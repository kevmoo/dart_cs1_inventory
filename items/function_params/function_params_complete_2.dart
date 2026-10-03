void showRange(int start, int size) {
  print(start);
  print(start + size);
}

void optionA() {
  var size = 2;
  var start = 7;
  showRange(size, start);
}

// KEY
void optionB() {
  var size = 2;
  var start = 7;
  showRange(start, size);
}

void optionD() {
  var size = 2;
  var start = 7;
  showRange(start, 9);
}

// Option c, `showRange(start)`, does not compile
// (not_enough_positional_arguments) and is omitted.
