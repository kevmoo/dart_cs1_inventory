int twice(int n) {
  return n * 2;
}

int addOne(int n) {
  return n + 1;
}

void main() {
  var x = addOne(twice(3));
  print(x);
  print(twice(addOne(x)));
}
