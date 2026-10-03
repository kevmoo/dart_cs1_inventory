void optionB() {
  var n = 1;
  var line = '';
  while (n < 20) {
    line += '$n ';
    n++;
  }
  print(line.trim());
}

// KEY
void optionA() {
  var n = 1;
  var line = '';
  while (n < 20) {
    line += '$n ';
    n = n * 2;
  }
  print(line.trim());
}

void optionC() {
  var n = 1;
  var line = '';
  while (n < 20) {
    line += '$n ';
    n = n + 2;
  }
  print(line.trim());
}

void optionD() {
  var n = 1;
  var line = '';
  while (n < 20) {
    line += '$n ';
    n = n * 2 + 1;
  }
  print(line.trim());
}
