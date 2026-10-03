void main() {
  var count = 0;
  for (var row = 1; row <= 3; row++) {
    for (var col = 1; col <= row; col++) {
      count++;
    }
  }
  print(count);
}
