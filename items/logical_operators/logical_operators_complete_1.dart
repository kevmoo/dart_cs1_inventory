// KEY
void optionA() {
  var n = 0;
  if (n >= 1 && n <= 10) {
    print('$n in');
  }
  n = 5;
  if (n >= 1 && n <= 10) {
    print('$n in');
  }
  n = 10;
  if (n >= 1 && n <= 10) {
    print('$n in');
  }
}

void optionB() {
  var n = 0;
  if (n >= 1 || n <= 10) {
    print('$n in');
  }
  n = 5;
  if (n >= 1 || n <= 10) {
    print('$n in');
  }
  n = 10;
  if (n >= 1 || n <= 10) {
    print('$n in');
  }
}

void optionC() {
  var n = 0;
  if (n > 1 && n < 10) {
    print('$n in');
  }
  n = 5;
  if (n > 1 && n < 10) {
    print('$n in');
  }
  n = 10;
  if (n > 1 && n < 10) {
    print('$n in');
  }
}
