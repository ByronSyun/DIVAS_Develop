# INFORMATION ------------------------------------------------------------------------------------------------------- #

# Author:  Steven Spratley, extending code by Guang Ho and Michelle Blom
# Date:    04/01/2021
# Purpose: Implements "Splendor" for the COMP90054 competitive game environment

# IMPORTS ------------------------------------------------------------------------------------------------------------#


import tkinter, copy, time, os, time
from   collections             import defaultdict
from   Splendor.splendor_utils import *
from   template                import Displayer


# CLASS DEF ----------------------------------------------------------------------------------------------------------#


def make_label(master, x, y, h, w, *args, **kwargs):
    f = tkinter.Frame(master, height=h, width=w)
    f.pack_propagate(0)
    f.place(x=x, y=y)
    label = tkinter.Label(f, *args, **kwargs)
    label.pack(fill=tkinter.BOTH, expand=1)
    return label


class AgentArea():
    def __init__(self, root, agent_id, agent_title):
        self.root = root
        self.agent_id = agent_id
        self.title_text = agent_title
        self.agent_title_var = tkinter.StringVar()
        self.set_agent_title(score=0)
        fsize = int(15*s) if len(agent_title)<=20 else int(10*s)
        self.agent_title = make_label(root, textvariable=self.agent_title_var, x=NAME_POS[0], 
                                      y=NAME_POS[1]+PLYR_SEP*agent_id, h=30*s, w=300*s,
                                      font=('times', fsize), bg='black', fg='white')
        
        #Initialise gem, card, and noble stacks.
        self.gems    = {c: None    for c in COLOURS.values()}
        self.cards   = {c:[None]*7 for c in COLOURS.values()}
        self.sleeves = [None]*3 #Max. 3 reserved cards.
        self.nobles  = []
       
    #Set agent title labels.
    def set_agent_title(self, score):
        if len(self.title_text) <= 20:
            self.agent_title_var.set("Agent #{}: {}. Score: {}".format(self.agent_id, self.title_text, score))
        else:
            self.agent_title_var.set("{}. Score: {}".format(self.title_text, score))
        
    #Place images of gems, cards, and nobles in this agent's area, colour by colour.
    def update(self, agent, resources):
        self.set_agent_title(agent.score)
        i = 0
        for colour in COLOURS.values():
            #Load and display image of gem counter (of this colour), with correct number.
            xpos = PGEM_POS[0]+PCRD_SEP[0]*i
            ypos = PGEM_POS[1]+PLYR_SEP*self.agent_id
            if agent.gems[colour]: #Draw gem counter only if there are gems in the stack.
                gem = self.root.create_image(xpos, ypos, 
                    image=resources['gems_small'][colour][agent.gems[colour]], tags='gem_small')
                self.gems[colour] = gem
            
            #Load and display images of cards (in this colour stack).
            j = 0
            for card in agent.cards[colour]:
                xpos = PCRD_POS[0]+PCRD_SEP[0]*i
                ypos = PCRD_POS[1]+PLYR_SEP*self.agent_id+PCRD_SEP[1]*j
                self.cards[colour][j] = self.root.create_image(xpos, ypos, 
                    image=resources['cards_small'][card.colour][card.code], tags='card_small')
                if colour=='yellow': #If these cards are yellow, that means they are unpaid. Display with card sleeve.
                    self.sleeves[j] = self.root.create_image(xpos, ypos, image=resources['card_sleeve'], tags='card_small')
                j += 1
            i += 1
            
        #Load and display images of obtained nobles.
        for i in range(len(agent.nobles)):
            xpos = PNBL_POS[0]
            ypos = PNBL_POS[1]+PLYR_SEP*self.agent_id+PNBL_SEP*i
            self.nobles.append(self.root.create_image(xpos, ypos, 
                                    image=resources['nobles_small'][agent.nobles[i][0]], tags='noble_small'))
      
        
def can_buy(agent, card):
    wild = agent.gems['yellow']
    for colour,cost in card.cost.items():
        wild -= max(cost - agent.gems[colour] - len(agent.cards[colour]), 0)
        if wild < 0:
            return False
    return True

           
class BoardArea():
    def __init__(self, root):
        self.root  = root
        self.start = True
        self.dealt = [[None]*4 for i in range(3)]
        self.dealt_transparencies = [[None]*4 for i in range(3)]
        self.gems  = {}
        self.nobles = []
        self.cntrs = [None]*3
        for i in range(3):
            self.cntrs[i] = self.root.create_text((D_COUNTR[0], D_COUNTR[1]+CARD_SEP[1]*i), 
                            text=str([40,30,20][i]), font=('times', int(20*s)), fill=['green','#bf7c1d','blue'][i])

    #Update text and images on the gameboard.
    def update(self, state, resources, no_highlighting):
        agent,board = state.agents[state.agent_to_move],state.board
        #If first update (start of the game), stagger image placements to make a simple animation.
        if self.start:
            self.start=False
            self.root.update()
            time.sleep(0.6)
            animation_sequence = [[[0,0]], [[0,1],[1,0]], [[0,2],[1,1],[2,0]], 
                                  [[0,3],[1,2],[2,1]], [[1,3],[2,2]], [[2,3]]]
            deck_counts = [40,30,20]
            i = 0
            for step in animation_sequence:
                for card in step:
                    deck_id,loc = card[0],card[1]
                    deck_counts[deck_id] -= 1
                    self.root.itemconfigure(self.cntrs[deck_id], text=str(deck_counts[deck_id]))
                    card = board.dealt[deck_id][loc]
                    xpos, ypos  = CARD_POS[0]+CARD_SEP[0]*loc, CARD_POS[1]+CARD_SEP[1]*deck_id
                    self.dealt[deck_id][loc] = (self.root.create_image(xpos, ypos, 
                                        image=resources['cards_large'][card.colour][card.code], tags='card_large'))
                colour = list(COLOURS.values())[i]
                self.gems[colour] = self.root.create_image(GEMS_POS[0], GEMS_POS[1]+GEMS_SEP*i, 
                                         image=resources['gems_large'][colour][board.gems[colour]], tags='gem_large')
                if i < len(board.nobles):
                    self.nobles.append(self.root.create_image(NOBL_POS[0], NOBL_POS[1]+NOBL_SEP*i, 
                                            image=resources['nobles_large'][board.nobles[i][0]], tags='noble_large'))                
                self.root.update()
                time.sleep(0.1)
                i+=1
            time.sleep(1)
        
        #Else, iterate over decks like normal.
        else:
            for i in range(3):
                #Update deck counter labels.
                self.root.itemconfigure(self.cntrs[i], text=str(len(board.decks[i])))
                #Update the dealt cards for this deck. 
                for j in range(4):
                    xpos, ypos  = CARD_POS[0]+CARD_SEP[0]*j, CARD_POS[1]+CARD_SEP[1]*i
                    if board.dealt[i][j]: #Generate image only if there is a card present at this position.
                        card = board.dealt[i][j]
                        self.dealt[i][j] = (self.root.create_image(xpos, ypos, 
                                            image=resources['cards_large'][card.colour][card.code], tags='card_large'))
                        if not no_highlighting and not can_buy(agent, board.dealt[i][j]):
                            self.dealt_transparencies[i][j] = (self.root.create_image(xpos, ypos, 
                                            image=resources['card_dull'], tags='card_large'))
            
        #Shared gem stacks.
        i = 0
        for colour in COLOURS.values():
            xpos, ypos = GEMS_POS[0], GEMS_POS[1]+GEMS_SEP*i
            count = board.gems[colour]
            if count: #Draw gem counter only if there are gems in this stack.
                self.gems[colour] = self.root.create_image(xpos, ypos, 
                                         image=resources['gems_large'][colour][count], tags='gem_large')
            i += 1
                
        #Nobles.
        for i in range(len(board.nobles)):
            xpos, ypos = NOBL_POS[0], NOBL_POS[1]+NOBL_SEP*i
            self.nobles.append(self.root.create_image(xpos, ypos, 
                                    image=resources['nobles_large'][board.nobles[i][0]], tags='noble_large'))
        
                
class GUIDisplayer(Displayer):
    def __init__(self, half_scale, delay = 0.1, no_highlighting=False):
        self.delay = delay
        self.no_highlighting = no_highlighting
        # Absolute positions for resources (cards, gems, nobles). All positions align with top-left of assets.
        global s,PLYR_POS,NAME_POS,PGEM_POS,PCRD_POS,PNBL_POS,PCRD_SEP,PLYR_SEP,D_COUNTR, RUNNING, \
                 CARD_POS,CARD_SEP,GEMS_POS,GEMS_SEP,NOBL_POS,PNBL_SEP,NOBL_SEP,CNVS_DIM, ACTN_BOX
        s = 0.5 if half_scale else 1
                    #   x      y   #
        CNVS_DIM = (1920*s,1080*s) #Canvas dimensions.        
        PLYR_POS =   (19*s,  30*s) #First player area.
        NAME_POS =   (26*s,  37*s) #First player name.
        PGEM_POS =   (54*s, 106*s) #First player's first gem stack.
        PCRD_POS =   (54*s, 165*s) #First player's first card stack.
        PNBL_POS =  (366*s,  56*s) #First player's first noble.
        PCRD_SEP =   (49*s,  15*s) #Horizontal and vertical separation between player cards.
        CARD_SEP =  (220*s, 298*s) #Horizontal and vertical separation between available cards.
        CARD_POS =  [783*s, 242*s] #Top left available card.
        D_COUNTR =  [598*s, 210*s] #Top deck counter.
        NOBL_POS = [1825*s, 327*s] #Top available noble.        
        GEMS_POS = [1665*s, 171*s] #Top shared gem stack.
        PLYR_SEP =   257*s         #Vertical separation between player areas.        
        GEMS_SEP =   149*s         #Vertical separation between gem stacks.
        PNBL_SEP =    25*s         #Vertical separation between player nobles (small).
        NOBL_SEP =   110*s         #Vertical separation between board nobles (large).
        ACTN_BOX = (20*s, 543*s)   #Action box position.
        RUNNING  = True
                
    def InitDisplayer(self, runner):
        #Initialise root frame.
        self.root = tkinter.Tk()
        self.root.protocol("WM_DELETE_WINDOW", self.close_window)
        self.root.title("Splendor ------ COMP90054 AI Planning for Autonomy")
        self.root['bg']='black'
        self.root.tk.call('wm', 'iconphoto', self.root._w, tkinter.PhotoImage(file='Splendor/resources/icon.png'))
        self.root.geometry("{}x{}".format(int(CNVS_DIM[0]), int(CNVS_DIM[1])))
        self.maximised = False
        if s==1: #Fullscreen mode only if running full resolution.
            self.root.attributes("-fullscreen", self.maximised)
        self.root.bind("<F11>", self.toggle_fullscreen)
        self.root.bind("<Escape>", self.end_fullscreen)
        
        #Load image resources.
        self.resources = {'background':  tkinter.PhotoImage(file="Splendor/resources/background.png").subsample(int(1/s)),
                          'cards_large': {c:{} for c in COLOURS.values()}, 'cards_small': {c:{} for c in COLOURS.values()},
                          'gems_large':  {c:{} for c in COLOURS.values()}, 'gems_small':  {c:{} for c in COLOURS.values()},
                          'nobles_large':{}, 'nobles_small':{}}
        for card in os.listdir("Splendor/resources/cards_large"):
            colour,code,_ = convert_filename(card)
            self.resources['cards_large'][colour][code] = tkinter.PhotoImage(\
                 file="Splendor/resources/cards_large/{}".format(card)).subsample(int(1/s))
        for card in os.listdir("Splendor/resources/cards_small"):
            colour,code,_ = convert_filename(card)
            self.resources['cards_small'][colour][code] = tkinter.PhotoImage(\
                 file="Splendor/resources/cards_small/{}".format(card)).subsample(int(1/s))
        for gem in os.listdir("Splendor/resources/gems_large"):
            colour,num = convert_filename(gem)
            self.resources['gems_large'][colour][num] = tkinter.PhotoImage(\
                 file="Splendor/resources/gems_large/{}".format(gem)).subsample(int(1/s))
        for gem in os.listdir("Splendor/resources/gems_small"):
            colour,num = convert_filename(gem)
            self.resources['gems_small'][colour][num] = tkinter.PhotoImage(\
                 file="Splendor/resources/gems_small/{}".format(gem)).subsample(int(1/s))
        for nobl in os.listdir("Splendor/resources/nobles_large"):
            _,code,_ = convert_filename(nobl)
            self.resources['nobles_large'][code] = tkinter.PhotoImage(\
                 file="Splendor/resources/nobles_large/{}".format(nobl)).subsample(int(1/s))
        for nobl in os.listdir("Splendor/resources/nobles_small"):
            _,code,_ = convert_filename(nobl)
            self.resources['nobles_small'][code] = tkinter.PhotoImage(\
                 file="Splendor/resources/nobles_small/{}".format(nobl)).subsample(int(1/s))                
        self.resources['card_sleeve'] = tkinter.PhotoImage(file="Splendor/resources/card_sleeve.png").subsample(int(1/s))
        self.resources['card_dull']   = tkinter.PhotoImage(file="Splendor/resources/card_dull.png").subsample(int(1/s))
                
        #Initialise canvas and place background table image.
        self.canvas = tkinter.Canvas(self.root, height=CNVS_DIM[1], width=CNVS_DIM[0])
        self.canvas.pack()
        self.table  = self.canvas.create_image(0, 0, image=self.resources['background'], anchor='nw')

        #Generate agent areas.
        self.agent_areas = []
        for i in range(len(runner.agents_namelist)): 
            area = AgentArea(self.canvas, i, runner.agents_namelist[i])
            self.agent_areas.append(area)
            
        #Generate board area.
        self.board_area = BoardArea(self.canvas)
        
        #Generate action selection area.
        self.action_frame = tkinter.Frame(self.canvas, bg='black')
        self.action_frame.place(x = ACTN_BOX[0], y = ACTN_BOX[1], height = 510*s, width=314*s)
        self.action_instruct = tkinter.StringVar()
        self.action_label = tkinter.Label(self.action_frame, textvariable=self.action_instruct, font=('times', int(14*s)), bg='black', fg='white')
        self.action_label.pack()
        self.xscrollbar1 = tkinter.Scrollbar(self.action_frame, orient=tkinter.HORIZONTAL)
        self.yscrollbar1 = tkinter.Scrollbar(self.action_frame, orient=tkinter.VERTICAL)
        self.action_box = tkinter.Listbox(self.action_frame,name="actions:", selectmode="single", 
                                borderwidth=int(4*s), xscrollcommand=self.xscrollbar1.set, yscrollcommand=self.yscrollbar1.set,
                                font=('times', 12), bg='black', selectbackground='black', fg='white')
        self.xscrollbar1.config(command=self.action_box.xview,troughcolor="white",bg="white")
        self.xscrollbar1.pack(side=tkinter.BOTTOM, fill=tkinter.X)
        self.yscrollbar1.config(command=self.action_box.yview,troughcolor="white",bg="white")
        self.yscrollbar1.pack(side=tkinter.RIGHT, fill=tkinter.Y)
        self.action_box.pack(fill='both', expand=True)
        self.action_box.bind('<<ListboxSelect>>', self.get_selection)
        self.selection = tkinter.IntVar()

        #Generate scoreboard in separate window.
        self.sb_window = tkinter.Toplevel(self.root)
        self.sb_window.title("Splendor ------ Activity Log")
        self.sb_window.tk.call('wm', 'iconphoto', self.sb_window._w, tkinter.PhotoImage(file='Splendor/resources/icon_log.png'))
        self.sb_window.geometry("640x455")
        self.sb_frame = tkinter.Frame(self.sb_window)
        self.sb_frame.pack()
        self.xscrollbar2 = tkinter.Scrollbar(self.sb_frame, orient=tkinter.HORIZONTAL)
        self.yscrollbar2 = tkinter.Scrollbar(self.sb_frame, orient=tkinter.VERTICAL)
        self.move_box = tkinter.Listbox(self.sb_frame,name="actions:", height=37, width=88, selectmode="single", 
                                borderwidth=4, xscrollcommand=self.xscrollbar2.set, yscrollcommand=self.yscrollbar2.set)
        self.xscrollbar2.config(command=self.move_box.xview,troughcolor="white",bg="white")
        self.xscrollbar2.pack(side=tkinter.BOTTOM, fill=tkinter.X)
        self.yscrollbar2.config(command=self.move_box.yview,troughcolor="white",bg="white")
        self.yscrollbar2.pack(side=tkinter.RIGHT, fill=tkinter.Y)
        self.move_box.pack(side=tkinter.LEFT, fill=tkinter.BOTH, expand=1)   
        self.game_state_history=[]
        self.round_num = 0
        self.sb_window.attributes("-topmost", True)
        
    def toggle_fullscreen(self, event=None):
        self.maximised = not self.maximised
        self.root.attributes("-fullscreen", self.maximised)

    def end_fullscreen(self, event=None):
        self.maximised = False
        self.root.attributes("-fullscreen", False)
        
    def close_window(self):
        self.selection.set(0) #Unblock user_input() from waiting on selection.
        self.root.destroy()
        
    def get_selection(self, event):
        w = event.widget
        self.selection.set(w.curselection()[0])
        
    def prime_action_box(self):
        self.selection.set(-1)
        self.root.wait_variable(self.selection)
        self.action_box.delete(0, self.action_box.size())
     
    def user_input(self, actions):       
        def combo_to_str(combo):
            string = ''
            for colour,number in combo.items():
                string += f'_{colour}-{number}'
            return string
                    
        def str_to_combo(string):
            combo = {}
            values = string.split('_')[1:]
            for v in values:
                v = v.split('-')
                combo[v[0]] = int(v[1])
            return combo        
        
        #Organise actions by type.
        actions_organised = defaultdict(list)
        for a in actions:
            actions_organised[a['type']].append(a)
            
        #User selects an available action type:
        self.action_instruct.set('Select action type:')
        types = sorted(list(actions_organised.keys()))
        for t in types:
            t = 'Collect up to 3 different gemstones' if t=='collect_diff' else \
                'Collect 2 identical gemstones' if t=='collect_same' else \
                'Reserve a card from the table' if t=='reserve' else \
                'Buy a card from the table' if t=='buy_available' else \
                'Buy a previously reserved card'
            self.action_box.insert(tkinter.END, t)
        self.prime_action_box()
        selected_type = types[self.selection.get()]
        actions = actions_organised[selected_type]
        
        #If type is buy or reserve, simply print actions, as they will be sparse enough.
        if selected_type in ['buy_available', 'buy_reserve', 'reserve']:
            self.action_instruct.set(f'Select card to {"buy" if "buy" in selected_type else "reserve"}:')
            for a in actions:
                action = a
                if 'buy' in selected_type:
                    a = f'{a["card"]}'
                else:
                    if a['collected_gems']:
                        a = f'{a["card"]}, receiving a wild'
                        if action['returned_gems']:
                            a += f' and returning a {list(action["returned_gems"].keys())[0]} gemstone'
                    else:
                        a = f'{a["card"]}'
                a += ', inviting a noble' if action['noble'] else ''
                self.action_box.insert(tkinter.END, a)
            self.prime_action_box()
            return actions[self.selection.get()]
                
        #If type is collection, ask for collect and return combos separately.
        self.action_instruct.set(f'Select gems to collect:')
        collect_combos = sorted(list(set([combo_to_str(a['collected_gems']) for a in actions])))
        collect_combos = [str_to_combo(c) for c in collect_combos]
        for c in collect_combos:
            self.action_box.insert(tkinter.END, GemsToString(c))
        self.prime_action_box()
        collected_str = combo_to_str(collect_combos[self.selection.get()])

        any_returned = False
        for a in actions:
            if combo_to_str(a['collected_gems'])==collected_str and a['returned_gems']:
                any_returned = True
                break
        if any_returned:
            return_combos = sorted(list(set(combo_to_str(a['returned_gems']) for a in actions 
                                  if combo_to_str(a['collected_gems'])==collected_str)))
            return_combos = [str_to_combo(c) for c in return_combos]            
            self.action_instruct.set(f'Select gems to return:')
            for c in return_combos:
                self.action_box.insert(tkinter.END, GemsToString(c))
            self.prime_action_box()
            returned_str = combo_to_str(return_combos[self.selection.get()])
            for a in actions:
                if combo_to_str(a['collected_gems'])==collected_str and combo_to_str(a['returned_gems'])==returned_str:
                    return a
        else:
            for a in actions:
                if combo_to_str(a['collected_gems'])==collected_str:
                    return a
        
        
    def _InsertState(self, text, game_state):
        text = text.replace("\n ","")
        self.game_state_history.append(copy.deepcopy(game_state))
        self.move_box.insert(tkinter.END,text)
        self.move_box.see(tkinter.END)
        self.move_box.selection_clear(0, last=None)
    
    #Rebuild canvas images.
    def _DisplayState(self, game_state):
        #Destroy select canvas text and images.
        self.canvas.delete('card_small')
        self.canvas.delete('gem_small')
        self.canvas.delete('counter')
        self.canvas.delete('card_large')
        self.canvas.delete('gem_large')
        self.canvas.delete('noble_large')
        self.canvas.delete('noble_small')
        
        #Update displayed areas (agents and board contents).
        self.board_area.update(game_state, self.resources, self.no_highlighting)
        for agent,area in zip(game_state.agents,self.agent_areas):
            area.update(agent, self.resources)        
        self.canvas.update()

    def ExcuteAction(self,player_id, action, game_state):
        self._InsertState(ActionToString(player_id, action), game_state)
        self._DisplayState(game_state)
        time.sleep(self.delay)

    def TimeOutWarning(self,runner,id):
        self._InsertState("Agent {} time out, {} out of {}. Choosing random action instead."\
                          .format(id, runner.warnings[id],runner.warning_limit),runner.game_rule.current_game_state)
        if id == 0:
            self.move_box.itemconfig(tkinter.END, {'bg':'red','fg':'blue'})
        else:
            self.move_box.itemconfig(tkinter.END, {'bg':'blue','fg':'yellow'})
        pass
        
    def EndGame(self,game_state,scores):
        self._InsertState("--------------End of game-------------",game_state)
        for i,plr_state in enumerate(game_state.agents):
            self._InsertState("Final score for Agent {}: {}".format(i,plr_state.score),game_state)
        
        self.focus = None
        def OnHistorySelect(event):
            w = event.widget
            self.focus = int(w.curselection()[0])
            if self.focus < len(self.game_state_history):
                self._DisplayState(self.game_state_history[self.focus])
        def OnHistoryAction(event):
            if event.keysym == "Up":
                if self.focus>0:
                    self.move_box.select_clear(self.focus)
                    self.focus -=1
                    self.move_box.select_set(self.focus)
                    if self.focus < len(self.game_state_history):
                        self._DisplayState(self.game_state_history[self.focus])
            if event.keysym == "Down":
                if self.focus<len(self.game_state_history)-1:
                    self.move_box.select_clear(self.focus)
                    self.focus +=1
                    self.move_box.select_set(self.focus)
                    self._DisplayState(self.game_state_history[self.focus])

        self.move_box.bind('<<ListboxSelect>>', OnHistorySelect)
        self.move_box.bind('<Up>', OnHistoryAction)
        self.move_box.bind('<Down>', OnHistoryAction)
    
        self.root.mainloop()
        pass    


class TextDisplayer(Displayer):
    def __init__(self):
        print ("--------------------------------------------------------------------")
        return

    def InitDisplayer(self,runner):
        print ("------------------------GAME STARTED--------------------------------")
        # self._DisplayState(runner.)
        pass

    def user_input(self, actions):
        action_dict = dict()
        counter = 0
        for action in actions:
            action_dict[counter] = action
            print("%d: %s"%(counter,action))
            counter += 1
        try:
            # Prompt the user for input
            user_input = input("please input your choose between 0 and %d: "%(counter-1))
            # Attempt to convert the input to an integer
            user_int = int(user_input)
        except ValueError:
            # Handle the error if the input is not a valid integer
            print("That's not an integer. Please try again.")
        return action_dict[user_int]


    def StartRound(self,game_state):
        pass   

    def _DisplayState(self, game_state): 
        print ("------------------------GAME STATE----------------------------------")
        print(game_state)
        print ("--------------------------------------------------------------------")
        pass

    def ExcuteAction(self,i,move, game_state):
        player_state = game_state.agents[i]
        print("\nAgent {} has chosen the following move:".format(i))
        print(ActionToString(i, move))
        print("\n")
        # print("The new agent state is:")
        # print(AgentToString(i, player_state))
        print ("------------------------State After Action----------------------------------")
        self._DisplayState(game_state)
        
        
    def TimeOutWarning(self,runner,id):
        print ("Agent {} Time Out, {} out of {}.".format(id,runner.warnings[id],runner.warning_limit))

    def EndGame(self,game_state,scores):
        print("GAME HAS ENDED")
        print ("--------------------------------------------------------------------")
        for plr_state in game_state.agents:
            print ("Score for Agent {}: {}".format(plr_state.id,plr_state.score))

# END FILE -----------------------------------------------------------------------------------------------------------#
