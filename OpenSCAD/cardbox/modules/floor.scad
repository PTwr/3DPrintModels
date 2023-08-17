use <../../libs/RoundedShapes.scad>
use <../../libs/PrettyWalls.scad>
use <../../libs/CopyPaste.scad>

module _Floor() {
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

module Floor(plateDimensions = [80,50,5], roundingRadius = 5, bezelThickness = 5) {
  union() {
    difference() {
      PrettyBoxWall(plateDimensions, roundingRadius=roundingRadius, windowBezelThickness=bezelThickness);
    }
  }
}

Floor();