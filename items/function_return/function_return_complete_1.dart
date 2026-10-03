// KEY
int squareB(int n) {
  return n * n;
}

void optionB() {
  var result = squareB(3);
  print(result);
}

int squareC(int n) {
  print(n * n);
  return n;
}

void optionC() {
  var result = squareC(3);
  print(result);
}

int squareD(int n) {
  n * n;
  return n;
}

void optionD() {
  var result = squareD(3);
  print(result);
}

// Option d's bare `n * n;` is the misconception under test.
