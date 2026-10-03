void main() {
  var n = 20;
  var steps = 0;
  while (n > 1) {
    n = n ~/ 2;
    steps++;
  }
  print('$steps $n');
}
