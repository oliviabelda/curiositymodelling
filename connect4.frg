#lang forge/bsl "cm" "qdezia"

//Connect 4
abstract sig Player {}
one sig Red, Blue extends Player {}

//state - board (6 vertical 7 horizontal)
sig State {
  next: lone State,
  board: pfunc Int -> Int -> Player
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
    all r, c: Int | {
      r > 0 => {
        some s1: State | {
          (s != s1) 
            => s1.board[subtract[r,1]][c] = Red or s1.board[subtract[r,1]][c] = Blue //TEST LOGIC
        }
      } 
    }
  }
}

//initial state - nothing on board
pred start[s: State] {
  all r, c: Int | {
    no s.board[r][c]
  }
}

//red and blues turn

pred blueTurn[s: State] {
  #{r, c: Int | s.board[r][c] = Red} =
  #{r, c: Int | s.board[r][c] = Blue}
}

pred redTurn[s: State] {
  #{r, c: Int | s.board[r][c] = Blue} =
  add[#{r, c: Int | s.board[r][c] = Red}, 1]
}

//move predicate
--check for empty space, is it your turn
pred move[pre: State, post: State, p: player, r: Int, c: Int] {
  // GUARD
  no pre.board[r][c]
  p = Red implies redTurn[pre]
  p = Blue implies blueTurn[pre]
  // ACTION
  all r1, c1: Int | {
    (r = r1 and c = c1) => {
      //move p
      post.board[r1][c1] = p
    } else {
      //no change
      post.board[r1][c1] = pre.board[r1][c1]
    }
  }
}

//winning! -> four in a row, horizontal, vertical, diagonal

//cheating (not your turn to play)
pred cheat[s: State] {
  not redTurn[s]
  not blueTurn[s]
}

//game is done
pred gameOver[s: State] {
  // some p: Player | 
  // winner[s, p] //TODO: need to make winner pred
}

//doNothing -> someone has won but no one can play
pred wait[pre: State, post: State] {
    //GUARD
    gameOver[pre]
    //ACTION
    all r, c: Int | {
      pre.board[r][c] = post.board[r][c] //TEST THIS LOGIC
    }
}

//traces
-- start init state
-- every move is valid
-- do nothing when wining
pred traces {
  some init, final: State {
        -- constraints on init state
        start[init]
        no s: State | next[s] = init

        -- constraints on final state
        no s: State | next[final] = s

        -- link init to final state via next
        reachable[final, init, next]

        -- valid transitions
        all s: State | s != final => {
          some r, c: Int, p: Player | {
            move[s, next[s], p, r, c] 
          }
          or
          wait[s, next[s]]      
        } 
    }
}


//run
--wellformed
--traces
-- for exactly  _ states, for {next is linear}
run {
  wellformed
  traces
} for exactly 5 State for {next is linear}


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