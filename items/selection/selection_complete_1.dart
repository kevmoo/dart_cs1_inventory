void optionA() {
  var line = '';
  for (var n = 1; n <= 5; n++) {
    if (n > 3) {
      line += 'B';
    }
    if (n > 1) {
      line += 'M';
    } else {
      line += 'S';
    }
  }
  print(line);
}

// KEY
void optionB() {
  var line = '';
  for (var n = 1; n <= 5; n++) {
    if (n > 3) {
      line += 'B';
    } else if (n > 1) {
      line += 'M';
    } else {
      line += 'S';
    }
  }
  print(line);
}

void optionC() {
  var line = '';
  for (var n = 1; n <= 5; n++) {
    if (n > 3) {
      line += 'B';
    } else if (n >= 1) {
      line += 'M';
    } else {
      line += 'S';
    }
  }
  print(line);
}
