int sumToA(int n) {
  if (n == 1) {
    return 0;
  }
  return n + sumToA(n - 1);
}

void optionA() {
  print(sumToA(3));
}

int sumToB(int n) {
  if (n > 0) {
    return 0;
  }
  return n + sumToB(n - 1);
}

void optionB() {
  print(sumToB(3));
}

// KEY
int sumToC(int n) {
  if (n == 0) {
    return 0;
  }
  return n + sumToC(n - 1);
}

void optionC() {
  print(sumToC(3));
}
