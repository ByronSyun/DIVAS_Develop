from template import Agent
import random
from collections import deque
import time
from copy import deepcopy
from Splendor.splendor_model import SplendorGameRule

THINKTIME = 0.95
NUM_AGENT = 2

class myAgent(Agent):
    def __init__(self, _id):
        super().__init__(_id)
        self.game_rule = SplendorGameRule(NUM_AGENT)

    def getActions(self, game_state):
        actions = self.game_rule.getLegalActions(game_state, self.id)
        total_gems = sum(game_state.agents[self.id].gems.values())

        # buying
        buy_actions = [a for a in actions if a['type'] == 'buy_available']
        if buy_actions:
            buy_actions = sorted(buy_actions, key=lambda a: (self.evaluate_card_value(a['card'], game_state), self.resource_scarcity(a['card'], game_state)), reverse=True)
            return buy_actions[:3], 'buy'

        # collecting gems
        gem_actions = [a for a in actions if a['type'] in ['collect_diff', 'collect_same']]
        if total_gems <= 8 and gem_actions:
            gem_actions = sorted(gem_actions, key=lambda a: self.evaluate_gem_need(a, game_state), reverse=True)
            return gem_actions, 'gem'

        return [random.choice(actions)], 'random'

    def evaluate_card_value(self, card, game_state):
        game_phase = len([c for p in game_state.agents for c in p.cards]) / 90  # 假设总卡片数为90
        if game_phase < 0.3:  # 游戏早期
            phase_weight = {1: 1.5, 2: 1, 3: 0.8}
        elif game_phase < 0.6:  # 游戏中期
            phase_weight = {1: 1.2, 2: 1.5, 3: 1}
        else:  # 游戏后期
            phase_weight = {1: 1, 2: 1.3, 3: 1.2}
        layer_bonus = phase_weight.get(card.deck_id, 1)
        # layer_bonus = 1.5 if card.deck_id == 1 else 1
        return (card.points / sum(card.cost.values())) * layer_bonus

    def resource_scarcity(self, card, game_state):
        scarcity = sum(game_state.board.gems[gem] < 3 for gem in card.cost)
        return scarcity

    def evaluate_gem_need(self, action, game_state):
        needed_gems = {}
        for tier_cards in game_state.board.dealt:
            for card in tier_cards:
                if card:
                    for gem, count in card.cost.items():
                        needed_gems[gem] = needed_gems.get(gem, 0) + count

        collected_gems = action['collected_gems']
        return sum(needed_gems.get(gem, 0) * count for gem, count in collected_gems.items())

    def SelectAction(self, actions, game_state):
        startTime = time.time()
        initial_actions, actionType = self.getActions(game_state)

        queue = deque([(deepcopy(game_state), [])])
        best_score = float('-inf')
        best_action = None

        while queue and (time.time() - startTime) < THINKTIME:
            current_state, path = queue.popleft()

            legal_actions = [action for action in initial_actions if action in self.game_rule.getLegalActions(current_state, self.id)]

            for action in legal_actions:
                new_state = deepcopy(current_state)
                new_state = self.game_rule.generateSuccessor(new_state, action, self.id)
                new_path = path + [action]

                score = self.evaluate_state(new_state)
                if score > best_score:
                    best_score = score
                    best_action = new_path[0] if new_path else None

                queue.append((new_state, new_path))

        return best_action if best_action else random.choice(initial_actions)

    def evaluate_state(self, state):
        return state.agents[self.id].score
