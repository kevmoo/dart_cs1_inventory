// KEY
void optionA() {
  var count = 0;
  for (var n = 0; n <= 11; n++) {
    if (n >= 1 && n <= 10) {
      count++;
    }
  }
  print(count);
}

void optionB() {
  var count = 0;
  for (var n = 0; n <= 11; n++) {
    if (n >= 1 || n <= 10) {
      count++;
    }
  }
  print(count);
}

void optionC() {
  var count = 0;
  for (var n = 0; n <= 11; n++) {
    if (n > 1 && n < 10) {
      count++;
    }
  }
  print(count);
}
