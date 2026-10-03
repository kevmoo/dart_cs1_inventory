void main() {
  var a = [1, 2, 3];
  var b = a;
  b[0] = 9;
  a[2] = 5;
  print(a);
  print(b);
}
