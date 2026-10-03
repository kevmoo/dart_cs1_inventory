void main() {
  var temp = 30;
  var humidity = 40;
  print('start');
  if (temp > 25) {
    print('hot');
    if (humidity > 60) {
      print('sticky');
    }
  } else {
    print('mild');
  }
  print('end');
}
