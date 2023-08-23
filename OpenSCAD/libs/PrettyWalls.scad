use <Helpers.scad>
use <RoundedShapes.scad>
use <GeometryHelpers.scad>
use <CopyPaste.scad>
use <dotSCAD/src/hollow_out.scad>
use <dotSCAD/src/shape_trapezium.scad>
use <dotSCAD/src/part/connector_peg.scad>

module WithConnectors(diameter, count, trapezoidDimensions, height = undef, bezelThickness = 0, shape="cylinder", insetPercent = 0, margin = 0, perpendicularInner = false, perpendicularOuter = false, void = true, spacingPercent = 10, top = false, bottom = false, left = false, right = false, condition = true) {
  let(height = height == undef ? diameter : height)
  UnionOrDiff(union = !void) {
    children();
    if (condition) {      
      let(dim = RectDimensionsToTrapezoidDimensions(trapezoidDimensions))
      let(
        a = dim[0],
        b = dim[1],
        h = dim[2],
        t = dim[3],
        alpha = TrapezoidSideAngle(a, b, h)
      )
      let(inset = ((shape=="sphere"?diameter/2:height)*insetPercent/100))
      // hole needs to fit whole magnet
      let(height=height*2) 
      // perpendicular holes needs som extra handling
      let(perpendicular=perpendicularInner || perpendicularOuter)
      let(inPlaneInset = perpendicular ? (bezelThickness/2) : inset)
      translate([0,0,perpendicular ? ((perpendicularInner?t/2-inset:0) - (perpendicularOuter?t/2-inset:0)) : 0])
//      let(zOffset = perpendicular ? t/2 - inset : 0)
      let(insetVectorLR = [[inPlaneInset,0,0],[inPlaneInset,0,0]])
      let(insetVectorTB = [[0,inPlaneInset,0],[0,inPlaneInset,0]])
      // conditionally render connector pegs/holes on all sides
      union()
      {
        //TODO inset
        //TODO translate perpendicular
        //spread holes along edge
        if (left) {
          let(vector = GetTrapezoidLeftEdgeVector(dim))
          let(vector = vector + insetVectorLR)
          _Connectors(diameter, height, count, vector, margin, perpendicular, alpha, shape, void);
        }
        if (right) {
          let(vector = GetTrapezoidRightEdgeVector(dim))
          let(vector = vector - insetVectorLR)
          _Connectors(diameter, height, count, vector, margin, perpendicular, -alpha, shape, void);
        }
        if (top) {
          let(vector = GetTrapezoidTopEdgeVector(dim))
          let(vector = vector - insetVectorTB)
          _Connectors(diameter, height, count, vector, margin, perpendicular, 0, shape, void);
        }
        if (bottom) {
          let(vector = GetTrapezoidBottomEdgeVector(dim))
          let(vector = vector + insetVectorTB)
          _Connectors(diameter, height, count, vector, margin, perpendicular, 0, shape, void);
        }
      }
    }
  }
}

module _Connectors(diameter, height, count, vector, margin, perpendicular, alpha, shape, void) {
  CopyBetween(vector[0], vector[1], count, margin = margin)
  rotate([0,0,alpha])
  rotate([perpendicular?90:0,0,0])
  Select(["cylinder", "cube", "sphere", "peg"], shape) {
    rotate([90,0,0])
    cylinder(h = height,d = diameter, center = true, $fn = 20);
    
    cube([diameter,height,diameter], center=true);
    
    sphere(d = diameter, $fn = 20);
    
    rotate([-90,0,0])    
    //ends mode does not produce neat height*2 aligned to grid, its easier to just copy&paste
    rotate_copy_x(180)
    connector_peg(radius = diameter/2, height=height/2, void = void, ends = false, spacing = 0.5, $fn=20);
  }
}

module PrettyBoxWall(dimensions, windowBezelThickness = 5, roundingRadius = 5, slopedBezel = true, roundExternal=true, roundInternal=true) {
  let(dim = RectDimensionsToTrapezoidDimensions(dimensions))
  let(
    a = dim[0],
    b = dim[1],
    h = dim[2],
    t = dim[3]
  )
  let(
    x=max(a,b)
  )
  union() {
    BoxWall(
      dimensions = dimensions, 
      windowBezelThickness = windowBezelThickness*(slopedBezel ? 0.5 : 1), 
      roundingRadius = roundingRadius, 
      roundExternal = roundExternal, 
      roundInternal = roundInternal);
    
    if (slopedBezel) {      
      let(dim=RectDimensionsToTrapezoidDimensions(dimensions))
      let(scale=[(x-windowBezelThickness)/x,(h-windowBezelThickness)/h])
      {
        BoxWall(dimensions, windowBezelThickness/2, roundingRadius, scale, roundExternal, roundInternal);
      }      
    }
  }
}

module BoxWall(dimensions, windowBezelThickness = 5, roundingRadius = 0, extrudeScale = [1,1], roundExternal = true, roundInternal = true) {
  let(extrudeConvexity = 10) //fix linear_extrude transparency bug https://github.com/openscad/openscad/issues/3903
  let(dim = RectDimensionsToTrapezoidDimensions(dimensions))
  let(
    a = dim[0],
    b = dim[1],
    h = dim[2],
    t = dim[3]
  )
  let(shell_thickness = windowBezelThickness == undef ? max(dimensions) : windowBezelThickness)
  let(cornerRadiusExternal = roundExternal ? roundingRadius : 0)
  let(cornerRadiusInternal = roundExternal ? roundingRadius : 0)
  linear_extrude(t, center = true, scale = extrudeScale, convexity = extrudeConvexity)
  round_internal(cornerRadiusInternal)
  hollow_out(shell_thickness) 
  polygon(
      shape_trapezium([b, a], 
      h = h,
      corner_r = cornerRadiusExternal)
  );
}

module __Demo() {
  let(windowBezelThickness=5)
  let(dimensions = [60,80,50,5]) {
    WithConnectors(diameter = 1, count=3, trapezoidDimensions=dimensions, shape="sphere", left=true, right=true, insetPercent = 50, void=false)
    WithConnectors(diameter=3,height=2,count=3, trapezoidDimensions=dimensions, shape="cube", top=true, bottom=true, bezelThickness = windowBezelThickness)
    BoxWall(dimensions = dimensions, windowBezelThickness = windowBezelThickness);
    
    translate([0,0,10])
    WithConnectors(diameter = 3, count=3, trapezoidDimensions=dimensions, shape="peg", bottom=true, top=true, void = false, perpendicularInner = true, bezelThickness = windowBezelThickness)
    WithConnectors(diameter = 3, count=3, trapezoidDimensions=dimensions, shape="peg", right=true, left=true, void=true, perpendicularInner = true, bezelThickness = windowBezelThickness)
    PrettyBoxWall(dimensions = dimensions, windowBezelThickness = windowBezelThickness*2);
  }
}
__Demo();