from template import Agent
import random, time
from copy import deepcopy
from collections import deque
from Splendor.splendor_model import SplendorGameRule
from Splendor.splendor_utils import *

THINKTIME = 0.9
AGENT_NUM = 2
GAMMA = 0.3

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

    # Method to select an action
    def SelectAction(self, actions, game_state):
        start_time = time.time()  # Record the start time
        q_sa = {}  # State-action values
        n_sa = {}  # State-action visit counts
        expanded_action_s = {}  # Expanded actions set
        t_root_state = self.TransformState(game_state, self.id)  # Root state string representation
        count = 0  # Counter

        # Check if all actions are expanded for the given state
        def IsExpanded(t_state, actions):
            if t_state in expanded_action_s:
                return [action for action in actions if not self.IsAction(action, expanded_action_s[t_state])]
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
                    print("MCT:", count)
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
                if t_cur_state in expanded_action_s:
                    expanded_action_s[t_cur_state].append(ActionToString(self.id, action))
                else:
                    expanded_action_s[t_cur_state] = [ActionToString(self.id, action)]
                queue.append((t_cur_state, action))
                state = self.game_rule.generateSuccessor(state, action, self.id)
                new_actions = self.game_rule.getLegalActions(state, self.id)
                t_cur_state = self.TransformState(state, self.id)

            # Simulation phase
            length = 0
            while not state.agents[self.id].score >= 15:
                length += 1
                if time.time() - start_time >= THINKTIME:
                    print("MCT:", count)
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
