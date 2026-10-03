void main() {
  var temp = 12;
  var sunny = temp > 0;
  var warm = temp > 20;
  print(!sunny && warm);
  print(!(sunny && warm));
  print(!sunny || !warm);
}
