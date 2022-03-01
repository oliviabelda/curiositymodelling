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

//initial state - nothing on board
pred start[s: State] {
  all r, c: Int | {
    no s.board[r][c]
  }
}

//move predicate
--check for empty space, is it your turn
pred move[pre: State, post: State, p: player, r: Int, c: Int] {
  // GUARD
  no pre.board[r][c]
  // ACTION
  all r2, c2: Int | {    
    (r = r2 and c = c2) 
      =>   post.board[r2][c2] = p //move p
      else post.board[r2][c2] = pre.board[r2][c2] //make sure rest of board is same
  }
}

//winning! -> four in a row, horizontal, vertical, diagonal

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

        winner[final, Blue]
        //this is winning state

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