#lang forge/bsl “cm” “qdezia”


//Connect 4
abstract sig Player{}
one sig Blue, Red extends Player{}

//state - board (6 vertical 6 horizontal)
sig State {
  board: pfunc Int -> Int -> Player
}

//wellformed
--check for valid place to put coin (ex. gravity)
-- either there is a coin under, or it is the first row
pred wellformed {
  all s : State | {
    all r, c: Int | {
      (r < 0 or r > 5 or c < 0 or col > 2)
        implies no s.board[r][c]
    }
  }
  //gravity
}

//initial state (starting)

//move predicate
--check for empty space, is it your turn


//red and blues turn

//winning! -> four in a row, horizontal, vertical, diagonal

//cheating (not your turn to play)

//traces
-- start init state
-- every move is valid
-- do nothing when wining

//doNothing -> someone has won but no one can play

//run
--wellformed
--traces
-- for exactly  _ states, for {next is linear}

//test!