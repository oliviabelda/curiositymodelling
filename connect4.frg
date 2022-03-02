#lang forge/bsl "cm" "qdezia"

//Connect 4
abstract sig Player {}
one sig Red, Blue extends Player {}

//state - board (6 vertical 7 horizontal)
sig State {
  next: lone State,
  board: pfunc Int -> Int -> Player,
  player: one Player
}

//wellformed
--check for valid place to put piece (ex. gravity)
-- either there is a piece under, or it is the first row
pred wellformed {
  all s: State | {
    all r, c: Int | {
      (r < 0 or r > 5 or c < 0 or c > 6) 
        implies no s.board[r][c]   
    }
  }

  // gravity - either first row or have piece below
  all s: State | {
    all r, c: Int | r != 5 => {
      (s.board[r][c] = Red or s.board[r][c] = Blue) => {
        s.board[add[r,1]][c] = Red or s.board[add[r,1]][c] = Blue} //TEST LOGIC 
    }
  }
}

example validWellFormed is wellformed for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Red + 
      `S0 -> 4 -> 1 -> Blue +
      `S0 -> 3 -> 1 -> Blue
  player = `S0 -> Blue
}

example invalidWellFormedGravity is not wellformed for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Red + 
      `S0 -> 4 -> 1 -> Blue +
      `S0 -> 4 -> 3 -> Blue
  player = `S0 -> Blue
}

example invalidWellFormedOutofBounds is not wellformed for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Red + 
      `S0 -> 4 -> 1 -> Blue +
      `S0 -> 5 -> 7 -> Blue
  player = `S0 -> Blue
}

//initial state - nothing on board
pred start[s: State] {
  all r, c: Int | {
    no s.board[r][c]
  }
}

example invalidStart is not {some s: State | start[s]} for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Blue
  player = `S0 -> Blue
}

//move predicate
--check for empty space, is it your turn
pred move[pre: State, post: State, p: Player, r: Int, c: Int] {
  // GUARD
  no pre.board[r][c]
  // ACTION
  all r2, c2: Int | {    
    (r = r2 and c = c2) 
      =>   post.board[r2][c2] = p //move p
      else post.board[r2][c2] = pre.board[r2][c2] //make sure rest of board is same
  }
}

example validMove is {some pre, post: State, p: Player, r, c: Int | move[pre, post, p, r, c]} for {
  State = `S0 + `S1 -- only two states for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Blue + 
      `S1 -> 5 -> 1 -> Red +
      `S1 -> 5 -> 2 -> Blue +
      `S1 -> 5 -> 5 -> Red
  next = `S0 -> `S1
  player = `S0 -> Blue +
      `S1 -> Red
}

example invalidMoveNoMove is not {some pre, post: State, p: Player, r, c: Int | move[pre, post, p, r, c]} for {
  State = `S0 + `S1 -- only two states for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
     `S0 -> 5 -> 2 -> Blue + 
      `S1 -> 5 -> 1 -> Red +
      `S1 -> 5 -> 2 -> Blue
  next = `S0 -> `S1
  player = `S0 -> Blue +
      `S1 -> Red
}

example invalidMoveTooManyMoves is not {some pre, post: State, p: Player, r, c: Int | move[pre, post, p, r, c]} for {
  State = `S0 + `S1 -- only two states for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Blue + 
      `S1 -> 5 -> 1 -> Red +
      `S1 -> 5 -> 2 -> Blue +
      `S1 -> 5 -> 5 -> Red +
      `S1 -> 4 -> 2 -> Blue
  next = `S0 -> `S1
  player = `S0 -> Blue +
      `S1 -> Red
}

// *** Do not include this example, alternating players is handled in traces not move predicate
// example invalidMoveSamePlayer is not {some pre, post: State, p: Player, r, c: Int | move[pre, post, p, r, c]} for {
//     State = `S0 + `S1 -- only two states for simplicity
//     Red = `Red
//     Blue = `Blue
//     Player = Red + Blue
//     board = `S0 -> 5 -> 1 -> Red + 
//         `S0 -> 5 -> 2 -> Blue + 
//         `S1 -> 5 -> 1 -> Red +
//         `S1 -> 5 -> 2 -> Blue +
//         `S1 -> 5 -> 5 -> Blue
//     next = `S0 -> `S1
//     player = `S0 -> Blue +
//         `S1 -> Blue
// }

//winning! -> four in a row, horizontal, vertical, diagonal
pred winRow[s: State, p: Player, row: Int, col: Int] {
  s.board[row][col] = p
  s.board[row][add[col, 1]] = p
  s.board[row][add[col, 2]] = p
  s.board[row][add[col, 3]] = p
}

pred winCol[s: State, p: Player, row: Int, col: Int] {
  s.board[row][col] = p
  s.board[add[row, 1]][col] = p
  s.board[add[row, 2]][col] = p
  s.board[add[row, 3]][col] = p  
}

pred winDownDiagonal[s: State, p: Player, row: Int, col: Int] {
  s.board[row][col] = p
  s.board[add[row, 1]][add[col, 1]] = p
  s.board[add[row, 2]][add[col, 2]] = p
  s.board[add[row, 3]][add[col, 3]] = p
}

pred winUpDiagonal[s: State, p: Player, row: Int, col: Int] {
  s.board[row][col] = p
  s.board[subtract[row, 1]][add[col, 1]] = p
  s.board[subtract[row, 2]][add[col, 2]] = p
  s.board[subtract[row, 3]][add[col, 3]] = p  
}

pred winner[s: State, p: Player] {
  some row, col: Int | {
    winRow[s, p, row, col]
    or
    winCol[s, p, row, col]
    or
    winUpDiagonal[s, p, row, col]
    or
    winDownDiagonal[s, p, row, col]
  }
}

example validWinnerWinRow is {some s: State, p: Player | winner[s, p]} for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Red +
      `S0 -> 5 -> 3 -> Red +
      `S0 -> 5 -> 4 -> Red +
      `S0 -> 4 -> 1 -> Blue + 
      `S0 -> 4 -> 2 -> Blue
  player = `S0 -> Blue
}

example validWinnerWinColumn is {some s: State, p: Player | winner[s, p]} for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 4 -> 1 -> Red +
      `S0 -> 3 -> 1 -> Red +
      `S0 -> 2 -> 1 -> Red +
      `S0 -> 1 -> 1 -> Blue + 
      `S0 -> 5 -> 2 -> Blue
  player = `S0 -> Blue
}

example validWinnerWinDiagonal is {some s: State, p: Player | winner[s, p]} for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 2 -> 1 -> Blue + 
      `S0 -> 3 -> 2 -> Blue +
      `S0 -> 4 -> 3 -> Blue +
      `S0 -> 5 -> 4 -> Blue +
      `S0 -> 3 -> 1 -> Red + 
      `S0 -> 4 -> 2 -> Red +
      `S0 -> 5 -> 3 -> Red + 
      `S0 -> 4 -> 1 -> Red +
      `S0 -> 5 -> 2 -> Red + 
      `S0 -> 5 -> 1 -> Red
  player = `S0 -> Red
}

example validWinnerNoWin is {no s: State, p: Player | winner[s, p]} for {
  State = `S0 -- a trace with one state for simplicity
  Red = `Red
  Blue = `Blue
  Player = Red + Blue
  board = `S0 -> 5 -> 1 -> Red + 
      `S0 -> 5 -> 2 -> Red +
      `S0 -> 5 -> 3 -> Red +
      `S0 -> 5 -> 4 -> Blue +
      `S0 -> 4 -> 1 -> Blue + 
      `S0 -> 4 -> 2 -> Blue
}

//traces
-- start init state
-- every move is valid
-- do nothing when wining
pred traces {
  some init, final: State {
        -- constraints on init state
        // start[init]
        // no s: State | next[s] = init

        -- alternating players
        no s: State | s.player = next[s].player

        -- constraints on final state
        no s: State | next[final] = s

        //this is winning state
        winner[final, Blue] or winner[final, Red]

        all s: State | s != final => {
          not winner[s, Blue]
          not winner[s, Red]
        }

        -- link init to final state via next
        reachable[final, init, next]

        -- valid transitions
        all s: State | s != final => {
          
          some r, c: Int, p: Player | {
            move[s, next[s], s.player, r, c]
          }
        } //only 4 states to winning
    }
}


//run
--wellformed
--traces
-- for exactly  _ states, for {next is linear}
run {
  wellformed
  traces
} for {next is linear}


test expect {
  bounds: {
    wellformed
    some s: State, r, c: Int | {
      r > 5 or r < 0
      c > 6 or c < 0
      no s.board[r][c]
    }
  } is sat
}
