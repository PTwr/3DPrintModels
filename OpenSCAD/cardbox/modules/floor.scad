include <../../libs/CopyPaste.scad>
include <../../libs/RoundedShapes.scad>

module RoundedCube(Size, RoundingRadius, Scale = 1) {
  linear_extrude(Size.z, center = true, scale = Scale)
  hull() 
  {
    color("red")
    translate([Size.x/2-RoundingRadius,Size.y/2-RoundingRadius,0])
    circle(r = RoundingRadius);
    
    color("green")
    translate([Size.x/2-RoundingRadius,-Size.y/2+RoundingRadius,0])
    circle(r = RoundingRadius);
    
    color("blue")
    translate([-Size.x/2+RoundingRadius,Size.y/2-RoundingRadius,0])
    circle(r = RoundingRadius);
    
    color("yellow")
    translate([-Size.x/2+RoundingRadius,-Size.y/2+RoundingRadius,0])
    circle(r = RoundingRadius);
  }
}
module RoundedCube2(Size, RoundingRadius, Scale = 1) {
//  color("red")
//  square([Size.x,Size.y], center=true);
//  cube([Size.x,Size.y, Size.z-1], center=true);
  minkowski()
  {
    RoundedCube(Size-[Size.z*2/3,Size.z*2/3,Size.z*2/3],RoundingRadius,Scale);
    sphere(r=Size.z/3);
  }
  //result z => Size.z + 2x sphere.radius
  //result x/y => Size.x/y + 2x sphere.radius
}

//difference() {
//RoundedCube([100,50,10], RoundingRadius(), 1);
//  offset(r=5) {
//RoundedCube([80,40,10.1], RoundingRadius(), 1);}
//}
//difference() {
//RoundedCube([100,50,10], RoundingRadius(), 1);
//RoundedCube2([100,50,10.1], RoundingRadius(), 1);
//}



//fillet(3)
//zround(3)
//difference() {
//square(100, center=true);
//square(50, center=true);
//}

// $fn=50;
//minkowski(){
// cube([10,10,1]);
// cylinder(r1=2, r2=1,h=1);
////  sphere(1);
//}

// cylinder(r1=2, r2=1,h=1);

//minkowski()
//{
////translate([0,0,4])
//cube([100,100,2]);
//cylinder(r=5, h= 1);
//}
//translate([-3,-3,0])
//cube([7,7,7], center=true);

//RoundedCube2([100,50,10.1], RoundingRadius(), 1);