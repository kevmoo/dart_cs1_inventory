void optionA() {
  var line = '';
  for (var i = 1; i < 5; i++) {
    line += '$i ';
  }
  print(line.trim());
}

// KEY
void optionB() {
  var line = '';
  for (var i = 1; i <= 5; i++) {
    line += '$i ';
  }
  print(line.trim());
}

void optionC() {
  var line = '';
  for (var i = 1; i <= 6; i++) {
    line += '$i ';
  }
  print(line.trim());
}

void optionD() {
  var line = '';
  for (var i = 1; i == 5; i++) {
    line += '$i ';
  }
  print(line.trim());
}
