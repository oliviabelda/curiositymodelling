const d3 = require('d3')
d3.selectAll("svg > *").remove();

function printValue(row, col, xoffset, yoffset, value) {
  
  var color = "red"
  if (value == "B")
    color = "blue"
  d3.select(svg)
    .append("text")
    .style("fill", color)
    .attr("x", (col+1)*10 + xoffset)
    .attr("y", (row+1.2)*14 + yoffset)
    .text(value);
}

function printState(stateAtom, xoffset, yoffset) {
  for (r = 0; r <= 5; r++) {
    for (c = 0; c <= 6; c++) {
      printValue(r, c, xoffset, yoffset,
                 stateAtom.board[r][c]
                 .toString().substring(0,1))  
    }
  }
  
  d3.select(svg)
    .append('rect')
    .attr('x', xoffset+5)
    .attr('y', yoffset+1)
    .attr('width', 80)
    .attr('height', 90)
    .attr('stroke-width', 2)
    .attr('stroke', 'black')
    .attr('fill', 'transparent');
}

var col = 0
var offset = 0
for(b = 0; b <= 42; b++) {
  if(State.atom("State"+b) != null)
    printState(State.atom("State"+b), col*85 ,offset)
  if (col == 4) {
    col = 0
    offset = offset + 95
  } else {col = col + 1}  
}