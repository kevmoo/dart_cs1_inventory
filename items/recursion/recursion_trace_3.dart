int sumFrom(List<int> items, int i) {
  if (i == items.length) {
    return 0;
  }
  return items[i] + sumFrom(items, i + 1);
}

void main() {
  print(sumFrom([4, 5, 6], 1));
}
