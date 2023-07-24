module copypaste(method, vector, copy=true, condition=true) {
  if (condition) {
    if (method == "mirror") {
      mirror(vector)
      children();
    }
    if (method == "rotate") {
      rotate(vector)
      children();
    }
    if (method == "translate") {
      translate(vector)
      children();
    }
    if (copy) {
      children();
    }
  } else {
    children();
  }
}
module mirror_copy(vector, copy=true, condition=true) {
  copypaste("mirror", vector, copy, condition)
  children();
}
module rotate_copy(vector, copy=true, condition=true) {
  copypaste("rotate", vector, copy, condition)
  children();
}
module translate_copy(vector, copy=true, condition=true) {
  copypaste("translate", vector, copy, condition)
  children();
}

module mirror_copy_x(copy=true, condition=true) {
  mirror_copy([1,0,0], copy, condition)
  children();
}
module mirror_copy_y(copy=true, condition=true) {
  mirror_copy([0,1,0], copy, condition)
  children()
  ;
}
module mirror_copy_z(copy=true, condition=true) {
  mirror_copy([0,0,1], copy, condition)
  children();
}

module rotate_copy_x(angle, copy=true, condition=true) {
  rotate_copy([angle,0,0], copy, condition)
  children();
}
module rotate_copy_y(angle, copy=true, condition=true) {
  rotate_copy([0,angle,0], copy, condition)
  children();
}
module rotate_copy_z(angle, copy=true, condition=true) {
  rotate_copy([0,0,angle], copy, condition)
  children();
}

module translate_copy_x(offset, copy=true, condition=true) {
  translate_copy([offset,0,0], copy, condition)
  children();
}
module translate_copy_y(offset, copy=true, condition=true) {
  translate_copy([0,offset,0], copy, condition)
  children();
}
module translate_copy_z(offset, copy=true, condition=true) {
  translate_copy([0,0,offset], copy, condition)
  children();
}