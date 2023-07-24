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
    round_internal(RoundingRadius())
    difference() {
        round_external(RoundingRadius())
        square([size.x, size.y], center=true);
        square([windowSize.x, windowSize.y], center=true);    
    }
}
module rounded_cube(size, windowSize = [0,0], roundingRadius = 0, scale = 1, center = true) {
    linear_extrude(size.z, center = true, scale = scale)
    rounded_square(size, windowSize, roundingRadius, center);
}