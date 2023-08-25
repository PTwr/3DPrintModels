module copypaste(method, vector, copy=true, condition=true) {
  if (condition) {
    if (method == "mirror") {
      mirror(vector)
      children();
    }
    if (method == "rotate") {
      rotate(vector)
      children();
    }
    if (method == "translate") {
      translate(vector)
      children();
    }
    if (copy) {
      children();
    }
  } else {
    children();
  }
}

module mirror_copy(vector, copy=true, condition=true) {
  copypaste("mirror", vector, copy, condition)
  children();
}
module rotate_copy(vector, copy=true, condition=true) {
  copypaste("rotate", vector, copy, condition)
  children();
}
module translate_copy(vector, copy=true, condition=true) {
  copypaste("translate", vector, copy, condition)
  children();
}

module mirror_copy_x(copy=true, condition=true) {
  mirror_copy([1,0,0], copy, condition)
  children();
}
module mirror_copy_y(copy=true, condition=true) {
  mirror_copy([0,1,0], copy, condition)
  children()
  ;
}
module mirror_copy_z(copy=true, condition=true) {
  mirror_copy([0,0,1], copy, condition)
  children();
}

module rotate_copy_x(angle, copy=true, condition=true) {
  rotate_copy([angle,0,0], copy, condition)
  children();
}
module rotate_copy_y(angle, copy=true, condition=true) {
  rotate_copy([0,angle,0], copy, condition)
  children();
}
module rotate_copy_z(angle, copy=true, condition=true) {
  rotate_copy([0,0,angle], copy, condition)
  children();
}

module translate_copy_x(offset, copy=true, condition=true) {
  translate_copy([offset,0,0], copy, condition)
  children();
}
module translate_copy_y(offset, copy=true, condition=true) {
  translate_copy([0,offset,0], copy, condition)
  children();
}
module translate_copy_z(offset, copy=true, condition=true) {
  translate_copy([0,0,offset], copy, condition)
  children();
}

module CopyBetween(from, to, count, includeFrom = false, includeTo = false, skip=[], margin = 0) {
  let(points = PointsBetween(from, to, count,includeFrom,includeTo, skip, margin))
  CopyToPoints(points)
  children();
}

module CopyToPoints(points) {
  for (p = points) {
    translate(p)
    children();
  }
}

use <dotSCAD/src/util/contains.scad>
function PointsBetween(from, to, count, includeFrom = false, includeTo = false, skip=[], margin = 0) =
  let(lv = to-from) //length vector
  let(length = sqrt(lv.x*lv.x + lv.y*lv.y + lv.z+lv.z))

  //start from margin
  let(offset = lv*(margin/length))
  //shorten vector by margins
  let(lv=lv-offset-offset)
  
  let(c=count-(includeFrom?1:0)-(includeTo?1:0))
  let(dV=lv/(c+1))

  [for(n = [(includeFrom?0:1):(includeTo?c+1:c)])
    if (contains(skip,n)==false)
      from+dV*n+offset
  ];
    
function PointsOnArc(wingLength, bendRadius, count, includeFrom = false, includeTo = false, skip=[], margin = 0) =
  let(bendLength = 2*Pi*bendRadius/4) //quarter of circle
  let(length = wingLength + bendRadius) //total length
  let(c=count-(includeFrom?1:0)-(includeTo?1:0)+1) //segment count
  let(dL = length/c)
  concat(
    //left wing
//    [for(n = [(includeFrom?0:1):(includeTo?c+1:c)])
//      if (contains(skip,n)==false)
//        from+dV*n+offset
//    ]
    //bend
    //right wing
    );
    
module __Demo() {
  echo(PointsBetween([0,0,0],[10,10,10],5, includeFrom=false, includeTo=false));
  echo(PointsBetween([0,0,0],[10,0,0],5, includeFrom=true, includeTo=true, margin = 1));
  echo(PointsBetween([0,0,0],[10,10,10],5, includeFrom=true, includeTo=true, margin = 1));
  
}
%__Demo();