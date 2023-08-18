use <Helpers.scad>
use <RoundedShapes.scad>
use <GeometryHelpers.scad>
use <CopyPaste.scad>
use <dotSCAD/src/hollow_out.scad>
use <dotSCAD/src/shape_trapezium.scad>

module WithMagnetHoles(diameter, height, count, walllDimensions, windowBezelThickness, shape = "cylinder", studsInsteadOfMagnets = false, bottom = false, left = false, right = false, cornerMargin = 0, insetPercent = -50, perpendicular = false, condition = true) {
  UnionOrDiff(union = studsInsteadOfMagnets) {
    children();
    if (condition) {
      let(isSide = left || right)
      let(dim = RectDimensionsToTrapezoidDimensions(walllDimensions))
      let(
        a = dim[0],
        b = dim[1],
        h = dim[2],
        t = dim[3],
        alpha = TrapezoidSideAngle(a, b, h)
      )
      //fix angle for upside-down trapezoid
      let(alpha = a >= b ? alpha : (180-alpha))
            
      let(inset = ((shape=="sphere"?diameter/2:height)*insetPercent/100))
      
      //position top or bottom
      let(y = dim[2]/2)
      let(y = y - (perpendicular ? (windowBezelThickness/2) : inset))
      let(y = bottom ? -y : y)
      
      //select top or bottom edge
      let(x = bottom ? dim[0] : dim[1])
      //don't place holes on curved corners
      let(x = x/2 - cornerMargin)
      let(z = perpendicular ? -inset : 0)
      
      //hole needs to fit whole magnet
      let(height=height*2)      
            
      translate([0,0,perpendicular ? dim[3]/2 : 0])
      //spread holes along edge
      CopyBetween([-x,y,z], [x,y,z], count)
      rotate([perpendicular?90:0,0,0])
      Select(["cylinder", "cube", "sphere"], shape) {
        rotate([90,0,0])
        cylinder(h = height,d = diameter, center = true, $fn = 20);
        cube([diameter,height,diameter], center=true);
        sphere(d = diameter, $fn = 20);
      }
    }
  }
}

module WithConnectorPegs(hole = false) {
  //TODO implement construction pegs for printing vertical walls separately from bases
}

module WithConnectorSlit() {
  //TODO implement construction slit for printing vertical walls separately from bases
}

module PartialWall(segmentLocation = [], withPegs = true) {
  //TODO implement segmented wall for smaller build plate, allowing for single-piece connection surfaces to vertical walls
}

module WithPressClip(dimensions, clipSizePercent = 0.3, clipCount = 3, clipShape = "ball", clipInset = 0.5, hole = false, condition = true) {
  if (condition) {
    let(dim = RectDimensionsToTrapezoidDimensions(dimensions))
    let(
      a = dim[0],
      b = dim[1],
      h = dim[2],
      t = dim[3],
      alpha = TrapezoidSideAngle(a, b, h),
      d = TrapezoidTriangleLength(a, b),
      c = TrapezoidSideLength(a,b,h),
      clipOffset = [-(min(a,b)/2+d/2),0,0]
    )
    //fix angle for upside-down trapezoid
    let(alpha= a >= b ? alpha : (180-alpha))
    let(clipSize = t*clipSizePercent)
    UnionOrDiff(union = !hole) {
      children();
      mirror_copy_x()
      translate(clipOffset)
      PressClip(c, alpha, clipSize, clipCount, clipShape, clipInset);
    }
  }
}

module PressClip(length, angle, size, count, shape = "ball", inset = 0.5) {
  let(offset=size*(inset-0.5))
  rotate([0,0,angle])
  let(from=[-length/2,-offset,0])
  let(to=[length/2,-offset,0])
  CopyBetween(from,to,count)
  sphere(d = size, $fn=20);
}

module PrettyBoxWall(dimensions, windowBezelThickness = 5, roundingRadius = 5, slopedBezel = true, roundExternal=true, roundInternal=true) {
  union() {
    BoxWall(
      dimensions = dimensions, 
      windowBezelThickness = windowBezelThickness*(slopedBezel ? 0.5 : 1), 
      roundingRadius = roundingRadius, 
      roundExternal = roundExternal, 
      roundInternal = roundInternal);
    
    if (slopedBezel) {      
      let(dim=RectDimensionsToTrapezoidDimensions(dimensions))
      let(scale=[(dim[0]-windowBezelThickness)/dim[0],(dim[2]-windowBezelThickness)/dim[2]])
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
      shape_trapezium([a, b], 
      h = h,
      corner_r = cornerRadiusExternal)
  );
}

module __Demo() {
  let(windowBezelThickness=5)
  let(dimensions = [80,60,50,5]) {
    WithMagnetHoles(3,2,3, dimensions, shape="cube", bottom=true)
    WithPressClip(dimensions, hole = true)
    BoxWall(dimensions = dimensions, windowBezelThickness = windowBezelThickness);
    
    translate([0,0,10])
    //for top/bottom plate
    WithMagnetHoles(3,2,3, dimensions, perpendicular = true, bottom = false, shape="sphere", windowBezelThickness = windowBezelThickness)
    WithMagnetHoles(3,2,3, dimensions, perpendicular = true, bottom = true, shape="sphere", windowBezelThickness = windowBezelThickness)
    //for walls
    WithMagnetHoles(3,2,3, dimensions, perpendicular = false, bottom=false, shape="cube", windowBezelThickness = windowBezelThickness)
    WithMagnetHoles(3,2,3, dimensions, perpendicular = false, bottom=true, shape="cube", windowBezelThickness = windowBezelThickness)
    //press-fit clip
    WithPressClip(dimensions, hole = false)
    PrettyBoxWall(dimensions = dimensions, windowBezelThickness = windowBezelThickness*2);
  }
}
__Demo();