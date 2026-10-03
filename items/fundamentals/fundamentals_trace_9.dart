void main() {
  var a = 1;
  var b = 2;
  var temp = a;
  a = b;
  print('$a $b $temp');
  b = temp;
  print('$a $b $temp');
}
