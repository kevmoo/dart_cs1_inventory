void main() {
  var line = '';
  for (var n = 3; n >= 0; n--) {
    line += '$n ';
  }
  print(line.trim());
}
