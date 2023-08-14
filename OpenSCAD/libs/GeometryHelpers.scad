
function RectDimensionsToTrapezoidDimensions(dimensions) = [
  dimensions[0],
  dimensions[3] == undef ? dimensions[0] : dimensions[1],
  dimensions[3] == undef ? dimensions[1] : dimensions[2],
  dimensions[3] == undef ? dimensions[2] : dimensions[3]
  ];