void walk(int n) {
  if (n == 0) {
    return;
  }
  print('down $n');
  walk(n - 1);
  print('up $n');
}

void main() {
  walk(2);
}
