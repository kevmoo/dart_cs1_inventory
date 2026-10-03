void main() {
  var count = 0;
  for (var i = 1; i <= 4; i++) {
    for (var j = 1; j <= i; j++) {
      count++;
    }
  }
  print(count);
}
