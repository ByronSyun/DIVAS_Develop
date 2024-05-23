import csv
from template import Agent
import random, time, json
from copy import deepcopy
from Splendor.splendor_model import SplendorGameRule as GameRule

THINKTIME = 0.95
NUM_PLAYERS = 2
GAMMA = 0.4
EPSILON = 0.9
ALPHA = 0.1
NEG_INFINITY = -999999
#
class myAgent(Agent):
    def __init__(self, agent_id, selected_features=None):
        super().__init__(agent_id)
        self.game_rule = GameRule(NUM_PLAYERS)

        # Selected features and weights
        self.selected_features = selected_features if selected_features is not None else [i for i in range(14)]
        self.weights = [1] * len(self.selected_features)
        
        # Load weights
        self.load_weights('agents/t_014/new_w.json')
        print(f"Loaded weights: {self.weights}")

    def load_weights(self, filepath):
        try:
            with open(filepath, 'r', encoding='utf-8') as file:
                loaded_weights = json.load(file)['weight']
                if len(loaded_weights) == len(self.selected_features):
                    self.weights = loaded_weights
                else:
                    print("Mismatch in length of loaded weights and selected features. Initializing with default weights.")
                    self.weights = [1] * len(self.selected_features)
        except FileNotFoundError:
            print("Weight file not found. Initializing with default weights.")
            self.weights = [1] * len(self.selected_features)

    def get_actions(self, state, state_id):
        return self.game_rule.getLegalActions(state, state_id)

    def perform_action(self, state, action, agent_id):
        return self.game_rule.generateSuccessor(state, action, agent_id)

    def SelectAction(self, actions, game_state):
        start_time = time.time()
        best_action = random.choice(actions)
        best_q_value = NEG_INFINITY

        for action in actions:
            if time.time() - start_time > THINKTIME:
                print("Time out")
                break
            q_value = self.calculate_q_value(game_state, action, self.id)
            if q_value > best_q_value:
                best_q_value = q_value
                best_action = action
                
        return best_action
    
    def calculate_features(self, state, action, agent_id):
        board = state.board
        agent = state.agents[agent_id]
        features = []
        NUM_FEATURE = 14
        # Define all potential features
        all_features = [0] * NUM_FEATURE

        if 'collect' in action['type']:
            for level in range(3):
                color_demand = {'black': 0, 'red': 0, 'green': 0, 'blue': 0, 'white': 0, 'yellow': 0}
                for card in board.dealt[level]:
                    if card is not None:
                        for color in card.cost:
                            if card.cost[color] > len(agent.cards[color]) + agent.gems[color]:
                                color_demand[color] += 1
                demand_score = 0
                for color in action['collected_gems']:
                    demand_score += action['collected_gems'][color] * color_demand[color]
                for color in action['returned_gems']:
                    demand_score -= action['returned_gems'][color] * color_demand[color]
                all_features[level] = demand_score / 100

        if 'buy' in action['type']:
            card = action.get('card')
            if card is not None:
                all_features[6] = card.points / 5
                cost_sum = sum(card.cost.values())
                all_features[7] = cost_sum / 15
                noble_demand = sum(1 for noble in board.nobles if card.colour in noble[1])
                all_features[8] = noble_demand / 5

        if 'reserve' in action['type']:
            defense_score = 0
            opponent_agent = state.agents[1 - agent_id]
            opponent_actions = self.get_actions(state, 1 - agent_id)
            for opp_action in opponent_actions:
                if 'buy' in opp_action['type']:
                    opp_card = opp_action.get('card')
                    if opp_card is not None and opp_card.points >= 3:
                        defense_score = 1
                        break
                    if 'noble' in opp_action and opp_action['noble'] is not None:
                        noble = opp_action['noble']
                        if opp_card is not None and opp_card.colour in noble[1] and len(opponent_agent.cards[opp_card.colour]) + 1 == noble[1][opp_card.colour]:
                            defense_score = 1
                            break
            all_features[10] = defense_score
        if 'noble' in action and action['noble'] is not None:
            all_features[9] = 1
        all_features[11] = sum(len(cards) for cards in agent.cards.values()) / 10
        
        potential_noble_points = sum(3 for noble in board.nobles if all(len(agent.cards[color]) >= count for color, count in noble[1].items()))
        all_features[12] = potential_noble_points / 3
        
        gem_priority = sum(count for gem, count in action.get('collected_gems', {}).items() if any(gem in card.cost for level in range(3) for card in board.dealt[level] if card is not None))
        all_features[13] = gem_priority / 10
        
        opponent = state.agents[1 - agent_id]
        threat_level = opponent.score
        all_features[5] = threat_level / 10
        
        if 'collect' in action['type']:
            efficiency = sum(card.cost[gem] for gem, count in action['collected_gems'].items() for level in range(3) for card in board.dealt[level] if card is not None and gem in card.cost and count > 0)
            all_features[4] = efficiency / 100

        if 'collect' in action['type']:
            opponent_gem_need = sum(card.cost[gem] for gem, count in action['collected_gems'].items() for level in range(3) for card in board.dealt[level] if card is not None and gem in card.cost and count > 0)
            all_features[3] = opponent_gem_need / 100

        # Select only the features specified in self.selected_features
        features = [all_features[i] for i in self.selected_features]
        print(f"Calculated features: {features}")
        print(f"Feature length: {len(features)}")

        return features

    def calculate_q_value(self, state, action, agent_id):
        features = self.calculate_features(state, action, agent_id)
        print(f"Weight length: {len(self.weights)}")
        if len(features) != len(self.weights):
            print(f"Features and weights length mismatch! Features: {len(features)}, Weights: {len(self.weights)}")
            return NEG_INFINITY
        return sum(weight * feature for weight, feature in zip(self.weights, features))