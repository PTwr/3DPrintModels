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
}
%__Demo();