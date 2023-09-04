//Ganimedes Hero tile: 37x46 42mm stack
//CCG (Terraforming Mars) 63.5x88
//standard playing cards:  88.1x58.3x

use <../libs/RoundedShapes.scad>
use <../libs/PrettyWalls.scad>
use <../libs/CopyPaste.scad>
use <../libs/BendShapes.scad>
use <../libs/Helpers.scad>
use <../libs/dotSCAD/src/part/connector_peg.scad>

//use <modules/floor.scad>

/* [Size] */
__CardStackDimensions = [88,63.5,50]; //CCG
__WallThickness = 5;
__WallFrameThickness = 5;
//How much of shorter side will corner take in %
__CornerPercentUpper = 20; //[0:100]
//How much of shorter side will corner take in %
__CornerPercentLower = 30; //[0:100]

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
__DisplayBothHalvesOfLid = true;
__DisplaySeparateSidePegs = true;
__DisplaySeparateLidPegs = true;

/* [Explode view] */
__ExplodeUpperAndLower = 220; //[100:300]
__ExplodeWallsAndSurfaces = 20; //[0:100]
__ExplodeLidHalves = 50; //[0:100]

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

/* [Construction pegs] */
__PegsEnabled = true;
__PegsPerCorner = 3;
__PegsPerWallX = 3;
__PegsPerWallY = 2;
__PegSize = 50; //[0:100]
__PegHeight = 50; //[0:100]
__PegsSeparately = true;

/* [Split lid] */
__SplitLidEnabled = true;
__SplitLidPegsEnabled = true;
__SplitLidPegSize = 50; //[0:100]
__SplitLidPegHeight = 50; //[0:100]

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
  
  color("red")
  SeparatePegs();
}

module SeparatePegs() {
  let(xOffset = floorDim()[0]) {
    if (__PegsSeparately && __DisplaySeparateLidPegs && __SplitLidPegsEnabled && __SplitLidEnabled) {
      let(pegCount = 4)
      let(radius = __WallThickness*__SplitLidPegSize/100/2)
      let(height = __WallThickness*__SplitLidPegHeight/100)
      for(i = [1:1:pegCount])
        translate([xOffset,-radius*4*1,0])
      ConnectorPeg(pegCount, radius, height);  
    }
    if (__PegsSeparately && __DisplaySeparateSidePegs) {
      let(radius = __WallThickness*__PegSize/100/2)
      let(height = __WallThickness*__PegHeight/100) {
        translate([xOffset,radius*4*1,0])
        let(pegCount = __PegsPerWallX*2)
        ConnectorPeg(pegCount, radius, height);
        
        translate([xOffset,radius*4*2,0])
        let(pegCount = __PegsPerWallY*2)
        ConnectorPeg(pegCount, radius, height);
        
        translate([xOffset,radius*4*3,0])
        let(pegCount = __PegsPerCorner*2)
        ConnectorPeg(pegCount, radius, height);
        
        translate([xOffset,radius*4*4,0])
        let(pegCount = __PegsPerCorner*2)
        ConnectorPeg(pegCount, radius, height);
      }
    }
  }
}

module ConnectorPeg(pegCount, radius, height) {
  for(i = [1:1:pegCount])
    translate([i*radius*4,0,height])
    mirror_copy_z()
    connector_peg(
        radius = radius,
        height = height,
        void = false,
        ends = false,
        $fn=20);
}

module SplitLid(dim) {
  if (__SplitLidEnabled) {
    let(dim=floorDim())
    rotate_copy_z(180, condition = __DisplayBothHalvesOfLid)
    translate_copy_y(-__ExplodeLidHalves/100*dim[2], copy=false)
    union() {
      difference() {
        children();
        
        //scale up to cover up for pegs and ghosting
        scale([2,2,2])
        translate([0,dim[2]/2,0])
        cube([dim[0],dim[2],dim[3]], center = true);
      
        if (__SplitLidPegsEnabled) {
          mirror_copy_x(condition = __PegsSeparately)
          translate(-[dim[0]/2-__WallThickness/2,0,0])
          rotate([90,0,0])
          connector_peg(
              radius = __WallThickness*__SplitLidPegSize/100/2,
              height = __WallThickness*__SplitLidPegHeight/100,
              void = true,
              $fn=20);    
        }
      } 
      
      if (!__PegsSeparately && __SplitLidPegsEnabled) {
        translate([dim[0]/2-__WallThickness/2,0,0])
        rotate([-90,0,0])
        connector_peg(
            radius = __WallThickness*__SplitLidPegSize/100/2,
            height = __WallThickness*__SplitLidPegHeight/100,
            void = false,
            $fn=20);  
      }
    }  
  } else {
    //no changes
    children();
  }
}

module LowerHalf() {
  if (__DisplayFloor) {
    let(dim = floorDim())
    translate([0,0,-wallAndSurfaceDistance()])
    SplitLid(dim)
    //magnets Y
    WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=__MagnetCountY, trapezoidDimensions=dim, shape=__MagnetShape, left=true, right=true, condition = __MagnetsEnabled, perpendicularInner = true, bezelThickness = __WallThickness, margin = cornerLowerWidth())
    //magnets X
    WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=__MagnetCountX, trapezoidDimensions=dim, shape=__MagnetShape, top=true, bottom=true, condition = __MagnetsEnabled, perpendicularInner = true, bezelThickness = __WallThickness, margin = cornerLowerWidth())
    difference() {
      PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallThickness*2, roundingRadius = RoundingRadiusZ(), window = __Windowed);
      //subastract construcion peg holes
      CornerPegHoles();
    }
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
      //face outwards
      rotate([180,0,0])
      let(dim=floorDim())
      SplitLid(dim)
      //construction pegs X
      WithConnectors(diameter=__WallThickness*__PegSize/100,height=__WallThickness*__PegHeight/100,count=__PegsPerWallX, trapezoidDimensions=dim, shape="peg", top=true, bottom=true, condition = __PegsEnabled, void=true, margin=cornerUpperWidth(), perpendicularInner=true, bezelThickness = __WallThickness)
      //construction pegs Y
      WithConnectors(diameter=__WallThickness*__PegSize/100,height=__WallThickness*__PegHeight/100,count=__PegsPerWallY, trapezoidDimensions=dim, shape="peg", left=true, right=true, condition = __PegsEnabled, void=true, margin=cornerUpperWidth(), perpendicularInner=true, bezelThickness = __WallThickness)
      //box wall
      PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallThickness*2, roundingRadius = RoundingRadiusZ(), window = __Windowed);    
    }
    
    //match Z with surfaces
    translate([0,0,-__CardStackDimensions.z/2 - __WallThickness/2])
    if (__DisplayWalls) {
      if (__DisplayXWall) {
        Wall(xDim(), floorDim()[2], __DisplayBothXWalls, RoundingRadiusX(), __MagnetCountX, __PegsPerWallX);
      }
      
      if (__DisplayYWall) {
        rotate([0,0,90])
        Wall(yDim(), floorDim()[0], __DisplayBothYWalls, RoundingRadiusY(), __MagnetCountY, __PegsPerWallY); 
      } 
    }
  }
}

module Wall(dim, offset, mirror, roundingRadius, magnetCount, pegCount) {
  mirror_copy_y(condition = mirror)
  //position on box edge
  translate([0,offset/2-__WallThickness/2,0])
  //vertical
  rotate([90,0,0])
  //construction pegs
  WithConnectors(diameter=__WallThickness*__PegSize/100,height=__WallThickness*__PegHeight/100,count=pegCount, trapezoidDimensions=dim, shape="peg", top=true, condition = __PegsEnabled, void=__PegsSeparately)
  //magnets
  WithConnectors(diameter=__MagnetDiameter,height=__MagnetHeight,count=magnetCount, trapezoidDimensions=dim, shape=__MagnetShape, bottom=true, condition = __MagnetsEnabled)
  //ball clip
  WithConnectors(diameter = __WallThickness*__BallClipSizePercent/100, count=__BallClipCount, trapezoidDimensions=dim, shape="sphere", right=true, left=true, condition = __BallClipEnabled, void=false, insetPercent = __BallClipInset)
  PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallFrameThickness, roundingRadius = roundingRadius, window = __Windowed, roundExternal = false);
}

module Corners() {
  
//render separately from bent corner to slim down render time  
  //populte other corners
  mirror_copy_y(condition = __DisplayAllCorners)
  mirror_copy_x(condition = __DisplayAllCorners)
  //match display of single walls
  mirror([1,0,0])
  //move to corner of floor
  translate([floorDim()[0]/2,floorDim()[2]/2,0])
  UnionOrDiff(!__PegsSeparately) {
    //put corner at [0,0]
    translate([-RoundingRadiusZ(),-RoundingRadiusZ(),0])
    //Z position to match lids
    translate([0,0,+__CardStackDimensions.z/2 + __WallThickness/2])
    Corner();
        
    CornerPegs(void = __PegsSeparately);
  }
}

module CornerPegHoles() {
  //populte other corners
  mirror_copy_y()
  mirror_copy_x()
  //match display of single walls
  mirror([1,0,0])
  //move to corner of floor
  translate([floorDim()[0]/2,floorDim()[2]/2,0])
  CornerPegs(void=true);
}


//render separately from bent corner to slim down render time  
module CornerPegs(void = false) {
  if (__PegsEnabled) {
    //put in center of wall instead of outer edge
    translate([-__WallThickness/2,-__WallThickness/2,0])
    //put on top of floor
    translate([0,0,__WallThickness/2])
    //match first corner rotation
    rotate([0,0,270])
    //radius to center of wall instead of outer edge
    let(radius = RoundingRadiusZ()-__WallThickness/2)
    //centered wing length is same as edge, only bend length changes
    let(cornerWingLengthLower = cornerLowerWidth() - RoundingRadiusZ())
    //align with corner
    translate([0,-cornerWingLengthLower-radius,0])
    let(arc = PointsOnArc(cornerWingLengthLower, radius, __PegsPerCorner, false, false))
    for(p = arc) {
      translate(p)
      //down facing
      rotate([180-180*int(__PegsSeparately),0,0])
      connector_peg(
        radius = __WallThickness*__PegSize/100/2,
        height = __WallThickness*__PegSize/100,
        void = void,
        $fn=20);
    }
  }
}

module Corner() {
  //corner width without bend
  let(cornerWingLengthUpper = cornerUpperWidth() - RoundingRadiusZ())
  let(cornerWingLengthLower = cornerLowerWidth() - RoundingRadiusZ())
  let(bendLength = PI*RoundingRadiusZ()/2)
  let(dim = [bendLength + cornerWingLengthUpper*2, bendLength + cornerWingLengthLower*2, __CardStackDimensions.z, __WallThickness])
  let(bendH = dim.z) {    
    BendCenterSection([dim.y,dim.z,dim[3]], [bendLength,bendH,__WallThickness] , reverse=false)
    //ball clip
    WithConnectors(diameter = __WallThickness*__BallClipSizePercent/100, count=__BallClipCount, trapezoidDimensions=dim, shape="sphere", right=true, left=true, condition = __BallClipEnabled, void=true, insetPercent = -__BallClipInset)
    PrettyBoxWall(dimensions = dim, windowBezelThickness = __WallFrameThickness, roundingRadius = RoundingRadiusC(), window = __Windowed, roundExternal = false);
  }
}


Cardbox();