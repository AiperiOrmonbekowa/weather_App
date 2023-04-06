class ApiConst {
  static String address(String name) =>
      'https://api.openweathermap.org/data/2.5/weather?q=$name&appid=2dadb31a8f4956aa5426d59e3884dde5';
  static String getLocator(double lat, double long) =>
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$long&appid=2dadb31a8f4956aa5426d59e3884dde5';

  static String getIcon(String iconCode, int size) {
    return 'https://openweathermap.org/img/wn/$iconCode@${size}x.png';
  }
}
