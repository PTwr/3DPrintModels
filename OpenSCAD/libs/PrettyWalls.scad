use <RoundedShapes.scad>
use <GeometryHelpers.scad>
use <dotSCAD/src/hollow_out.scad>
use <dotSCAD/src/shape_trapezium.scad>

module PrettyBoxWall(dimensions = [80,50,5], windowBezelThickness = undef, roundingRadius = 5, slopedBezel = true, roundExternal=true, roundInternal=true) {
  union() {
    color("red")
    BoxWall(dimensions, windowBezelThickness*(windowBezelThickness != undef ? 0.5 : 1), roundingRadius, [1,1], roundExternal, roundInternal);
    if (windowBezelThickness != undef) {
      let(dim=RectDimensionsToTrapezoidDimensions(dimensions))
      let(scale=[(dim[0]-windowBezelThickness)/dim[0],(dim[2]-windowBezelThickness)/dim[2]])
      {
        color("green")
        BoxWall(dimensions, windowBezelThickness/2, roundingRadius, scale, roundExternal, roundInternal);  
        //fill annoying gap
        color("blue")
        BoxWall(dimensions, windowBezelThickness/2, roundingRadius, (scale+[1,1])/2, roundExternal, roundInternal);
      }
    }
  }
}

module BoxWall(dimensions = [80,50,5], windowBezelThickness = undef, roundingRadius = 0, extrudeScale = [1,1], roundExternal=true, roundInternal=true) { 
  let(dim=RectDimensionsToTrapezoidDimensions(dimensions))
  let(
    a = dim[0],
    b = dim[1],
    h = dim[2],
    t = dim[3]
  )
  linear_extrude(t, center = true, scale = extrudeScale)
  round_internal(roundInternal?roundingRadius:0)
  hollow_out(shell_thickness = windowBezelThickness == undef ?max(dimensions) : windowBezelThickness) 
  polygon(
      shape_trapezium([a, b], 
      h = h,
      corner_r = roundExternal?roundingRadius:0)
  );
}

module __Demo() {
  BoxWall(windowBezelThickness = 5);
  translate([0,0,10])
  PrettyBoxWall(windowBezelThickness = 5);
}
__Demo();