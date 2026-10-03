void show(int x, int y) {
  print('$x $y');
}

void main() {
  var y = 1;
  var x = 4;
  show(y, x + 1);
  show(x, y);
}
