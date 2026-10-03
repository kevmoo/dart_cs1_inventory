void main() {
  var count = 10;
  do {
    print('tick $count');
    count = count + 1;
  } while (count < 5);
  print('done $count');
}
