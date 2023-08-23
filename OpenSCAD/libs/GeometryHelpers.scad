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

function GetTrapezoidCornersClockwise(dim) =
let(dim = RectDimensionsToTrapezoidDimensions(dim))
let(
  a = dim[0],
  b = dim[1],
  h = dim[2]
)
[
  [a/2,h/2,0],
  [b/2,-h/2,0],
  [-b/2,-h/2,0],
  [-a/2,h/2,0]
];

function GetTrapezoidRightEdgeVector(dim) =
let(corners = GetTrapezoidCornersClockwise(dim))
[
  corners[0],
  corners[1]
];
function GetTrapezoidBottomEdgeVector(dim) =
let(corners = GetTrapezoidCornersClockwise(dim))
[
  corners[1],
  corners[2]
];
function GetTrapezoidLeftEdgeVector(dim) =
let(corners = GetTrapezoidCornersClockwise(dim))
[
  corners[2],
  corners[3]
];
function GetTrapezoidTopEdgeVector(dim) =
let(corners = GetTrapezoidCornersClockwise(dim))
[
  corners[3],
  corners[0]
];

module line(vector, thickness = 1) {
    hull() {
        translate(vector[0]) sphere(thickness);
        translate(vector[1]) sphere(thickness);
    }
}

module __Demo() {
  let(dim = RectDimensionsToTrapezoidDimensions([60,80,60,5])) {
    text(str(dim));
    translate([0,-20,0])
    text(str(TrapezoidTriangleLength(dim[0], dim[2])));
    translate([0,-40,0])
    text(str(TrapezoidSideLength(dim[0], dim[1], dim[2])));
    translate([0,-60,0])
    text(str(TrapezoidSideAngle(dim[0], dim[1], dim[2])));
      
    translate([0,0,-20]) {
        color("red")
        line(GetTrapezoidRightEdgeVector(dim));
        color("green")
        line(GetTrapezoidLeftEdgeVector(dim));
        color("blue")
        line(GetTrapezoidTopEdgeVector(dim));
        color("yellow")
        line(GetTrapezoidBottomEdgeVector(dim));
    }
  }
}
%__Demo();