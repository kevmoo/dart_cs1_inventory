// KEY
void optionA() {
  for (var i = 1; i <= 3; i++) {
    var row = '';
    for (var j = 1; j <= i; j++) {
      row += '*';
    }
    print(row);
  }
}

void optionB() {
  for (var i = 1; i <= 3; i++) {
    var row = '';
    for (var j = 1; j < i; j++) {
      row += '*';
    }
    print(row);
  }
}

void optionC() {
  for (var i = 1; i <= 3; i++) {
    var row = '';
    for (var j = 1; j <= 3; j++) {
      row += '*';
    }
    print(row);
  }
}

void optionD() {
  for (var i = 1; i <= 3; i++) {
    var row = '';
    for (var j = 1; j <= i + 1; j++) {
      row += '*';
    }
    print(row);
  }
}
