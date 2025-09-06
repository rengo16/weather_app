String conditionToEmoji(String condition) {
  final c = condition.toLowerCase();
  if (c.contains('clear')) return '☀️';
  if (c.contains('cloud')) return '☁️';
  if (c.contains('rain')) return '🌧️';
  if (c.contains('drizzle')) return '🌦️';
  if (c.contains('thunder')) return '⛈️';
  if (c.contains('snow')) return '❄️';
  if (c.contains('mist') || c.contains('fog')) return '🌫️';
  return '🌍';
}
