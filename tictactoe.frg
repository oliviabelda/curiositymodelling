#lang forge/bsl

abstract sig Player {}
one sig X, O extends Player {}

-- In every state of the game, each square has 0 or 1 marks.
sig State {
  board: pfunc Int -> Int -> Player
}

pred wellformed {
  all s: State | {
    all row, col: Int | {
      (row < 0 or row > 2 or col < 0 or col > 2) 
        implies no s.board[row][col]    
    }
  }
}

pred starting[s: State] {
  all row, col: Int | 
    no s.board[row][col]
}

// MOVE
pred move[pre: State, row: Int, col: Int, p: Player, post: State] {
  no pre.board[row][col] -- nobody's moved there
  p = X implies XTurn[pre]  
  p = O implies OTurn[pre]  
  all row2, col2: Int | {    
    (row = row2 and col = col2) 
      =>   post.board[row2][col2] = p
      else post.board[row2][col2] = pre.board[row2][col2]     
  }
}

pred XTurn[s: State] {
  #{row, col: Int | s.board[row][col] = X} =
  #{row, col: Int | s.board[row][col] = O}
}

pred OTurn[s: State] {
  #{row, col: Int | s.board[row][col] = X} =
  add[#{row, col: Int | s.board[row][col] = O}, 1]
}


// WIN
pred winRow[s: State, p: Player] {
  -- note we cannot use `all` here because there are more Ints  
  some row: Int | {
    s.board[row][0] = p
    s.board[row][1] = p
    s.board[row][2] = p
  }
}

pred winCol[s: State, p: Player] {
  some column: Int | {
    s.board[0][column] = p
    s.board[1][column] = p
    s.board[2][column] = p
  }      
}

pred winner[s: State, p: Player] {
  winRow[s, p]
  or
  winCol[s, p]
  or 
  {
    s.board[0][0] = p
    s.board[1][1] = p
    s.board[2][2] = p
  }
  or
  {
    s.board[0][2] = p
    s.board[1][1] = p
    s.board[2][0] = p
  }  
}

// CHEATING
pred cheating[s: State] {
  not XTurn[s]
  not OTurn[s]
}

//DO NOTHING

gameOver[s: State] {
  some p: Player | winner[s, p]
}

pred doNothing[pre: State, post: State] {
    gameOver[pre] -- guard of the transition
    pre.board = post.board -- effect of the transition
}

// TRACE
pred traces {
    -- The trace starts with an initial state
    starting[Game.initialState]
    no sprev: State | sprev.next = Game.initialState
    -- Every transition is a valid move
    all s: State | some Game.next[s] implies {
      some row, col: Int, p: Player | {
        move[s, row, col, p, Game.next[s]] 
      }
      or
      doNothing[s, Game.next[s]]      
    } 
}

pred traces {
    -- The trace starts with an initial state
    starting[Game.initialState]
    no sprev: State | Game.next[sprev] = Game.initialState
    -- Every transition is a valid move
    all s: State | some Game.next[s] implies {
      some row, col: Int, p: Player |
        move[s, row, col, p, Game.next[s]]
    }
}

run {
  wellformed
  traces
} for exactly 10 State for {next is linear}
