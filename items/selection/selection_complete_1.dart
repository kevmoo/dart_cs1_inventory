void optionB() {
  var n = 1;
  if (n > 3) {
    print('B');
  }
  if (n > 1) {
    print('M');
  } else {
    print('S');
  }
  n = 4;
  if (n > 3) {
    print('B');
  }
  if (n > 1) {
    print('M');
  } else {
    print('S');
  }
}

// KEY
void optionA() {
  var n = 1;
  if (n > 3) {
    print('B');
  } else if (n > 1) {
    print('M');
  } else {
    print('S');
  }
  n = 4;
  if (n > 3) {
    print('B');
  } else if (n > 1) {
    print('M');
  } else {
    print('S');
  }
}

void optionC() {
  var n = 1;
  if (n > 3) {
    print('B');
  } else if (n >= 1) {
    print('M');
  } else {
    print('S');
  }
  n = 4;
  if (n > 3) {
    print('B');
  } else if (n >= 1) {
    print('M');
  } else {
    print('S');
  }
}
