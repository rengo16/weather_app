import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../providers/weather_notifier.dart';
import '../utils/emoji.dart';
import '../../providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final st = ref.read(weatherNotifierProvider);
      if (st.lastCity.isNotEmpty) {
        _controller.text = st.lastCity;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(weatherNotifierProvider);
    final notifier = ref.read(weatherNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App 🌤️'),
        actions: [
          IconButton(
            tooltip: state.useCelsius ? "Switch to °F" : "Switch to °C",
            icon: Text(state.useCelsius ? '°C' : '°F', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () async {
              await notifier.toggleUnit();
              
              final newState = ref.read(weatherNotifierProvider);
              if (newState.lastCity.isNotEmpty) _controller.text = newState.lastCity;
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(weatherNotifierProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => _performSearch(),
                decoration: const InputDecoration(
                  labelText: 'City name',
                  hintText: 'e.g. Cairo, London, New York',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _performSearch,
                      icon: const Icon(Icons.search),
                      label: const Text('Search'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildResultArea(state),
              const SizedBox(height: 40),
              const Text('Pull down to refresh the last searched city'),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch() {
    final city = _controller.text.trim();
    if (city.isEmpty) {
      _showSnack('Please enter a city name');
      return;
    }
    ref.read(weatherNotifierProvider.notifier).fetch(city);
  }

  Widget _buildResultArea(WeatherState state) {
    switch (state.status) {
      case WeatherStatus.initial:
        return const Center(child: Text('Enter a city and press Search'));
      case WeatherStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case WeatherStatus.error:
        return Column(
          children: [
            Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (state.lastCity.isNotEmpty) {
                  ref.read(weatherNotifierProvider.notifier).fetch(state.lastCity);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        );
      case WeatherStatus.success:
        final w = state.weather!;
        final emoji = conditionToEmoji(w.condition);
        final unitSymbol = state.useCelsius ? '°C' : '°F';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(w.city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (w.iconCode.isNotEmpty)
              Image.network(
                AppConstants.iconUrl(w.iconCode),
                width: 100,
                height: 100,
                errorBuilder: (_, __, ___) => Text(emoji, style: const TextStyle(fontSize: 48)),
              )
            else
              Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text('${w.temperature.toStringAsFixed(1)} $unitSymbol', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(w.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(w.condition, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        );
    }
  }
}
