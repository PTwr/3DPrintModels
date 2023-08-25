//Ganimedes Hero tile: 37x46 42mm stack
//CCG (Terraforming Mars) 63.5x88

use <../libs/RoundedShapes.scad>
use <../libs/PrettyWalls.scad>
use <../libs/CopyPaste.scad>
use <../libs/BendShapes.scad>

//use <modules/floor.scad>

/* [Parts] */
__DisplayRoof = true;
__DisplayFloor = true;
__DisplayWalls = true;
__DisplayXWall = true;
__DisplayBothXWalls = true;
__DisplayYWall = true;
__DisplayBothYWalls = true;
__DisplayCorners = true;
__DisplayAllCorners = true;

/* [Explode view] */
__ExplodeUpperAndLower = 100; //[100:300]
__ExplodeWallsAndSurfaces = 0; //[0:100]


/* [Size] */
__CardStackDimensions = [88,63.5,50]; //CCG
__WallThickness = 5;
__WallFrameThickness = 5;
//How much of shorter side will corner take in %
__CornerPercentUpper = 20; //[0:100]
//How much of shorter side will corner take in %
__CornerPercentLower = 30; //[0:100]

/* [Eye candy] */
__Windowed = true;
//% of shorter side that will be rounded
__RoundingRadiusPercentX = 5; //[0:20]
__RoundingRadiusPercentY = 5; //[0:20]
__RoundingRadiusPercentC = 5; //[0:20]
__RoundingRadiusPercentZ = 10; //[0:20]

/* [Ball clip] */
__BallClipEnabled = true;
__BallClipSizePercent = 20; //[0:100]
__BallClipCount = 3;
__BallClipInset = 50; //[-100:100]

/* [Magnets] */
__MagnetsEnabled = true;
__MagnetCountX = 3;
__MagnetCountY = 2;
__MagnetDiameter = 3;
__MagnetHeight = 2;
__MagnetShape = "cylinder"; //[cylinder, cube]

function floorDim() = [__CardStackDimensions.x + __WallThickness*2, __CardStackDimensions.x + __WallThickness*2, __CardStackDimensions.y + __WallThickness*2, __WallThickness];
function shorterSide() = min(floorDim()[0], floorDim()[2]);
function cornerUpperWidth() = shorterSide()*__CornerPercentUpper/100;
function cornerLowerWidth() = shorterSide()*__CornerPercentLower/100;

function xDim() = [floorDim()[0]-cornerUpperWidth()*2, floorDim()[0]-cornerLowerWidth()*2, __CardStackDimensions.z, __WallThickness];
function yDim() = [floorDim()[2]-cornerUpperWidth()*2, floorDim()[2]-cornerLowerWidth()*2, __CardStackDimensions.z, __WallThickness];

function upperAndLowerSurfacesDistance() = __CardStackDimensions.z * __ExplodeUpperAndLower/100 + __WallThickness;
function wallAndSurfaceDistance() = __CardStackDimensions.z * __ExplodeWallsAndSurfaces/100;

function RoundingRadiusX() = min(floorDim().x, floorDim().y)*__RoundingRadiusPercentX/100;
function RoundingRadiusY() = min(floorDim().x, floorDim().y)*__RoundingRadiusPercentY/100;
function RoundingRadiusC() = min(floorDim().x, floorDim().y)*__RoundingRadiusPercentC/100;
function RoundingRadiusZ() = min(floorDim().x, floorDim().y)*__RoundingRadiusPercentZ/100;

module Cardbox() {
  LowerHalf();
  UpperHalf();
}

module LowerHalf() {
  if (__DisplayFloor) {
    let(dim = floorDim())
    translate([0,0,-wallAndSurfaceDistance()])
    WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=__MagnetCountY, trapezoidDimensions=dim, shape=__MagnetShape, left=true, right=true, condition = __MagnetsEnabled, perpendicularInner = true, bezelThickness = __WallThickness, margin = cornerLowerWidth())
    WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=__MagnetCountX, trapezoidDimensions=dim, shape=__MagnetShape, top=true, bottom=true, condition = __MagnetsEnabled, perpendicularInner = true, bezelThickness = __WallThickness, margin = cornerLowerWidth())
    PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallThickness*2, roundingRadius = RoundingRadiusZ(), window = __Windowed);
  }
  
  if (__DisplayCorners) {
    Corners();
  }
}

module UpperHalf() {
  //explode upper and lower lid
  translate([0,0,upperAndLowerSurfacesDistance()]) {
    if (__DisplayRoof) {
      //explode walls from lid
      translate([0,0,wallAndSurfaceDistance()])
      rotate([180,0,0])
      PrettyBoxWall(dimensions = floorDim(), windowBezelThickness = __WallThickness*2, roundingRadius = RoundingRadiusZ(), window = __Windowed);    
    }
    
    //match Z with surfaces
    translate([0,0,-__CardStackDimensions.z/2 - __WallThickness/2])
    if (__DisplayWalls) {
      if (__DisplayXWall) {
        Wall(xDim(), floorDim()[2], __DisplayBothXWalls, RoundingRadiusX(), __MagnetCountX);
      }
      
      if (__DisplayYWall) {
        rotate([0,0,90])
        Wall(yDim(), floorDim()[0], __DisplayBothYWalls, RoundingRadiusY(), __MagnetCountY); 
      } 
    }
  }
}

module Wall(dim, offset, mirror, roundingRadius, magnetCount) {
  mirror_copy_y(condition = mirror)
  translate([0,offset/2-__WallThickness/2,0])
  rotate([90,0,0])
  //magnets
  WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=magnetCount, trapezoidDimensions=dim, shape=__MagnetShape, bottom=true, condition = __MagnetsEnabled)
  //ball clip
  WithConnectors(diameter = __WallThickness*__BallClipSizePercent/100, count=__BallClipCount, trapezoidDimensions=dim, shape="sphere", right=true, left=true, condition = __BallClipEnabled, void=false, insetPercent = __BallClipInset)
  PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallFrameThickness, roundingRadius = roundingRadius, window = __Windowed, roundExternal = false);
}

module Corners() {
  //populte other corners
  mirror_copy_y(condition = __DisplayAllCorners)
  mirror_copy_x(condition = __DisplayAllCorners)
  //match display of single walls
  mirror([1,0,0])
  //move to corner of floor
  translate([floorDim()[0]/2,floorDim()[2]/2,0])
  //put corner at [0,0]
  translate([-RoundingRadiusZ(),-RoundingRadiusZ(),0])
  //Z position to match lids
  translate([0,0,+__CardStackDimensions.z/2 + __WallThickness/2])
  Corner();
}

module Corner() {
  //corner width without bend
  let(cornerWingLengthUpper = cornerUpperWidth() - RoundingRadiusZ())
  let(cornerWingLengthLower = cornerLowerWidth() - RoundingRadiusZ())
  let(bendLength = PI*RoundingRadiusZ()/2)
  let(dim = [bendLength + cornerWingLengthUpper*2, bendLength + cornerWingLengthLower*2, __CardStackDimensions.z, __WallThickness])
  let(bendH = dim.z) // TODO + peg height
  {
    echo(bendLength);
    echo(cornerWingLengthUpper);
    echo(cornerWingLengthLower);
    
    BendCenterSection([dim.y,dim.z,dim[3]], [bendLength,bendH,__WallThickness] , reverse=false)
    //ball clip
    WithConnectors(diameter = __WallThickness*__BallClipSizePercent/100, count=__BallClipCount, trapezoidDimensions=dim, shape="sphere", right=true, left=true, condition = __BallClipEnabled, void=true, insetPercent = -__BallClipInset)
    PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallFrameThickness, roundingRadius = RoundingRadiusC(), window = __Windowed, roundExternal = false);
  }
}

//TODO corners
//TODO corner connector positioning
//TODO construction studs
Cardbox();