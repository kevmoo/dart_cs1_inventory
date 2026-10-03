class Box {
  int width;
  int height;

  Box(this.height, this.width);
}

void main() {
  var a = Box(2, 5);
  var b = Box(7, 1);
  print('${a.width} ${a.height}');
  print('${b.width} ${b.height}');
}

// The brief forbids primary constructors in student-facing code.
