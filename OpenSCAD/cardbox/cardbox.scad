include <./modules/floor.scad>


__Part = "both"; // [bottom, top, both, none]
//for preview only, disable before generating STL
__DisplayCardStack = true;

/* [Dimensions] */
//add ~3mm if jacketed
__CardSize = [88,63.5,0.5];
__CardCount = 50;

/* [Eye Candy] */
__IsRounded = true;
//% of shorter side that will be rounded
__RoundingRadiusPercent = 15;

//Helper functions
function RoundingRadius() = __IsRounded ? min(__CardSize.x, __CardSize.y)*15/100 : 0.000001;

//difference() 
{
//RoundedCube([100,50,10], RoundingRadius(), 1);
//  offset(r=5) 
    {
RoundedCube([80,40,10.1], RoundingRadius(), 1);
      }
}

include <../../libs/RoundedShapes.scad>
//
//color("red")
//translate([0,0,10])
//linear_extrude(10, center = true, scale = 1)
//round_external(RoundingRadius())
//square([80,40], center=true);
//
//color("green")
//translate([0,0,20])
//linear_extrude(10, center = true, scale = 1)
//round_internal(RoundingRadius())
//difference() {
//round_external(RoundingRadius())
//square([80,40], center=true);
//square([70,30], center=true);    
//}

color("blue")
translate([0,0,30])
rounded_cube([80,40,10], [70,30], RoundingRadius(), scale=[0.8,0.5]);

//difference() {
//RoundedCube([100,50,10], RoundingRadius(), 1);
//RoundedCube2([100,50,10.1], RoundingRadius(), 1);
//}