# INFORMATION ------------------------------------------------------------------------------------------------------- #

# Author:  Steven Spratley, extending code by Guang Ho and Michelle Blom
# Date:    04/01/2021
# Purpose: Implements "Splendor" for the COMP90054 competitive game environment

# CONSTANTS ----------------------------------------------------------------------------------------------------------#


#CARDS holds the colours, unique codes, gemstone costs, deck ID (1-3), and point totals of all 90 cards in the game.

#        code : (colour, cost, deck_id, points)
CARDS = {'1g1w1r1b': ('black', {'green': 1, 'white': 1, 'red': 1, 'blue': 1}, 1, 0),
         '1g1w1r2b': ('black', {'green': 1, 'white': 1, 'red': 1, 'blue': 2}, 1, 0),
         '2b1r2w': ('black', {'blue': 2, 'red': 1, 'white': 2}, 1, 0),
         '2b2g3w': ('black', {'blue': 2, 'green': 2, 'white': 3}, 2, 1),
         '2g1r': ('black', {'green': 2, 'red': 1}, 1, 0),
         '2w2g': ('black', {'white': 2, 'green': 2}, 1, 0),
         '3g': ('black', {'green': 3}, 1, 0),
         '3g2B3w': ('black', {'green': 3, 'black': 2, 'white': 3}, 2, 1),
         '3r1B1g': ('black', {'red': 3, 'black': 1, 'green': 1}, 1, 0),
         '4b': ('black', {'blue': 4}, 1, 1),
         '4g2r1b': ('black', {'green': 4, 'red': 2, 'blue': 1}, 2, 2),
         '5g3r': ('black', {'green': 5, 'red': 3}, 2, 2),
         '5g3w3r3b': ('black', {'green': 5, 'white': 3, 'red': 3, 'blue': 3}, 3, 3),
         '5w': ('black', {'white': 5}, 2, 2),
         '6B': ('black', {'black': 6}, 2, 3),
         '6r3B3g': ('black', {'red': 6, 'black': 3, 'green': 3}, 3, 4),
         '7r': ('black', {'red': 7}, 3, 4),
         '7r3B': ('black', {'red': 7, 'black': 3}, 3, 5),
         '1r1w1B1g': ('blue', {'red': 1, 'white': 1, 'black': 1, 'green': 1}, 1, 0),
         '1r4B2w': ('blue', {'red': 1, 'black': 4, 'white': 2}, 2, 2),
         '1w2B': ('blue', {'white': 1, 'black': 2}, 1, 0),
         '2g2B': ('blue', {'green': 2, 'black': 2}, 1, 0),
         '2g2r1w': ('blue', {'green': 2, 'red': 2, 'white': 1}, 1, 0),
         '2g3r2b': ('blue', {'green': 2, 'red': 3, 'blue': 2}, 2, 1),
         '2r1w1B1g': ('blue', {'red': 2, 'white': 1, 'black': 1, 'green': 1}, 1, 0),
         '3B': ('blue', {'black': 3}, 1, 0),
         '3b3B6w': ('blue', {'blue': 3, 'black': 3, 'white': 6}, 3, 4),
         '3g1r1b': ('blue', {'green': 3, 'red': 1, 'blue': 1}, 1, 0),
         '3g3B2b': ('blue', {'green': 3, 'black': 3, 'blue': 2}, 2, 1),
         '3r3w5B3g': ('blue', {'red': 3, 'white': 3, 'black': 5, 'green': 3}, 3, 3),
         '4r': ('blue', {'red': 4}, 1, 1),
         '5b': ('blue', {'blue': 5}, 2, 2),
         '5w3b': ('blue', {'white': 5, 'blue': 3}, 2, 2),
         '6b': ('blue', {'blue': 6}, 2, 3),
         '7w': ('blue', {'white': 7}, 3, 4),
         '7w3b': ('blue', {'white': 7, 'blue': 3}, 3, 5),
         '1r1w1B1b': ('green', {'red': 1, 'white': 1, 'black': 1, 'blue': 1}, 1, 0),
         '1r1w2B1b': ('green', {'red': 1, 'white': 1, 'black': 2, 'blue': 1}, 1, 0),
         '2b1B4w': ('green', {'blue': 2, 'black': 1, 'white': 4}, 2, 2),
         '2b2r': ('green', {'blue': 2, 'red': 2}, 1, 0),
         '2g3r3w': ('green', {'green': 2, 'red': 3, 'white': 3}, 2, 1),
         '2r2B1b': ('green', {'red': 2, 'black': 2, 'blue': 1}, 1, 0),
         '2w1b': ('green', {'white': 2, 'blue': 1}, 1, 0),
         '3b1g1w': ('green', {'blue': 3, 'green': 1, 'white': 1}, 1, 0),
         '3b2B2w': ('green', {'blue': 3, 'black': 2, 'white': 2}, 2, 1),
         '3r': ('green', {'red': 3}, 1, 0),
         '3r5w3B3b': ('green', {'red': 3, 'white': 5, 'black': 3, 'blue': 3}, 3, 3),
         '4B': ('green', {'black': 4}, 1, 1),
         '5b3g': ('green', {'blue': 5, 'green': 3}, 2, 2),
         '5g': ('green', {'green': 5}, 2, 2),
         '6b3g3w': ('green', {'blue': 6, 'green': 3, 'white': 3}, 3, 4),
         '6g': ('green', {'green': 6}, 2, 3),
         '7b': ('green', {'blue': 7}, 3, 4),
         '7b3g': ('green', {'blue': 7, 'green': 3}, 3, 5),
         '1g1w1B1b': ('red', {'green': 1, 'white': 1, 'black': 1, 'blue': 1}, 1, 0),
         '1g2B2w': ('red', {'green': 1, 'black': 2, 'white': 2}, 1, 0),
         '1g2w1B1b': ('red', {'green': 1, 'white': 2, 'black': 1, 'blue': 1}, 1, 0),
         '1r3B1w': ('red', {'red': 1, 'black': 3, 'white': 1}, 1, 0),
         '2b1g': ('red', {'blue': 2, 'green': 1}, 1, 0),
         '2r3B2w': ('red', {'red': 2, 'black': 3, 'white': 2}, 2, 1),
         '2r3B3b': ('red', {'red': 2, 'black': 3, 'blue': 3}, 2, 1),
         '2w2r': ('red', {'white': 2, 'red': 2}, 1, 0),
         '3g3w3B5b': ('red', {'green': 3, 'white': 3, 'black': 3, 'blue': 5}, 3, 3),
         '3w': ('red', {'white': 3}, 1, 0),
         '3w5B': ('red', {'white': 3, 'black': 5}, 2, 2),
         '4b2g1w': ('red', {'blue': 4, 'green': 2, 'white': 1}, 2, 2),
         '4w': ('red', {'white': 4}, 1, 1),
         '5B': ('red', {'black': 5}, 2, 2),
         '6g3r3b': ('red', {'green': 6, 'red': 3, 'blue': 3}, 3, 4),
         '6r': ('red', {'red': 6}, 2, 3),
         '7g': ('red', {'green': 7}, 3, 4),
         '7g3r': ('red', {'green': 7, 'red': 3}, 3, 5),
         '1b1B3w': ('white', {'blue': 1, 'black': 1, 'white': 3}, 1, 0),
         '1r1b1B1g': ('white', {'red': 1, 'blue': 1, 'black': 1, 'green': 1}, 1, 0),
         '1r1b1B2g': ('white', {'red': 1, 'blue': 1, 'black': 1, 'green': 2}, 1, 0),
         '2b2B': ('white', {'blue': 2, 'black': 2}, 1, 0),
         '2g1B2b': ('white', {'green': 2, 'black': 1, 'blue': 2}, 1, 0),
         '2r1B': ('white', {'red': 2, 'black': 1}, 1, 0),
         '2r2B3g': ('white', {'red': 2, 'black': 2, 'green': 3}, 2, 1),
         '3b': ('white', {'blue': 3}, 1, 0),
         '3b3r2w': ('white', {'blue': 3, 'red': 3, 'white': 2}, 2, 1),
         '3r6B3w': ('white', {'red': 3, 'black': 6, 'white': 3}, 3, 4),
         '3w7B': ('white', {'white': 3, 'black': 7}, 3, 5),
         '4g': ('white', {'green': 4}, 1, 1),
         '4r2B1g': ('white', {'red': 4, 'black': 2, 'green': 1}, 2, 2),
         '5r': ('white', {'red': 5}, 2, 2),
         '5r3B': ('white', {'red': 5, 'black': 3}, 2, 2),
         '5r3b3B3g': ('white', {'red': 5, 'blue': 3, 'black': 3, 'green': 3}, 3, 3),
         '6w': ('white', {'white': 6}, 2, 3),
         '7B': ('white', {'black': 7}, 3, 4)}


#         (code, cost)
NOBLES = [('4g4r', {'green': 4, 'red': 4}), 
          ('3w3r3B', {'white': 3, 'red': 3, 'black': 3}), 
          ('3b3g3r', {'blue': 3, 'green': 3, 'red': 3}), 
          ('3w3b3g', {'white': 3, 'blue': 3, 'green': 3}), 
          ('4w4b', {'white': 4, 'blue': 4}), 
          ('4w4B', {'white': 4, 'black': 4}), 
          ('3w3b3B', {'white': 3, 'blue': 3, 'black': 3}), 
          ('4r4B', {'red': 4, 'black': 4}), 
          ('4b4g', {'blue': 4, 'green': 4}), 
          ('3g3r3B', {'green': 3, 'red': 3, 'black': 3})]


COLOURS = {'B':'black', 'r':'red', 'y':'yellow', 'g':'green', 'b':'blue', 'w':'white'}


# CLASS DEF ----------------------------------------------------------------------------------------------------------#


# Convert the filename of an image asset and return game information (e.g. its colour and gem cost).
def convert_filename(filename):
    f = filename[:-4] #Strip extension.
    if f[-1].isdigit(): #If last character is digit, this is a gem asset. Process accordingly.
        f = f.split('_')
        return (f[0],int(f[1])) if len(f)==2 else (f[0],int(f[2])) #Return colour and number.
    colour,code = f.split('_') if f[0].isalpha() else (None,f) #Else, this is a card asset. Process accordingly.
    code = code.replace('blu', 'b').replace('bla', 'B')
    cost = {}
    for i in range(0, len(code), 2):
        cost[COLOURS[code[i+1]]] = code[i]
    return colour,code,cost

# Bundle together an agent's activity in the game for use in updating a policy.
class AgentTrace:
    def __init__(self, pid):
        self.id = pid
        self.action_reward = [] # Turn-by-turn history consisting of (action,reward) tuples.
    
def GemsToString(gem_dict):
    gem_counts = list(gem_dict.items())
    if len(gem_counts)==1:
        return '{} {} gem{}'.format(gem_counts[0][1], gem_counts[0][0], 's' if gem_counts[0][1] > 1 else '')
    elif len(gem_counts)==2:
        return '{} {} and {} {} gems'.format(gem_counts[0][1], gem_counts[0][0], gem_counts[1][1], gem_counts[1][0])
    elif len(gem_counts)==3:
        return '{} {}, {} {}, and {} {} gems'.format(
            gem_counts[0][1], gem_counts[0][0], gem_counts[1][1], gem_counts[1][0], gem_counts[2][1], gem_counts[2][0])
        
def ActionToString(agent_id, action):
    desc = ''
    if 'card' in action:
        card = action['card']
    if 'collect' in action['type']:
        if len(action['returned_gems']):
            desc = "Agent {} collected {}, exceeded the limit, and returned {}."\
                .format(agent_id, GemsToString(action['collected_gems']), GemsToString(action['returned_gems']))
        else:
           desc = "Agent {} collected {}.".format(agent_id, GemsToString(action['collected_gems']))           

    elif action['type']=='reserve':
        desc = "Agent {} reserved a Tier {} {} card.".format(agent_id, card.deck_id+1, card.colour)
        
    elif 'buy' in action['type']:
        if card.points:
            desc = "Agent {} bought a {}Tier {} {} card, earning {} point{}!"\
                .format(agent_id, 'previously reserved ' if 'reserved' in action['type'] else '',
                        card.deck_id+1, card.colour, card.points, 's' if card.points > 1 else '')
        else:
            desc = "Agent {} bought a {}Tier {} {} card."\
                .format(agent_id, 'previously reserved ' if 'reserved' in action['type'] else '',
                        card.deck_id+1, card.colour)
                
    elif action['type']=='pass':
        desc = "Agent {} has no gems to take, and nothing to buy.".format(agent_id)
                
    if action['noble']:
        desc += ' A noble has also taken interest, earning 3 points!'
        
    return desc

def AgentToString(agent_id, ps):
    desc = "Agent #{} has scored {} points thus far.\n".format(agent_id, ps.score)
    return desc

def BoardToString(game_state):
    desc = ""
    return desc


# END FILE -----------------------------------------------------------------------------------------------------------#