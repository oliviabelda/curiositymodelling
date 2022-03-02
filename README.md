# Connect4

### **What are you trying to model? Include a brief description that would give someone unfamiliar with the topic a basic understanding of your goal.**
<br>
The game we are modelling is called Connect4. It is a 7by6 vertical board where alternating player (Blue and Red) drop their pieces. The objective is to get 4 pieces in a row. Be it horizontal, vertical or diagonal. 

<br>

### **Give an overview of your model design choices, what checks or run statements you wrote, and what we should expect to see from an instance produced by Sterling. How should we look at and interpret an instance created by your spec?**
<br>
This model is similar to Tic-Tac-Toe, but with two added complexities. First, the board is larger and so the winning predicate can't be hard-coded (for example in lecture, we hard coded the diagonal winning predicate for tictactoe). Since you have to get 4 pieces in a row (and the board is larger than a 4by4), we decided to make a "search" through the board to catch any winning moves. The second added complexity is the concept of gravity. In this game, pieces are dropped on top of each other until we run out of vertical space, or there is a winning move. We decided to add this constraint on the wellformed predicate that now ensures the size of the board, and that gravity is maintained (basically the piece is either in the first row, or there is a piece under it)

Our initial idea was to have model multiple possible game for Connect4. I.E. have a sig Game such that each games has their set of 42 states such that you either win on the last state, or you win before and a doNothing predicate ensures no other move is made. We quickly realized that it would be incredibly taxing and time consuming for Sterling to run 42 states with for multiple games. We instead decided to simplify it to have one game and each state is linear to the next one (just like in forge2 homework) and not have the `sig Game`. With this addition, we didn't need the `doNothing` predicate by ensuring that the last state will always be a winning state, and that no state before the last one can be a winning one. In the run statement then, you can now choose the number of states before winning, up to 43 (stating with an empty board and winning at the full board), which take about 4 minutes to show up in Sterling. This means that there will be an error if there are more than 43 states as the move predicate wont be satisfied because the board becomes full.

We also edited the visualizer fom tictactoe to fit out game. We change fit more states on the Sterling page, the pieces are colored and the board is slightly bigger. Make sure to run on `svg` mode. When running the script, you will be able to see that all pieces follow the gravity constraint, that the players are alternating, that there is no winning move before the last state, that the bounds of the board are respected and that the states are linear.


//////////ADD TESTS/EXAMPLES/RUN STATEMENTS

<br>

### **At a high level, what do each of your sigs and preds represent in the context of the model? Justify the purpose for their existence and how they fit together.**
<br>

`Player` is ann abstract sig that will be extended by `Red` and `Blue` which are the two opponents playing this game.

`State` contains `next` field, which maintains the linearity of the state such that every state is reachable, the final state has no next and the initial state is next of any other state. It also contains the `pfunc board` which holds all the pieces to the board and the Player to whom those piece belong to. Finally, there is also a field for `player` which is used to define who's turn it is. In the traces predicate, the alternating player constraint is enforced.

<br>

### In addition to the README be sure to document your model.w
