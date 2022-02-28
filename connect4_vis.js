const d3 = require('d3')
d3.selectAll("svg > *").remove();

function printValue(row, col, yoffset, value) {
  d3.select(svg)
    .append("text")
    .style("fill", "black")
    .attr("x", (col+1)*10)
    .attr("y", (row+1)*14 + yoffset)
    .text(value);
}

function printState(stateAtom, yoffset) {
  for (r = 0; r <= 5; r++) {
    for (c = 0; c <= 6; c++) {
      printValue(r, c, yoffset,
                 stateAtom.board[r][c]
                 .toString().substring(0,1))  
    }
  }
  
  d3.select(svg)
    .append('rect')
    .attr('x', 5)
    .attr('y', yoffset+1)
    .attr('width', 120)
    .attr('height', 90)
    .attr('stroke-width', 2)
    .attr('stroke', 'black')
    .attr('fill', 'transparent');
}


var offset = 0
for(b = 0; b <= 10; b++) {  
  if(State.atom("State"+b) != null)
    printState(State.atom("State"+b), offset)  
  offset = offset + 95
}