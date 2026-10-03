void main() {
  var data = [4, 7, -1, 9, 3];
  var i = 0;
  var sum = 0;
  while (true) {
    var x = data[i];
    if (x < 0) break;
    sum += x;
    i++;
  }
  print('$i $sum');
}
