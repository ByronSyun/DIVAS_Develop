from template import Agent
import random, time
from copy import deepcopy
from collections import deque
from Splendor.splendor_model import SplendorGameRule
from Splendor.splendor_utils import *

THINKTIME = 0.9
AGENT_NUM = 2  
GAMMA = 0.1  

class myAgent(Agent):
    def __init__(self, _id):
        super().__init__(_id)
        self.game_rule = SplendorGameRule(AGENT_NUM)  

    # Check if an action is in the action list
    def IsAction(self, action, action_list):
        t_action = ActionToString(self.id, action)
        return (t_action in action_list)

    # Transform the state into a string representation
    def TransformState(self, state, _id):
        t_state = state.__str__()
        return t_state
       # Get actions and categorize them
    def getActions(self, game_state):
        actions = self.game_rule.getLegalActions(game_state, self.id)
        total_gems = sum(game_state.agents[self.id].gems.values())

        # Buying actions
        buy_actions = [a for a in actions if a['type'] == 'buy_available']
        if buy_actions:
            buy_actions = sorted(buy_actions, key=lambda a: (self.evaluate_card_value(a['card'], game_state), self.resource_scarcity(a['card'], game_state)), reverse=True)
            return buy_actions[:3], 'buy'

        # Collecting gem actions
        gem_actions = [a for a in actions if a['type'] in ['collect_diff', 'collect_same']]
        if total_gems <= 8 and gem_actions:
            gem_actions = sorted(gem_actions, key=lambda a: self.evaluate_gem_need(a, game_state), reverse=True)
            return gem_actions, 'gem'

        return [random.choice(actions)], 'random'

    # Evaluate the value of a card
    def evaluate_card_value(self, card, game_state):
        layer_bonus = 1.3 if card.deck_id == 1 else 1
        return (card.points / sum(card.cost.values())) * layer_bonus

    # Evaluate the scarcity of resources needed for a card
    def resource_scarcity(self, card, game_state):
        scarcity = sum(game_state.board.gems[gem] < 3 for gem in card.cost)
        return scarcity

    # Evaluate the need for gems based on the current game state
    def evaluate_gem_need(self, action, game_state):
        needed_gems = {}
        for tier_cards in game_state.board.dealt:
            for card in tier_cards:
                if card:
                    for gem, count in card.cost.items():
                        needed_gems[gem] = needed_gems.get(gem, 0) + count

        collected_gems = action['collected_gems']
        return sum(needed_gems.get(gem, 0) * count for gem, count in collected_gems.items())


    # strategy to prioritize certain actions
    def get_strategy(self, state):
        actions = self.game_rule.getLegalActions(state, self.id)
        agent = state.agents[self.id]
        total_gems = sum(agent.gems.values())

        # Prioritize noble actions
        for action in actions:
            if 'noble' in action and action['noble'] is not None:
                return action

        # Prioritize buy actions with the highest points
        buy_actions = [a for a in actions if a['type'] == 'buy_available']
        if buy_actions:
            high_value_buys = sorted(buy_actions, key=lambda a: a['card'].points, reverse=True)
            if high_value_buys:
                return high_value_buys[0]

        # Collect gems if the total number of gems is less than or equal to 7
        if total_gems <= 7:
            gem_actions = [a for a in actions if a['type'] in ['collect_diff', 'collect_same']]
            if gem_actions:
                return random.choice(gem_actions)

        # Reserve actions based on the potential to buy in the next turn
        for action in actions:
            if action['type'] == 'reserve_available':
                card = action['card']
                if card and all(agent.gems[gem] + agent.cards[gem] >= count - 1 for gem, count in card.cost.items()):
                    return action

        return None

    # Method to select an action
    def SelectAction(self, actions, game_state):
        # Check for hardcoded strategy actions first
        get_action = self.get_strategy(game_state)
        if get_action:
            return get_action

        start_time = time.time()  # Record the start time
        q_sa = {}  # State-action values
        n_sa = {}  # State-action visit counts
        expanded_action = {}  # Expanded actions set
        t_root_state = self.TransformState(game_state, self.id)  
        count = 0  # Counter

        # Check if all actions are expanded for the given state
        def IsExpanded(t_state, actions):
            if t_state in expanded_action:
                return [action for action in actions if not self.IsAction(action, expanded_action[t_state])]
            return actions

        # Get the best action for the given state
        def BestAction(t_state, actions):
            max_value = -float('inf')
            best_action = random.choice(actions)
            for action in actions:
                t_sa = t_state + ActionToString(self.id, action)
                if t_sa in q_sa and q_sa[t_sa] > max_value:
                    max_value = q_sa[t_sa]
                    best_action = action
            return best_action

        # Run simulations within the given think time
        while time.time() - start_time < THINKTIME:
            count += 1
            state = deepcopy(game_state)  # Deep copy the game state
            new_actions = actions[:]  # Shallow copy the actions
            queue = deque()  # Action queue
            t_cur_state = self.TransformState(state, self.id)  # Current state string representation

            # Selection and Expansion phase
            while len(IsExpanded(t_cur_state, new_actions)) == 0 and not state.agents[self.id].score >= 15:
                if time.time() - start_time >= THINKTIME:  # Check the think time
                    return BestAction(t_root_state, actions)

                EPSILON = max(0.1, 1 - (time.time() - start_time) / THINKTIME)  # Dynamically adjust EPSILON
                if random.uniform(0, 1) < 1 - EPSILON:
                    cur_action = BestAction(t_cur_state, new_actions)
                else:
                    cur_action = random.choice(new_actions)

                queue.append((t_cur_state, cur_action))  # Add the current state and action to the queue
                state = self.game_rule.generateSuccessor(state, cur_action, self.id)  # Perform the action
                new_actions = self.game_rule.getLegalActions(state, self.id)  # Get new legal actions
                t_cur_state = self.TransformState(state, self.id)  # Update the current state

            # Action Expansion phase
            available_actions = IsExpanded(t_cur_state, new_actions)
            if available_actions:
                action = random.choice(available_actions)
                if t_cur_state in expanded_action:
                    expanded_action[t_cur_state].append(ActionToString(self.id, action))
                else:
                    expanded_action[t_cur_state] = [ActionToString(self.id, action)]
                queue.append((t_cur_state, action))
                state = self.game_rule.generateSuccessor(state, action, self.id)
                new_actions = self.game_rule.getLegalActions(state, self.id)
                t_cur_state = self.TransformState(state, self.id)

            # Simulation phase
            length = 0
            while not state.agents[self.id].score >= 15:
                length += 1
                if time.time() - start_time >= THINKTIME:
                    return BestAction(t_root_state, actions)
                cur_action = random.choice(new_actions)
                state = self.game_rule.generateSuccessor(state, cur_action, self.id)
                new_actions = self.game_rule.getLegalActions(state, self.id)

            reward = state.agents[self.id].score

            # Backpropagation phase
            cur_value = reward * (GAMMA ** length)
            while queue and time.time() < THINKTIME:
                t_state, cur_action = queue.pop()
                t_sa = t_state + ActionToString(self.id, cur_action)
                if t_sa in q_sa:
                    n_sa[t_sa] += 1
                    q_sa[t_sa] += (cur_value - q_sa[t_sa]) / n_sa[t_sa]
                else:
                    q_sa[t_sa] = cur_value
                    n_sa[t_sa] = 1
                cur_value *= GAMMA

        print("MCT:", count)
        return BestAction(t_root_state, actions)

