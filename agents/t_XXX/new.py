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
        total_gems = sum(game_state.agents[self.id].gems.values())
        actions = self.game_rule.getLegalActions(game_state, self.id)
        
        buy_actions = [action for action in actions if action["type"] in ("buy_available", "buy_reserve")]
        gem_actions = [action for action in actions if action["type"] in ("collect_diff", "collect_same") and sum(game_state.board.gems.values()) >= 3]
        reserve_actions = [action for action in actions if action["type"] == "reserve"]
        
        if buy_actions:
            return buy_actions, "buy_actions"
        elif gem_actions:
            return gem_actions, "gem_actions"
        elif reserve_actions:
            return reserve_actions, "reserve_actions"
        return [], "no_actions"

    def SelectAction(self, actions, game_state):
        start_time = time.time()
        best_action = None
        best_score = float('-inf')
        
        depth_limit = 1  # Start with a manageable depth to ensure responsiveness
        while time.time() - start_time < THINKTIME and depth_limit < 10:
            action, score = self.depthLimitedSearch(game_state, depth_limit, best_score, start_time)
            if score > best_score:
                best_score = score
                best_action = action
            depth_limit += 1  # Incrementally increase the search depth
        
        return best_action if best_action else random.choice(actions)

    def depthLimitedSearch(self, game_state, depth, best_score, start_time):
        if depth == 0 or time.time() - start_time > THINKTIME:
            return None, self.game_rule.calScore(game_state, self.id)  # Evaluate the leaf node

        best_action = None
        actions, _ = self.getActions(game_state)
        for action in actions:
            next_state = self.game_rule.generateSuccessor(deepcopy(game_state), action, self.id)
            _, score = self.depthLimitedSearch(next_state, depth - 1, best_score, start_time)
            
            if score > best_score:
                best_score = score
                best_action = action
        
        return best_action, best_score

    def collectNeedGem(self, action, state):
        cards = state.board.dealt_list()
        need_gems = {color: 0 for color in ['black', 'red', 'green', 'blue', 'white']}
        for card in cards:
            for color, num in card.cost.items():
                need_gems[color] += num
        most_need_color = max(need_gems, key=need_gems.get)
        return most_need_color in action['collected_gems'].keys()