#lang forge/bsl "cm" "qdezia"

//Connect 4
abstract sig Player {}
one sig Red, Blue extends Player {}

//state - board (6 vertical 7 horizontal)
sig State {
  board: pfunc Int -> Int -> Player
}

//the game
one sig Game {
  initState: one State,
  next: pfunc State -> State //next is linear!
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
  // all s: State | {
  //   all r, c: Int | {
  //     s.board[r][c] => {
  //       (r = 0) or (some s1: State | s != s1 => s1.board[subtract[r,1]][c])
  //     } 
  //   }
  // }
}

//initial state - nothing on board
pred init[s: State] {
  all r, c: Int | {
    no s.board[r][c]
  }
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


//red and blues turn

pred blueTurn[s: State] {
  #{r, c: Int | s.board[r][c] = Red} =
  #{r, c: Int | s.board[r][c] = Blue}
}

pred redTurn[s: State] {
  #{row, col: Int | s.board[row][col] = Blue} =
  add[#{row, col: Int | s.board[row][col] = Red}, 1]
}

//winning! -> four in a row, horizontal, vertical, diagonal

//cheating (not your turn to play)
pred cheat[s: State] {
  not redTurn[s]
  not blueTurn[s]
}

//traces
-- start init state
-- every move is valid
-- do nothing when wining
pred traces {
  init[Game.initState]
  //make sure init has no previous state
  no prev: State | prev.next = Game.initState
  //every transition is valid
  all s: State | some Game.next[s] implies {
    some r, c: Int, p: Player | {
      move[s, r, c, p, Game.next[s]] 
    }
    or
    wait[s, Game.next[s]]      
  } 
}

//doNothing -> someone has won but no one can play
pred wait[pre: State, post: State] {
    //GUARD
    gameOver[pre]
    //ACTION
    pre.board = post.board
}

//game is done
pred gameOver[s: State] {
  // some p: Player | 
  // winner[s, p] //TODO: need to make winner pred
}

//run
--wellformed
--traces
-- for exactly  _ states, for {next is linear}
// run {
//   wellformed
// } for exactly 42 State 
// for {next is linear}

// //test!
// test expect {
//   noCheatingAtStart: {
//     wellformed
//     some s: State | s.board[1][2]
//   } is unsat
// }

run {
  wellformed
  // traces
} for exactly 10 State for {next is linear}


// test expect {
//   bounds: {
//     wellformed
//     some s: State, r, c: Int | {
//       r > 5 or r < 0
//       c > 6 or c < 0
//       s.board[r][c]
//     }
//   } is unsat
// }