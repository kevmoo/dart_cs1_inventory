class Tank {
  int liters;

  Tank(this.liters);

  int doubled() {
    return liters * 2;
  }

  void add(int amount) {
    liters += amount;
  }
}

void main() {
  var t = Tank(5);
  print(t.doubled());
  print(t.doubled());
  t.add(3);
  print('${t.liters} ${t.doubled()}');
}

// The brief forbids primary constructors in student-facing code.
