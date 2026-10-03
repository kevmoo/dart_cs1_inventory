void between(int low, int high) {
  var line = '';
  for (var i = low; i <= high; i++) {
    line += '$i ';
  }
  print(line.trim());
}

void optionA() {
  var high = 4;
  var low = 2;
  between(high, low);
}

// KEY
void optionC() {
  var high = 4;
  var low = 2;
  between(low, high);
}

void optionD() {
  var high = 4;
  var low = 2;
  between(low, high + 1);
}
