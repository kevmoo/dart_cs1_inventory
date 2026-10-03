// KEY
class CounterA {
  int count;

  CounterA(this.count);

  void bump() {
    this.count += 1;
  }
}

void optionA() {
  var c = CounterA(3);
  c.bump();
  c.bump();
  print(c.count);
}

class CounterB {
  int count;

  CounterB(this.count);

  void bump() {
    var count = this.count + 1;
  }
}

void optionB() {
  var c = CounterB(3);
  c.bump();
  c.bump();
  print(c.count);
}

class CounterC {
  int count;

  CounterC(this.count);

  void bump() {
    print(count + 1);
  }
}

void optionC() {
  var c = CounterC(3);
  c.bump();
  c.bump();
  print(c.count);
}

// The brief forbids primary constructors in student-facing code; `this.count`
// and the dead local in option b are the misconceptions under test.
