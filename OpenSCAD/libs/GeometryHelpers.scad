//returns [a,b,height,thickness]
function RectDimensionsToTrapezoidDimensions(dimensions) = [
  dimensions[0],
  dimensions[3] == undef ? dimensions[0] : dimensions[1],
  dimensions[3] == undef ? dimensions[1] : dimensions[2],
  dimensions[3] == undef ? dimensions[2] : dimensions[3]
  ];
  
function TrapezoidTriangleLength(a,b) = (abs(a-b)/2);
function TrapezoidSideLength(a,b,h) = sqrt(TrapezoidTriangleLength(a,b)^2+h^2);
function TrapezoidSideAngle(a,b,h) = atan(h/ TrapezoidTriangleLength(a,b));

module __Demo() {
  let(dim = RectDimensionsToTrapezoidDimensions([80,70,60,5])) {
    text(str(dim));
    translate([0,-20,0])
    text(str(TrapezoidTriangleLength(dim[0], dim[2])));
    translate([0,-40,0])
    text(str(TrapezoidSideLength(dim[0], dim[1], dim[2])));
    translate([0,-60,0])
    text(str(TrapezoidSideAngle(dim[0], dim[1], dim[2])));
  }
}
%__Demo();