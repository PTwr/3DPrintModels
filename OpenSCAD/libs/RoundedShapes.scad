use <dotSCAD/src/bend.scad>

module round_internal(r) {
  round_external(-r)
  children();
}
module round_external(r) {
   offset(r = r) {
     offset(delta = -r) {
       children();
     }
   }
}

module rounded_square(size, windowSize=[0,0], roundingRadius = 0, center = true) {
    round_internal(roundingRadius)
    difference() {
        round_external(roundingRadius)
        square([size.x, size.y], center=true);
        square([windowSize.x, windowSize.y], center=true);    
    }
}
module rounded_cube(size, windowSize = [0,0], roundingRadius = 0, scale = 1, center = true) {
    linear_extrude(size.z, center = true, scale = scale)
    rounded_square(size, windowSize, roundingRadius, center);
}

//moves object to first octant
module uncenter(boundingDimensions) {
  translate(boundingDimensions/2)
  children();
}
module center(boundingDimensions) {
  translate(-boundingDimensions/2)
  children();
}
module zeroin_section(boundingDimensions, bendDimensions) {
  let(sectionOffset=-(boundingDimensions-bendDimensions)/2)
  translate(sectionOffset)
  children();
}


function getBendRadius(bendLength) = 2*bendLength/PI;

//bends object by rounded 90 degree angle
module BendCenterSection(boundingDimensions, bendDimensions, reverse=false) {
  translate([0,0,-bendDimensions.y/2])
  bend(bendDimensions, 90)
  uncenter(boundingDimensions)
  zeroin_section(boundingDimensions, bendDimensions)
  mirror([0,0,reverse?0:1])
  children();
  
  let (bendRadius = getBendRadius(bendDimensions.x))
  let(wingLength = (boundingDimensions.x-bendDimensions.x)/2) {
    translate([0,boundingDimensions.z/2+bendRadius-boundingDimensions.z,0])
    mirror([0,reverse?1:0,0])
    rotate([90,0,0])
    translate([-wingLength/2,0,0])
    LeftWing(boundingDimensions, bendDimensions, center=true)
    children();
    
    translate([boundingDimensions.z/2+bendRadius-boundingDimensions.z,0,0])
    mirror([reverse?0:1,0,0])
    mirror([0,1,0])
    rotate([90,0,90])
    translate([+wingLength/2,0,0])
    RightWing(boundingDimensions, bendDimensions, center=true)
    children();
  }
}

module LeftWing(boundingDimensions, centerDimensions, center = false) {
  Wing(boundingDimensions, centerDimensions, side = 1, center = center)
  children();
}
module RightWing(boundingDimensions, centerDimensions, center = false) {
  Wing(boundingDimensions, centerDimensions, side = -1, center = center)
  children();
}
module Wing(boundingDimensions, centerDimensions, side = 1, center = false) {
  let(B=centerDimensions.x)
  let(A=(boundingDimensions.x-B)/2)
  let(wingCentering=center?side*(A/2+B/2):0)
  translate([wingCentering,0,0])
  difference() {
    children();
    
    let(xOffset = boundingDimensions.x/2-centerDimensions.x/2)
    scale([1,1.1,1.1])
    translate([side*xOffset,0,0])
    cube(boundingDimensions, center= true);
  }
}