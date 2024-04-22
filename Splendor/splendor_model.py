# INFORMATION ------------------------------------------------------------------------------------------------------- #

# Author:  Steven Spratley, extending code by Guang Ho and Michelle Blom
# Date:    04/01/2021
# Purpose: Implements "Splendor" for the COMP90054 competitive game environment

# IMPORTS ------------------------------------------------------------------------------------------------------------#


import random, itertools, copy
from Splendor.splendor_utils import *
from template import GameState, GameRule
import Splendor.splendor_utils as utils

# CLASS DEF ----------------------------------------------------------------------------------------------------------#       


#Represents cards with a colour (str), unique code (str), resource costs (dict), deck ID (int), and points (int).
class Card():
    def __init__(self, colour, code, cost, deck_id, points):
        self.colour = colour
        self.code = code        
        self.cost = cost
        self.deck_id = deck_id
        self.points = points
    def __str__(self):
        gem_string = ''
        for colour,number in self.cost.items():
            gem_string += f'{", " if gem_string!="" else ""}{number} {colour}'
        return f'Tier {self.deck_id+1} {self.colour} card worth {self.points} points and costing {gem_string}'
    def __repr__(self):
        return self.code
    def __eq__(self, other): #Equal in the ways that matter: code is identical, and points haven't been tampered with.
        return hasattr(other, 'code') and other.code==self.code and self.points==other.points==CARDS[other.code][-1]
    

#Represents game as agents playing on a board with cards, gems, and nobles.
class SplendorState(GameState):           
    def __init__(self, num_agents):
        self.board  =  self.BoardState(num_agents)
        self.agents = [self.AgentState(i) for i in range(num_agents)]
        self.agent_to_move = 0
    
    # def __repr__(self) -> str:
    #     return super().__repr__()

    def __str__(self) -> str:
        output = ""
        output += str(self.board)
        for agent_state in self.agents:
            output += str(agent_state)
        return output
    
    class BoardState:
        def __init__(self, num_agents):
            self.decks = [[], [], []]
            self.dealt = [[None]*4 for i in range(3)]
            #All gem stacks start at (4,5,7) for games of (2,3,4) players respectively. Yellow seals always start at 5.
            n = [4,5,7][num_agents-2]
            self.gems = {'black':n, 'red':n, 'yellow':5, 'green':n, 'blue':n, 'white':n}
            #Deal out num_agents+1 of the 10 nobles at random. Nobles = (code, cost).
            self.nobles = random.sample(NOBLES, k=num_agents+1)
            #Sort cards into three deck tiers. Deal four cards per tier. Decks are shuffled before each deal.
            for code, (colour, cost, deck_id, points) in CARDS.items():
                deck_id -= 1 #Deck IDs are read in as (1-3), but should be zero-indexed instead.
                card = Card(colour, code, cost, deck_id, points)
                self.decks[deck_id].append(card)
            for deck in self.decks:
                random.shuffle(deck)
            for i in range(3):
                for j in range(4):
                    self.dealt[i][j] = self.deal(i)
                
        def deal(self, deck_id):
            if len(self.decks[deck_id]):
                random.shuffle(self.decks[deck_id])
                return self.decks[deck_id].pop()
            return None
        
        def dealt_list(self):
            return [card for deck in self.dealt for card in deck if card]
        
        def __str__(self) -> str:
            output = ""
            output += "\nAvailable Gems:\n"
            output += str(self.gems)
            output += "\nDealt Card List: \n"
            for card in self.dealt_list():

                output += "\t" +str(card)+ "\n"
            output += "\nNoble List \n"
            output += str(self.nobles)
            output += "\n"

            return output
        # def __repr__(self) -> str:
        #     return self.__str__
            
    class AgentState:
        def __init__(self, _id):
            self.id     = _id
            self.score  = 0
            self.gems   = {c: 0 for c in COLOURS.values()}
            self.cards  = {c:[] for c in COLOURS.values()}
            self.nobles = []
            self.passed = False
            self.agent_trace = AgentTrace(_id)
            self.last_action = None
        
        def __str__(self) -> str:
            output = ""
            output += "Agent (%d): \n" % (self.id)
            output += "\tscore: %d,\n" % (self.score)
            output += "\tgems: %s\n" % (self.gems)
            output += "\tcards: %s\n" % (self.cards)
            output += "\tnobles: %s.\n" % (self.nobles)
            return output
        

#Implements game logic.
class SplendorGameRule(GameRule):
    def __init__(self,num_of_agent):
        super().__init__(num_of_agent)
        #No private information: agent states are available to other agents. While upcoming cards are random, the decks
        #are still provided in the gamestate for agents to use if they want, since they are shuffled before each deal.
        self.private_information = None

    # # for now the idea is to see whether the action is one of the legal action   
    # def validAction(self, selected, all_legal_actions):
    #     # return utils.ValidAction(m, actions)
        

    def initialGameState(self):
        return SplendorState(self.num_of_agent)
    
    def generateSuccessor(self, state, action, agent_id):
        agent,board = state.agents[agent_id],state.board
        agent.last_action = action #Record last action such that other agents can make use of this information.
        score = 0
        
        if 'card' in action:
            card = action['card']
        
        if 'collect' in action['type'] or action['type']=='reserve':
            #Decrement board gem stacks by collected_gems. Increment player gem stacks by collected_gems.
            for colour,count in action['collected_gems'].items():
                board.gems[colour] -= count
                agent.gems[colour] += count
            #Decrement player gem stacks by returned_gems. Increment board gem stacks by returned_gems.
            for colour,count in action['returned_gems'].items():
                agent.gems[colour] -= count
                board.gems[colour] += count 
            
            if action['type'] == 'reserve':
                #Remove card from dealt cards by locating via unique code (cards aren't otherwise hashable).
                #Since we want to retain the positioning of dealt cards, set removed card slot to new dealt card.
                #Since the board may have None cards (empty slots that cannot be filled), check cards first.
                #Add card to player's yellow stack.
                for i in range(len(board.dealt[card.deck_id])):
                    if board.dealt[card.deck_id][i] and board.dealt[card.deck_id][i].code == card.code:
                        board.dealt[card.deck_id][i] = board.deal(card.deck_id)
                        agent.cards['yellow'].append(card)
                        break
        
        elif 'buy' in action['type']:
            #Decrement player gem stacks by returned_gems. Increment board gem stacks by returned_gems.
            for colour,count in action['returned_gems'].items():
                agent.gems[colour] -= count
                board.gems[colour] += count
            #If buying one of the available cards on the board, set removed card slot to new dealt card.
            #Since the board may have None cards (empty slots that cannot be filled), check cards first.
            if 'available' in action['type']:
                for i in range(len(board.dealt[card.deck_id])):
                    if board.dealt[card.deck_id][i] and board.dealt[card.deck_id][i].code == card.code:                
                        board.dealt[card.deck_id][i] = board.deal(card.deck_id)
                        break
            #Else, agent is buying a reserved card. Remove card from player's yellow stack.
            else:
                for i in range(len(agent.cards['yellow'])):
                    if agent.cards['yellow'][i].code == card.code:
                        del agent.cards['yellow'][i]
                        break                
            
            #Add card to player's stack of matching colour, and increment agent's score accordingly.
            agent.cards[card.colour].append(card)
            score += card.points
            
        if action['noble']:
            #Remove noble from board. Add noble to player's stack. Like cards, nobles aren't hashable due to possessing
            #dictionaries (i.e. resource costs). Therefore, locate and delete the noble via unique code.
            #Add noble's points to agent score.
            for i in range(len(board.nobles)):
                if board.nobles[i][0] == action['noble'][0]:
                    del board.nobles[i]
                    agent.nobles.append(action['noble'])
                    score += 3
                    break
                
        #Log this turn's action and any resultant score. Return updated gamestate.
        agent.agent_trace.action_reward.append((action,score))
        agent.score += score
        agent.passed = action['type']=='pass'
        return state

    #Game ends if any agent possesses at least 15 points, and all agents have gone in this round. As a very rare edge
    #case, poor playing agents might encounter a game where none are able to proceed. Game also ends in this case.
    def gameEnds(self):
        deadlock = 0
        for agent in self.current_game_state.agents:
            deadlock += 1 if agent.passed else 0
            if agent.score >= 15 and self.current_agent_index == 0:
                return True
        return deadlock==len(self.current_game_state.agents)

    #Return final score for this agent. If victories are tied, tie-break on number of cards placed by incrementing points.
    def calScore(self, game_state, agent_id):
        max_score = 0
        details = []
        bought_cards = lambda a : sum([len(cards) for colour,cards in a.cards.items() if colour!='yellow'])
        for a in game_state.agents:
            details.append((a.id, bought_cards(a), a.score))
            max_score = max(a.score, max_score)
        victors = [d for d in details if d[-1]==max_score]
        if len(victors) > 1 and agent_id in [d[0] for d in victors]:
            min_cards = min([d[1] for d in details])
            if bought_cards(game_state.agents[agent_id])==min_cards:
                # Add a half point if this agent was a tied victor, and had the fewest cards.
                return game_state.agents[agent_id].score + .5
        return game_state.agents[agent_id].score

    #Generate a list of gem combinations that can be returned, if agent exceeds limit with collected gems.
    #Agents are disallowed from returning gems of the same colour as those they've just picked up. Since collected_gems
    #is sampled exhaustively, this function simply needs to screen out colours in collected_gems, in order for agents
    #to be given all collected/returned combinations permissible.
    def generate_return_combos(self, current_gems, collected_gems):
        total_gem_count = sum(current_gems.values()) + sum(collected_gems.values())
        if total_gem_count > 10:
            return_combos = []
            num_return = total_gem_count - 10
            #Combine current and collected gems. Screen out gem colours that were just collected.
            total_gems = {i: current_gems.get(i, 0) + collected_gems.get(i, 0) for i in set(current_gems)}
            total_gems = {i[0]:i[1] for i in total_gems.items() if i[0] not in collected_gems.keys()}.items()
            #Form a total gems list (with elements == gem colours, and len == number of gems).
            total_gems_list = []                    
            for colour,count in total_gems:
                for _ in range(count):
                    total_gems_list.append(colour)
            #If, after screening, there aren't enough gems that can be returned, return an empty list, indicating that 
            #the collected_gems combination is not viable.
            if len(total_gems_list) < num_return:
                return []     
            #Else, find all valid combinations of gems to return.               
            for combo in set(itertools.combinations(total_gems_list, num_return)):
                returned_gems = {c:0 for c in COLOURS.values()}
                for colour in combo:
                    returned_gems[colour] += 1
                #Filter out colours with zero gems, and append.
                return_combos.append(dict({i for i in returned_gems.items() if i[-1]>0}))
                
            return return_combos
        
        return [{}] #If no gems need to be returned, return a list comprised of one empty combo.

    #Checks to see whether an agent's purchased cards and collected gems can cover a given resource cost.
    #If it can, return the combination of gems to be returned, if any. If it can't, return False.
    def resources_sufficient(self, agent, costs):
        wild = agent.gems['yellow']
        return_combo = {c:0 for c in COLOURS.values()}
        for colour,cost in costs.items():
            #If a shortfall is found, see if the difference can be made with wild/seal/yellow gems.
            available = agent.gems[colour] + len(agent.cards[colour])
            shortfall = max(cost - available, 0) #Shortfall shouldn't be negative.
            wild -= shortfall
            #If wilds are expended, the agent cannot make the purchase.
            if wild < 0:
                return False
            #Else, increment return_combo accordingly. Note that the agent should never return gems if it can afford 
            #to pay using its card stacks, and should never return wilds if it can return coloured gems instead. 
            #Although there may be strategic instances where holding on to coloured gems is beneficial (by virtue of 
            #shorting players from resources), in this implementation, this edge case is not worth added complexity.
            gem_cost                = max(cost - len(agent.cards[colour]), 0) #Gems owed.
            gem_shortfall           = max(gem_cost - agent.gems[colour], 0)   #Wilds required.
            return_combo[colour]    = gem_cost - gem_shortfall                #Coloured gems to be returned.
            return_combo['yellow'] += gem_shortfall                           #Wilds to be returned.
            
        #Filter out unnecessary colours and return dict specifying combination of gems.
        return dict({i for i in return_combo.items() if i[-1]>0})

    #Checks whether a particular noble is a candidate for visiting this agent.
    def noble_visit(self, agent, noble):
        _,costs = noble
        for colour,cost in costs.items():
            if not len(agent.cards[colour]) >= cost:
                return False
        return True

    def getLegalActions(self, game_state, agent_id):
        actions = []
        agent,board = game_state.agents[agent_id], game_state.board

        
        #A given turn consists of the following:
        #  1. Collect gems (up to 3 different)    OR
        #     Collect gems (2 same, if stack >=4) OR
        #     Reserve one of 12 available cards   OR
        #     Buy one of 12 available cards       OR
        #     Buy a previously reserved card.
        #  2. Discard down to 10 gems if necessary.
        #  3. Obtain a noble if requirements are met.
        
        #Since the gamestate does not change during an agent's turn, all turn parts are able to be planned for at once.
        #Action fields: {'type', 'collected_gems', 'returned_gems', 'card', 'noble'}
        
        #Actions will always take the form of one of the following three templates:
        # {'type': 'collect_diff'/'collect_same', 'collected_gems': {gem counts}, 'returned_gems': {gem counts}, 'noble': noble}
        # {'type': 'reserve', 'card':card, 'collected_gems': {'yellow': 1/None}, 'returned_gems': {colour: 1/None}, 'noble': noble}
        # {'type': 'buy_available'/'buy_reserve', 'card': card, 'returned_gems': {gem counts}, 'noble': noble}
        
        #First, check if any nobles are waiting to visit from the last turn. Ensure each action to follow recognises
        #this, and in the exceedingly rare case that there are multiple nobles waiting (meaning that, at the last turn,
        #this agent had the choice of at least 3 nobles), multiply all generated actions by these nobles to allow the
        #agent to choose again.
        potential_nobles = []
        for noble in board.nobles:
            if self.noble_visit(agent, noble):
                potential_nobles.append(noble)
        if len(potential_nobles) == 0:
            potential_nobles = [None]
        
        #Generate actions (collect up to 3 different gems). Work out all legal combinations. Theoretical max is 10.
        available_colours = [colour for colour,number in board.gems.items() if colour!='yellow' and number>0]
        num_holding_gem = sum(agent.gems.values())
        if num_holding_gem <=7 :
            min_comb_len = min(3,len(available_colours))

        elif num_holding_gem == 8:
            min_comb_len = min(2,len(available_colours))
        else:
            min_comb_len = min(1,len(available_colours))

        for combo_length in range(min_comb_len, min(len(available_colours), 3) + 1):
            for combo in itertools.combinations(available_colours, combo_length):
                collected_gems = {colour:1 for colour in combo}
                # make sure there is no action that collect empty gem
                if not collected_gems == {}:
                    #Find combos of gems to return, if any. Since the max to be returned can be 3, theoretical max 
                    #combinations will be 51, and max actions generated by the end of this stage will be 510. 
                    #Handling this branching factor properly will be crucial for agent performance.
                    #If return_combos comes back False, then taking these gems is invalid and won't be added.
                    return_combos = self.generate_return_combos(agent.gems, collected_gems)
                    for returned_gems in return_combos:
                        for noble in potential_nobles:
                            actions.append({'type': 'collect_diff',
                                            'collected_gems': collected_gems,
                                            'returned_gems': returned_gems,
                                            'noble': noble})
        
        #Generate actions (collect 2 identical gems). Theoretical max is 5.
        available_colours = [colour for colour,number in board.gems.items() if colour!='yellow' and number>=4]
        for colour in available_colours:
            collected_gems = {colour:2}
            
            #Like before, find combos to return, if any. Since the max to be returned is now 2, theoretical max 
            #combinations will be 21, and max actions generated here will be 105.
            return_combos = self.generate_return_combos(agent.gems, collected_gems)
            for returned_gems in return_combos:
                for noble in potential_nobles:
                    actions.append({'type': 'collect_same',
                                    'collected_gems': collected_gems,
                                    'returned_gems': returned_gems,
                                    'noble': noble})  

        #Generate actions (reserve card). Agent can reserve only if it possesses < 3 cards currently reserved.
        #With a reservation, the agent will receive one seal (yellow), if there are any left. Reservations are stored
        #and displayed under the agent's yellow stack, as they won't generate their true colour until fully purchased.
        #There is a possible 12 cards to be reserved, and if the agent goes over limit, there are max 6 gem colours
        #that can be returned, leading to a theoretical max of 72 actions here.
        if len(agent.cards['yellow']) < 3:
            collected_gems = {'yellow':1} if board.gems['yellow']>0 else {}
            return_combos = self.generate_return_combos(agent.gems, collected_gems)
            for returned_gems in return_combos:
                for card in board.dealt_list():
                    if card:
                        for noble in potential_nobles:
                            actions.append({'type': 'reserve',
                                            'card': card,
                                            'collected_gems': collected_gems,
                                            'returned_gems': returned_gems,
                                            'noble': noble})
            
        #Generate actions (buy card). Agents can buy cards if they can cover its resource cost. Resources can come from
        #an agent's gem and card stacks. Card stacks represent gem factories, or 'permanent gems'; if there are 2 blue 
        #cards already purchased, this acts like 2 extra blue gems to spend in a given turn. Gems are therefore only 
        #returned if the stack of that colour is insufficient to cover the cost.
        #Agents are disallowed from purchasing > 7 cards of any one colour, for the purposes of a clean interface. 
        #This is not expected to affect gameplay, as there is essentially zero strategic reason to exceed this limit.
        #Available cards consist of cards dealt onto the board, as well as cards previously reserved by this agent.
        #There is a max 15 actions that can be generated here (15 possible cards to be bought: 12 dealt + 3 reserved).
        #However, in the case that multiple nobles are made candidates for visiting with this move, this number will
        #be multiplied accordingly. This however, is a rare event.
        for card in board.dealt_list() + agent.cards['yellow']:
            if not card or len(agent.cards[card.colour]) == 7:
                continue
            returned_gems = self.resources_sufficient(agent, card.cost) #Check if this card is affordable.
            if type(returned_gems)==dict: #If a dict was returned, this means the agent possesses sufficient resources.
                #Check to see if the acquisition of a new card has meant new nobles becoming candidates to visit.
                new_nobles = []
                for noble in board.nobles:
                    agent_post_action = copy.deepcopy(agent)
                    #Give the card featured in this action to a copy of the agent.
                    agent_post_action.cards[card.colour].append(card)
                    #Use this copied agent to check whether this noble can visit.
                    if self.noble_visit(agent_post_action, noble):
                        new_nobles.append(noble) #If so, add noble to the new list.
                if not new_nobles:
                    new_nobles = [None]
                for noble in new_nobles:
                    actions.append({'type': 'buy_reserve' if card in agent.cards['yellow'] else 'buy_available',
                                    'card': card,
                                    'returned_gems': returned_gems,
                                    'noble': noble})
        
        #Return list of actions. If there are no actions (almost impossible), all this player can do is pass.
        #A noble is still permitted to visit if conditions are met.
        if not actions:
            for noble in potential_nobles:
                actions.append({'type': 'pass', 'noble':noble})
                
        return actions


# END FILE -----------------------------------------------------------------------------------------------------------#
