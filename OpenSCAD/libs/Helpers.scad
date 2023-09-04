use <dotSCAD/src/util/find_index.scad>

function int(bool) = bool ? 1 : 0;

module Select(choices, choice) {  
  let(i=find_index(choices,  function(e) e == choice))
  children(i);
}

module UnionOrDiff(union) {
  union() {
    difference() {
      children(0);
      if(!union) {
        children(1);
      }
    }
    if(union) {
      children(1);
    }
  }
}

module __Demo() {
  UnionOrDiff(union = true) {
    sphere(5);
    cube(5);
  }
  translate([10,0,0])
  UnionOrDiff(union = false) {
    sphere(5);
    cube(5);
  }
  translate([20,0,0])
  Select(["red","green","blue"], "green") {
    color("red")
    sphere(2.5);    
    color("green")
    sphere(2.5);
    color("blue")    
    sphere(2.5);
  }
}
%__Demo();