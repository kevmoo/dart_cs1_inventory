class Counter {
  int count;

  Counter(this.count);

  void bump() {
    count += 1;
  }
}

void main() {
  var a = Counter(5);
  var b = a;
  var c = Counter(5);
  b.bump();
  print('${a.count} ${b.count} ${c.count}');
}

// The brief forbids primary constructors in student-facing code.
