int firstBig(List<int> items) {
  for (var n in items) {
    if (n > 10) {
      return n;
    }
  }
  return -1;
}

void main() {
  print(firstBig([3, 12, 20, 5]));
}
