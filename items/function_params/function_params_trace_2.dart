void change(int n, List<int> items) {
  n = n + 1;
  items[0] = n;
}

void main() {
  var n = 5;
  var items = [1, 2];
  change(n, items);
  print(n);
  print(items);
}
