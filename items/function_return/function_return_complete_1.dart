// KEY
int squareD(int n) {
  return n * n;
}

void optionD() {
  var result = squareD(3);
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

int squareB(int n) {
  n * n;
  return n;
}

void optionB() {
  var result = squareB(3);
  print(result);
}

// Option d's bare `n * n;` is the misconception under test.
