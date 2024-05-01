from template import Agent
import random
from copy import deepcopy
import time
from Splendor.splendor_model import SplendorGameRule

THINKTIME = 0.9
NUM_OF_AGENT = 2

class myAgent(Agent):
    def __init__(self, _id):
        super().__init__(_id)
        self.game_rule = SplendorGameRule(NUM_OF_AGENT)

    def getActions(self, game_state):
        actions = self.game_rule.getLegalActions(game_state, self.id)
        prioritized_actions = sorted(actions, key=lambda x: self.evaluateAction(x, game_state), reverse=True)
        return prioritized_actions

    def evaluateAction(self, action, game_state):
        score = 0
        if action['type'].startswith('buy'):
            card = action['card']
            score += card.points  # Higher score for cards with more points
            score += 5 * len([noble for noble in game_state.board.nobles if self.can_attract_noble_after_purchase(game_state.agents[self.id], noble, card)])
        elif action['type'].startswith('collect'):
            score += 1  # Lower priority unless specific gems are critically needed
        return score

    def can_attract_noble_after_purchase(self, agent, noble, card):
        # Simplified check if buying this card would attract a noble
        needed_bonuses = {color: count - (agent.cards.get(color, 0) + (1 if card.colour == color else 0))
                        for color, count in noble.cost.items()}
        return all(count <= 0 for count in needed_bonuses.values())

    def depthLimitedSearch(self, game_state, depth, best_score):
        if depth == 0:
            return None, self.heuristic(game_state)

        best_action = None
        actions = self.getActions(game_state)
        for action in actions:
            if not self.isFeasible(action, game_state):
                continue
            next_state = self.game_rule.generateSuccessor(deepcopy(game_state), action, self.id)
            _, score = self.depthLimitedSearch(next_state, depth - 1, best_score)
            heuristic_score = score + self.heuristic(next_state)

            if heuristic_score > best_score:
                best_score = heuristic_score
                best_action = action
        return best_action, best_score

    def heuristic(self, game_state):
        agent = game_state.agents[game_state.agent_to_move]
        score = agent.score
        score += sum(5 for noble in game_state.board.nobles if self.can_attract_noble(agent, noble))
        return score
    
    def shouldPrune(self, game_state, action, depth):
        if action['type'] == 'collect_same' and sum(game_state.agents[game_state.agent_to_move].gems.values()) > 7:
            return True  # Prune collecting gems if already having many, unless critical
        
        return False
