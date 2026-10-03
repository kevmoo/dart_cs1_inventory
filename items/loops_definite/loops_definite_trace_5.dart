void main() {
  var total = 0;
  for (var i = 1; i <= 6; i++) {
    if (i % 3 == 0) {
      continue;
    }
    total += i;
  }
  print(total);
}
