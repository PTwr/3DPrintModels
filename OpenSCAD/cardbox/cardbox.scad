//Ganimedes Hero tile: 37x46 42mm stack
//CCG (Terraforming Mars) 63.5x88

use <../libs/RoundedShapes.scad>
use <../libs/PrettyWalls.scad>
use <../libs/CopyPaste.scad>

use <modules/floor.scad>

/* [Presentation] */
__DisplayRoof = true;
__DisplayFloor = true;
__DisplayCorners = true;
__DisplayWalls = true;
__DisplayOnlyOneCorner = false;
__DisplayOnlyOneWall = "false"; // [false, X, Y]

//set to max before rendering to STL. Low values are for faster preview only
__Roundness = 0; //[0:100]
$fn=__Roundness;

//for preview only, disable before generating STL
__DisplayCardStack = true;
__PartsVerticalSeparation = 20; //[0:200]
__SideBySide = "false"; // [false, X, Y]
__PartsHorizontalSeparation = 5; //[0:200]
__WallVerticalSeparation = 0; //[0:200]

/* [Dimensions] */
__CardStackSize = [88,63.5,50];
__WallThickness = 5;
__EmptySpaceMargin= 5;

/* [Sides]*/
__CornerUpperPercent = 30; //[10:40]
__CornerBottomPercent = 20; //[10:40]
__PegConnectorsEnabled = false;
__PegConnectorsSize = 50; //[0:100]
__PegConnectorsOnSides = true;
__PegConnectorsPerWallX = 3;
__PegConnectorsPerWallY = 2;
__PegConnectorsPerCorner = 3;
__PegConnectorsHeight = 50; //[0:100]

/* [Clip] */
__BallClipEnabled = true;
//% of wall thickness taken by clip
__BallClipSize = 50; //[0:100]
__BallClipCount = 1; //[1:10]
//% of ball hidden inside of wall, increase for softer clip
__BallClipInset = 75; //[50:100]

/* [Magnets] */
__MagnetsEnabled = true;
__MagnetCountX = 3;
__MagnetCountY = 2;
__MagnetRadius = 1.5;
__MagnetHeight = 2;

/* [Eye Candy] */
__IsRounded = true;
//% of shorter side that will be rounded
__RoundingRadiusPercent = 15; //[0:20]
__SlopedBezels = true;

//Helper functions
function BasePlateDimensions() = [__CardStackSize.x+__WallThickness*2+__EmptySpaceMargin*2, __CardStackSize.y+__WallThickness*2+__EmptySpaceMargin*2, __WallThickness];
function CardStackHeight() = __CardStackSize.z+__EmptySpaceMargin;
function RoundingRadius() = __IsRounded ? min(BasePlateDimensions().x, BasePlateDimensions().y)*__RoundingRadiusPercent/100 : 0.000001;

function __Corner_a() = min(BasePlateDimensions().x,BasePlateDimensions().y)*__CornerUpperPercent/100;
function __Corner_b() = min(BasePlateDimensions().x,BasePlateDimensions().y)*__CornerBottomPercent/100;

function __Wall_ax() = BasePlateDimensions().x-2*__Corner_a();
function __Wall_bx() = BasePlateDimensions().x-2*__Corner_b();
function __Wall_ay() = BasePlateDimensions().y-2*__Corner_a();
function __Wall_by() = BasePlateDimensions().y-2*__Corner_b();

function SeparationVector() = [0,0,CardStackHeight()*__PartsVerticalSeparation/100*(__SideBySide=="false"?1:0)];
function WallSeparationVector() = [0,0,CardStackHeight()*__WallVerticalSeparation/100];

use <../libs/dotSCAD/src/part/connector_peg.scad>
module PegConnectorsHole() {
  if (__PegConnectorsEnabled) {
  }
}

function PegConnectorHeight() = __WallThickness*__PegConnectorsHeight/100;
module PegConnectorsStud(radius=2.5, height=undef, spacing=0.2, void = false) {
  if (__PegConnectorsEnabled) {
    connector_peg(
        radius = radius, 
        height = height,
        spacing = spacing,
        void = void
    );
  }
}
module PegConnectorsLine(length, count, voidspacing = 0.2, void = false, skip=[]) {
  CopyBetween([-length/2,0,0],[length/2,0,0], count, skip=skip)
  PegConnectorsStud(radius = __WallThickness/2*__PegConnectorsSize/100, height = PegConnectorHeight(), spacing = voidspacing, void = void, $fn=20);
}

module Floor() {
  union() {
    difference() {
      translate([0,0,-BasePlateDimensions().z/2-CardStackHeight()/2])
      PrettyBoxWall(BasePlateDimensions(), roundingRadius=RoundingRadius(), windowBezelThickness=__WallThickness*2);
      
      Magnets();
      
      if (__PegConnectorsOnSides && __PegConnectorsPerCorner>0) {
        FloorPegs(void = true);
      }
    }
    
    if (!__PegConnectorsOnSides && __PegConnectorsPerCorner>0) {
      FloorPegs(void = false);
    }
  }
}

module FloorPegs(void) {
  mirror_copy_x()
  mirror_copy_y()
  translate([0,0,-BasePlateDimensions().z/2-CardStackHeight()/2+__WallThickness/2])
  let(bendLength = PI*RoundingRadius()/2)
  let(bendLengthOffset = -RoundingRadius()*2+bendLength)  
  let(bendH = CardStackHeight() + (__PegConnectorsOnSides?PegConnectorHeight()*2:0))
  let(dim=[__Corner_a()*2+bendLengthOffset, __Corner_b()*2+bendLengthOffset, CardStackHeight(),__WallThickness])
  translate([-RoundingRadius(),-RoundingRadius(),0])
  translate([BasePlateDimensions().x/2,BasePlateDimensions().y/2,0])
  //TODO replace with muuuuuch lighter curve positioner, bending blows up normalized tree and requires render
  render()
  BendCenterSection([dim.x,dim.z,dim[3]], [bendLength,bendH,__WallThickness] , reverse=false)
  rotate([void?90:-90,0,0])
  let(skip = __PegConnectorsPerCorner%2==1 ? [__PegConnectorsPerCorner%2+1]:[])
  PegConnectorsLine(__Corner_a()*2+bendLength-2*RoundingRadius(), __PegConnectorsPerCorner, void=void, skip=skip);
}

module Roof() {
  let(h=CardStackHeight())
  difference() {
    union() {
      translate([0,0,+BasePlateDimensions().z/2+h/2])
      mirror([0,0,1])
      PrettyBoxWall(dimensions=BasePlateDimensions(), roundingRadius=RoundingRadius(), windowBezelThickness=__WallThickness*2);
      
      if (!__PegConnectorsOnSides) {
        mirror_copy_y()
        translate([0,BasePlateDimensions().y/2-__WallThickness/2,h/2])
        rotate([180,0,0])
        PegConnectorsLine(__Wall_bx(), __PegConnectorsPerWallX, void=false);
        
        mirror_copy_x()
        translate([BasePlateDimensions().x/2-__WallThickness/2,0,h/2])
        rotate([180,0,90])
        PegConnectorsLine(__Wall_by(), __PegConnectorsPerWallY, void=false);
      }
    }
    if (__PegConnectorsOnSides) {
      mirror_copy_y()
      translate([0,BasePlateDimensions().y/2-__WallThickness/2,h/2])
      rotate([0,0,0])
      PegConnectorsLine(__Wall_bx(), __PegConnectorsPerWallX, void=true);
        
      mirror_copy_x()
      translate([BasePlateDimensions().x/2-__WallThickness/2,0,h/2])
      rotate([0,0,90])
      PegConnectorsLine(__Wall_by(), __PegConnectorsPerWallY, void=true);
    }
  }
}

module Wall(x=true,angle=0) {
  rotate([0,0,angle])
  translate([0,(x?BasePlateDimensions().y:BasePlateDimensions().x)/2-__WallThickness/2,0])
  rotate([90,0,0])
  let(
    a=x?__Wall_ax():__Wall_ay(),
    b=x?__Wall_bx():__Wall_by(),
    h=CardStackHeight()
  )
  difference() {
    union() 
    {
      PrettyBoxWall(dimensions=[a,b,h,__WallThickness], roundingRadius=RoundingRadius(), windowBezelThickness=__WallThickness, roundExternal=false, roundInternal=true);
      
      mirror_copy_x()
      translate([min(a,b)/2,0,0])
      translate([abs(a-b)/2,0,0])
      rotate([90,90,0])
      BallClip();
      
      if (__PegConnectorsOnSides) {
        translate([0,h/2,0])
        rotate([-90,0,0])
        PegConnectorsLine(b, x?__PegConnectorsPerWallX:__PegConnectorsPerWallY, void=false);
      }
    }
    if (!__PegConnectorsOnSides) {
      translate([0,h/2,0])
      rotate([90,0,0])
      PegConnectorsLine(b, x?__PegConnectorsPerWallX:__PegConnectorsPerWallY, void=true);
    }
  }
}

color("red")
SeparateRoofFromFloor()
{
  if (__DisplayRoof)
    translate(WallSeparationVector())
    Roof();
  difference() {
    union() {
      if (__DisplayWalls && __DisplayOnlyOneWall != "Y")
        mirror_copy_y(condition = __DisplayOnlyOneWall == "false")
        Wall(true,0);
      if (__DisplayWalls && __DisplayOnlyOneWall != "X")
        mirror_copy_x(condition = __DisplayOnlyOneWall == "false")
        Wall(false, 90);
    }
    Magnets();
  }
}

module SeparateRoofFromFloor() {
//  translate([0,BasePlateDimensions().y+__WallThickness,0])
  translate([
    __SideBySide=="X"?(BasePlateDimensions().x*(1+__PartsHorizontalSeparation/100)):0,
    __SideBySide=="Y"?(BasePlateDimensions().y*(1+__PartsHorizontalSeparation/100)):0,
    0])
  rotate([__SideBySide=="false"?0:180,0,0])
  translate(SeparationVector()/2)
  children();
}

color("green")
translate(-SeparationVector()/2)
{
  if (__DisplayFloor)
    translate(-WallSeparationVector())
    Floor();
  if (__DisplayCorners)
    mirror_copy_y(condition = !__DisplayOnlyOneCorner)
    mirror_copy_x(condition = !__DisplayOnlyOneCorner)
    Corner();
}

if (__DisplayCardStack) {
  CardStack();
}

module Corner() {
  let(bendLength = PI*RoundingRadius()/2)
  let(bendLengthOffset = -RoundingRadius()*2+bendLength)  
  let(bendH = CardStackHeight() + (__PegConnectorsOnSides?PegConnectorHeight()*2:0))
  let(dim=[__Corner_a()*2+bendLengthOffset, __Corner_b()*2+bendLengthOffset, CardStackHeight(),__WallThickness])
  translate([-RoundingRadius(),-RoundingRadius(),0])
  translate([BasePlateDimensions().x/2,BasePlateDimensions().y/2,0])
  BendCenterSection([dim.x,dim.z,dim[3]], [bendLength,bendH,__WallThickness] , reverse=false)
  union() {
     difference() {
      PrettyBoxWall(dimensions=dim, roundingRadius=RoundingRadius(), windowBezelThickness=__WallThickness, roundExternal=false, roundInternal=true);
      
      mirror_copy_x()
      translate([min(dim[0],dim[1])/2,0,0])
      rotate([0,-90,90])
      BallClip();  
       
      if (!__PegConnectorsOnSides && __PegConnectorsPerCorner>0) {
        rotate([90,0,00])
        translate([0,0,dim.z/2])
        rotate([180,0,0])
        let(skip = __PegConnectorsPerCorner%2==1 ? [__PegConnectorsPerCorner%2+1]:[])
        PegConnectorsLine(__Corner_a()*2+bendLength-2*RoundingRadius(), __PegConnectorsPerCorner, void=true, skip=skip);
      }
       
    }
    
    if (__PegConnectorsOnSides &&  __PegConnectorsPerCorner>0) {
      rotate([90,0,0])
      translate([0,0,dim.z/2])
      let(skip = __PegConnectorsPerCorner%2==1 ? [__PegConnectorsPerCorner%2+1]:[])
      PegConnectorsLine(__Corner_a()*2+bendLength-2*RoundingRadius(), __PegConnectorsPerCorner, void=false, skip=skip);
    }
       
  }
}


module CardStack() {
  %cube(__CardStackSize, center=true);
}

module BallClip() {
  color("magenta")
  let(
    a=__Wall_ax(), 
    b=__Wall_bx(),
    h=CardStackHeight(),
    alpha = TrapezoidSideAngle(a,b,h),
    d = TrapezoidTriangleLength(a,b),
    c = TrapezoidSideLength(a,b,h),
    count =__BallClipEnabled? __BallClipCount:0,
    r=__WallThickness/2*__BallClipSize/100,
    inset=r*2*__BallClipInset/100
  )
  translate([0,-abs(a-b)/4,0])
  Balls(alpha, count, c, r, inset);
}

module Balls(angle, count, h, radius, inset = undef) {let(dY=inset==undef?0:inset)
  rotate([90-angle,0,0])
  CopyBetween([0,-inset+radius,-h/2],[0,-inset+radius,h/2],count)
  sphere(r=radius, $fn=20);
}

module MagnetLine(length, count) {  
  CopyBetween([-length/2,0,0],[length/2,0,0],count)
  cylinder(__MagnetHeight*2, r = __MagnetRadius, center=true, $fn=20);
}

module Magnets() {
  mirror_copy_y()
  translate([0,BasePlateDimensions().y/2-__WallThickness/2,-CardStackHeight()/2])
  MagnetLine(__Wall_ax(), __MagnetCountX);
  
  mirror_copy_x()
  translate([BasePlateDimensions().x/2-__WallThickness/2,0,-CardStackHeight()/2])
  rotate([0,0,90])
  MagnetLine(__Wall_ay(), __MagnetCountY);
}