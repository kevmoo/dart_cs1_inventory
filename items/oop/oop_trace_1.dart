class Counter {
  int count;

  Counter(this.count);

  void bump() {
    count += 1;
  }
}

void main() {
  var a = Counter(0);
  var b = Counter(10);
  a.bump();
  a.bump();
  b.bump();
  print('${a.count} ${b.count}');
}

// The brief forbids primary constructors in student-facing code.
