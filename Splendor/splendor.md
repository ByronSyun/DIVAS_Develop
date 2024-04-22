# SPLENDOR : A Competitive Game Environment for COMP90054, Semester 2, 2021
---------------------------------------------------------------------------

### Table of contents

  * [Introduction](#introduction)
     * [Key files to read:](#key-files-to-read)
     * [Other supporting files (do not modify):](#other-supporting-files-do-not-modify)
  * [Rules of SPLENDOR](#rules-of-splendor)
     * [Layout:](#layout)
     * [Scoring:](#scoring)
     * [Observations:](#observations)
     * [Winning:](#winning)
     * [Computation Time:](#computation-time)
  * [Getting Started](#getting-started)
     * [Restrictions:](#restrictions)
     * [Warning:](#warning)
     * [Ranking](#ranking)
  
## Introduction

For COMP90054 this semester, you will be competing against agent teams in SPLENDOR, a strategic board game.
There are many files in this package, most of them implementing the game itself. The **only** file that you should work on is `myTeam.py` and this will be the only file that you will submit.

### Key files to read:

* `splendor_model.py`: The model file that generates game states and valid actions. Start here to understand how everything is structured, and what is passed to your agent. In particular, ```getLegalActions()``` will provide a concise rundown of what a turn consists of, and how that is encapsulated in an action.
<!-- * `agents/generic/example_bfs.py`: Example code that defines the skeleton of a basic planning agent. You aren't required to use any of the filled in code, but your agent submitted in `myTeam.py` will at least need to be initialised with __init__(self, _id), and implement SelectAction(self, actions, rootstate) to return a valid action when asked. -->

### Other supporting files (do not modify):

* `general_game_runner.py`: Support code to setup and run games. See the loadParameter() function for details on acceptable arguments.
* `splendor_utils.py`: Holds the full lists of cards and nobles used in the game, along with their gemstone costs and point values.

Of course, you are welcome to read and use any and all code supplied. For instance, if your agent is trying to simulate future gamestates, it might want to appropriate code from `splendor_model.py` in order to do so.


## Rules of SPLENDOR:

### Layout: 

Upon loading SPLENDOR, both Table and Score windows will appear. The Score window will remain in front, tracking each agent's move. At the end of the game, you are able to click on actions in this window and watch the state reload in Table accordingly.

The Table window will show each agent's collected gemstones and cards (on the left), the three tiers of cards being dealt (centre), and available gemstones and nobles (right).

In the bottom left of the screen, there is also a black selection box. If the game is running in interactive mode, this box will list all actions available to the Citrine agent. Clicking on these actions will allow you to play against the Ruby agent.

### Scoring:

Please read the official rules here: https://cdn.1j1ju.com/medias/7f/91/ba-splendor-rulebook.pdf

### Changes

We have made a few **alterations** to these rules for computational reasons:
* A golden token is considered as a special gem with the colour of yellow.

* Reserve action can only reserve cards from the table for simplicity.

* Cards are replaced at the end of each turn, not immediately. This functionally doesn't change anything aside from a rare edge case: if an agent, possessing 10 gems, reserves a card along with a wild (yellow gem), they need to return 1 gem of their choice by the end of their turn. Their choice may benefit from knowledge of the newly revealed card. I didn't deem this a substantial enough mechanic to warrant inclusion at the cost of added complexity and computation time.

* The rules state that if you are either approaching or have reached the gem limit (10), you are still allowed to take up to 3 gems as available, but you need to discard down to the limit by the end of your turn. However, this is clunky if implemented as-is, as it means you can return some or all of the gems you picked up. 
Instead, when generating actions, the game engine will not allow the same colour gem to appear in the collected\_gems and returned\_gems fields. Likewise, if you exceed 10 by reserving a card and receiving a wild, you need to return a non-wild gem.
To be specific about this:
   * If you have less than 8 gems, the action with type "collect_diff" must collect 3 gems if there exists enough gems from different colours.
   * If you have 8 gems, your are allow to:
      * only collect 2 gems if there exists enough gems from different colours.
      * collect 3 gems if there exists enough gems from different colours and return a gem that is different from those just collected. (if you want to return the gem with the same colour, then you should only collect 2 gems)
   * If you have 9, your are allow to:
      * collect 3 gems and return 2 gems with different colour than those collected.
      * collect 2 gems and return 1 gems with different colour than those collected.
      * collect 1 gems.
   * If you have 10, your are allow to:
      * collect 3 gems and return 3 gems with different colour than those collected.
      * collect 3 gems and return 2 gems with different colour than those collected.
      * collect 3 gems and return 1 gems with different colour than those collected. 
   * The returned gems:
      * must not contain any gem that has the same colour as those collected in the same action.
      * can contain same colour gems.
      * can contain any amount of yellow gem.

* Agents are limited to 7 cards per colour for the purposes of a clean interface. This is not expected to affect gameplay, as there is essentially zero strategic reason to exceed this limit. The interface ensures this constrain by filtering out the buying action for the colour if the player already have 7 cards of that colour.

* Agents aren't permitted to pay with a yellow gem if they can instead cover the cost with regular gems. Although there may be rare strategic instances where holding on to coloured gems is beneficial (by virtue of shorting players from resources), in this implementation, this edge case is not worth added complexity.

### Observations:

SPLENDOR is an imperfect information game. While the board state is almost fully observable, including all your opponents' gems and cards, the decks are face-down. You may look at the state's deck variable to glimpse possible upcoming cards (which may be useful for your own simulations), but the game will shuffle decks before each deal, so there's no guarantee of which card will appear next.

### Winning:

The game proceeds round by round. At the end of a round, if any agent has achieved at least 15 points, the game will end, and victory will go to the agent with the most points. Points are tie-broken on the number of cards played; if both agents receive the same points, but one has done so with fewer cards, they will be victorious. If agents are still tied, they will both be victorious.

### Computation Time:

Each agent has 1 second to return each action. Each move which does not return within one second will incur a warning. After three warnings, or any single move taking more than 3 seconds, the game is forfeit. 
There will be an initial start-up allowance of 15 seconds. Your agent will need to keep track of turns if it is to make use of this allowance. 


## Getting Started

**Make sure the version of Python used is >= 3.8, and that you have installed func-timeout (e.g. ```pip install func-timeout```)**

By default, you can run a game against two random agents with the following:

```bash
$ python general_game_runner.py -g Splendor
```

To enter interactive mode, use the argument --interactive. In the game, the Citrine agent will be titled "Human", and you will be able to select actions each turn. This works with both GUI and text displayer.
```bash
$ python general_game_runner.py -g Splendor --interactive
```

To specify the running agent, the option `-a` or `--agents` is needed, follows two agent python files separated by ','. For example:
```bash
$ python general_game_runner.py -g Splendor-a agents.generic.random,agents.generic.random
```

If the game renders at a resolution that doesn't fit your screen, try using the argument --half-scale. The game runs in windowed mode by default, but can be toggled to fullscreen with F11.

### Options:
The options are listed (including but not limited to) as follows:
* `-t`: text displayer, use when you do not want GUI
* `-s`: save the replay
* `-l`: save the log
* `-p`: enable printing
* `--interactive`: enable interactive model. (You can choose your action from the left bottom black list frame)

### Restrictions: 

You are free to use any techniques you want, but will need to respect the provided APIs to have a valid submission. Agents which compute during the opponent's turn will be disqualified. In particular, any form of multi-threading is disallowed, because we have found it very hard to ensure that no computation takes place on the opponent's turn.

### Warning: 

If one of your agents produces any stdout/stderr output during its games in the any tournament (preliminary or final), that output will be included in the contest results posted on the website. Additionally, in some cases a stack trace may be shown among this output in the event that one of your agents throws an exception. You should design your code in such a way that this does not expose any information that you wish to keep confidential.

### Ranking: 

Rankings are determined according to the number of points received in nightly round-robin tournaments, where a win is worth 3 points, a tie is worth 1 point, and losses are worth 0 (Ties are not worth very much to discourage stalemates). Extra credit will be awarded according to the final competition, but participating early in the pre-competitions will increase your learning and feedback. 
<!-- In addition, staff members have entered the tournament with their own devious agents, seeking fame and glory. These agents have team names beginning with `Staff-`. -->
