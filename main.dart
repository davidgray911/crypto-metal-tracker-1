import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';



void main() {
  runApp(CryptoMetalTrackerApp());
}

class CryptoMetalTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Metal Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CryptoScreen(),
    MetalsScreen(),
    CurrencyConverterScreen(),
    TicTacToeScreen(),
  ];

  final List<String> _titles = [
    'Kryptowaluty',
    'Metale Szlachetne',
    'Kursy Walut',
    'Click Game',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Krypto',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.precision_manufacturing),
            label: 'Metale',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Kursy Walut',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gamepad),
            label: 'Gra',
          ),
        ],
      ),
    );
  }
}

// Ekran Kryptowalut
class CryptoScreen extends StatefulWidget {
  @override
  _CryptoScreenState createState() => _CryptoScreenState();
}

class _CryptoScreenState extends State<CryptoScreen> {
  List<dynamic> _cryptoList = [];
  List<dynamic> _favorites = [];
  String _searchQuery = '';
  Map<String, dynamic>? _searchResult;
  bool _isLoading = true;
  bool _showFavorites = false;

  @override
  void initState() {
    super.initState();
    _fetchCryptoPrices();
  }

  Future<void> _fetchCryptoPrices() async {
    const String apiUrl =
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          _cryptoList = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print('Błąd pobierania danych: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchCrypto() {
    final crypto = _cryptoList.firstWhere(
          (element) => element['name'].toLowerCase() == _searchQuery.toLowerCase(),
      orElse: () => null,
    );
    setState(() {
      _searchResult = crypto;
    });
  }

  void _toggleFavorite(dynamic crypto) {
    setState(() {
      if (_favorites.contains(crypto)) {
        _favorites.remove(crypto);
      } else {
        _favorites.add(crypto);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final listToShow = _showFavorites ? _favorites : _cryptoList;

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Center(
              child: StreamBuilder(
                stream: Stream.periodic(Duration(seconds: 1)),
                builder: (context, snapshot) {
                  final now = DateTime.now();
                  return Text(
                    "${now.toLocal()}".split('.')[0],
                    style: TextStyle(color: Colors.amber, fontSize: 18),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Wpisz nazwę kryptowaluty',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                    },
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _searchCrypto,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Szukaj',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showFavorites = !_showFavorites;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showFavorites
                        ? Colors.amber
                        : Colors.grey[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    _showFavorites
                        ? 'Pokaż Wszystkie'
                        : 'Ulubione kryptowaluty',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_searchResult != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    _searchResult!['image'],
                    height: 30,
                    width: 30,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Cena: \$${_searchResult!['current_price']}",
                    style: TextStyle(color: Colors.amber, fontSize: 18),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
                : ListView.builder(
              itemCount: listToShow.length,
              itemBuilder: (context, index) {
                final crypto = listToShow[index];
                final isFavorite = _favorites.contains(crypto);
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: Image.network(
                      crypto['image'],
                      height: 40,
                      width: 40,
                    ),
                    title: Text(
                      crypto['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '\$${crypto['current_price'].toString()}',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.star
                                : Icons.star_border,
                            color: isFavorite
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          onPressed: () =>
                              _toggleFavorite(crypto),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.show_chart,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CryptoChartScreen(
                                      cryptoId: crypto['id'],
                                      cryptoName: crypto['name'],
                                    ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Wykres kryptowalut
class CryptoChartScreen extends StatelessWidget {
  final String cryptoId;
  final String cryptoName;

  CryptoChartScreen({required this.cryptoId, required this.cryptoName});

  Future<List<FlSpot>> _fetchChartData() async {
    final String apiUrl =
        'https://api.coingecko.com/api/v3/coins/$cryptoId/market_chart?vs_currency=usd&days=7';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> prices = data['prices'];
        return prices
            .asMap()
            .entries
            .map((entry) =>
            FlSpot(entry.key.toDouble(), entry.value[1].toDouble()))
            .toList();
      } else {
        throw Exception('Błąd podczas pobierania danych wykresu');
      }
    } catch (e) {
      print('Błąd: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$cryptoName - Wykres'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FlSpot>>(
        future: _fetchChartData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Nie udało się załadować wykresu.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final data = snapshot.data ?? [];
            if (data.isEmpty) {
              return Center(
                child: Text(
                  'Brak danych dla wykresu.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(showTitles: true),
                    bottomTitles: SideTitles(showTitles: false),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  minX: 0,
                  maxX: data.length.toDouble(),
                  minY: data.map((spot) => spot.y).reduce((a, b) => a < b ? a : b),
                  maxY: data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b),
                  lineBarsData: [
                    LineChartBarData(
                      spots: data,
                      isCurved: true,
                      colors: [Colors.amber],
                      barWidth: 2,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// Placeholder dla innych ekranów

class MetalsScreen extends StatefulWidget {
  @override
  _MetalsScreenState createState() => _MetalsScreenState();
}

class _MetalsScreenState extends State<MetalsScreen> {
  Map<String, double> _metalPrices = {};
  bool _isLoading = true;

  final TextEditingController _gramsController = TextEditingController();
  String _selectedMetal = 'Złoto';
  double _calculatedValue = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMetalPrices();
  }

  Future<void> _fetchMetalPrices() async {
    const String apiKey = 'goldapi-jti2sm6dts0jo-io';
    const String baseUrl = 'https://www.goldapi.io/api';

    try {
      final responseGold = await http.get(
        Uri.parse('$baseUrl/XAU/USD'),
        headers: {'x-access-token': apiKey, 'Content-Type': 'application/json'},
      );

      final responseSilver = await http.get(
        Uri.parse('$baseUrl/XAG/USD'),
        headers: {'x-access-token': apiKey, 'Content-Type': 'application/json'},
      );

      final responsePlatinum = await http.get(
        Uri.parse('$baseUrl/XPT/USD'),
        headers: {'x-access-token': apiKey, 'Content-Type': 'application/json'},
      );

      final responsePalladium = await http.get(
        Uri.parse('$baseUrl/XPD/USD'),
        headers: {'x-access-token': apiKey, 'Content-Type': 'application/json'},
      );

      if (responseGold.statusCode == 200 &&
          responseSilver.statusCode == 200 &&
          responsePlatinum.statusCode == 200 &&
          responsePalladium.statusCode == 200) {
        final goldData = json.decode(responseGold.body);
        final silverData = json.decode(responseSilver.body);
        final platinumData = json.decode(responsePlatinum.body);
        final palladiumData = json.decode(responsePalladium.body);

        setState(() {
          _metalPrices = {
            'Złoto': goldData['price'] ?? 0.0,
            'Srebro': silverData['price'] ?? 0.0,
            'Platyna': platinumData['price'] ?? 0.0,
            'Pallad': palladiumData['price'] ?? 0.0,
          };
          _isLoading = false;
        });
      } else {
        _handleApiError();
      }
    } catch (e) {
      _handleApiError();
    }
  }

  void _handleApiError() {
    setState(() {
      _metalPrices = {};
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Nie udało się pobrać danych. Sprawdź API.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kurs Metali Szlachetnych za 1 oz',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.amber))
          : _metalPrices.isEmpty
          ? Center(
        child: Text(
          'Brak danych do wyświetlenia.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: _metalPrices.entries.map((entry) {
                return Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '\$${entry.value.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24),
            Divider(color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Przelicz wartość metalu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedMetal,
              isExpanded: true,
              alignment: Alignment.center,
              items: _metalPrices.keys.map((metal) {
                return DropdownMenuItem(
                  value: metal,
                  child: Center(child: Text(metal)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMetal = value!;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              controller: _gramsController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Wprowadź ilość gramów',
                labelStyle: TextStyle(fontSize: 16),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final grams =
                    double.tryParse(_gramsController.text) ?? 0.0;
                final pricePerOunce =
                    _metalPrices[_selectedMetal] ?? 0.0;
                final pricePerGram = pricePerOunce / 31.1035;
                setState(() {
                  _calculatedValue = grams * pricePerGram;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: EdgeInsets.symmetric(
                    vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'PRZELICZ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Wartość: \$${_calculatedValue.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CurrencyConverterScreen extends StatefulWidget {
  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  TextEditingController _amountController = TextEditingController();
  String _fromCurrency = 'USD';
  String _toCurrency = 'PLN';
  double _convertedAmount = 0.0;
  Map<String, double> _exchangeRates = {};
  bool _isLoading = true;

  // Lista dostępnych walut
  List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'AUD',
    'CAD',
    'CHF',
    'JPY',
    'CNY',
    'INR',
    'MXN',
    'BRL',
    'SEK',
    'NZD',
    'SGD',
    'PLN',
    'KRW',
    'ZAR',
    'TRY',
    'CZK',
    'HKD'
  ];

  // Lista wybranych walut do wyświetlenia na dole
  final List<String> _selectedCurrencies = ['USD', 'EUR', 'GBP', 'CZK', 'CHF'];

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    const String apiUrl =
        'https://api.frankfurter.app/latest?from=PLN'; // Pobieramy kursy względem PLN
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _exchangeRates = Map<String, double>.from(data['rates']);
          _isLoading = false;
        });
      } else {
        print('Błąd pobierania danych: ${response.statusCode}');
      }
    } catch (e) {
      print('Błąd: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) {
      setState(() {
        _convertedAmount = 0.0;
      });
      return;
    }

    double amount = double.parse(_amountController.text);
    double fromRate = _exchangeRates[_fromCurrency] ?? 1.0; // Kurs waluty źródłowej względem PLN
    double toRate = _exchangeRates[_toCurrency] ?? 1.0; // Kurs waluty docelowej względem PLN

    setState(() {
      _convertedAmount = amount * (toRate / fromRate); // Przeliczanie waluty
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalkulator Walut'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Wyśrodkowany napis "Kwota" nad polem tekstowym
            Text(
              'Kwota',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // Pole tekstowe na kwotę (wyśrodkowane)
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center, // Wartości wpisywane na środku
              style: TextStyle(color: Colors.white, fontSize: 20),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            SizedBox(height: 24),
            // Sekcja wyboru walut (obok siebie z "na" między nimi)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dropdown z walutą źródłową
                Expanded(
                  child: DropdownButton<String>(
                    value: _fromCurrency,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _fromCurrency = newValue!;
                      });
                    },
                    items: currencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                  ),
                ),
                // Tekst "na"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'na',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                // Dropdown z walutą docelową
                Expanded(
                  child: DropdownButton<String>(
                    value: _toCurrency,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        _toCurrency = newValue!;
                      });
                    },
                    items: currencies
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Center(child: Text(value)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Przycisk "Przelicz"
            Center(
              child: ElevatedButton(
                onPressed: _convertCurrency,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Przelicz',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            // Wynik przeliczenia
            Center(
              child: Text(
                _convertedAmount > 0
                    ? 'Wynik: ${_convertedAmount.toStringAsFixed(2)} $_toCurrency'
                    : 'Proszę podać kwotę',
                style: TextStyle(color: Colors.amber, fontSize: 22),
              ),
            ),
            SizedBox(height: 32),
            // Sekcja wybranych walut
            Text(
              'Aktualne kursy:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _selectedCurrencies.length,
                itemBuilder: (context, index) {
                  final currency = _selectedCurrencies[index];
                  final rate = _exchangeRates[currency] ?? 0.0;
                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(
                        '1 $currency = ${(1 / rate).toStringAsFixed(4)} PLN',
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicTacToeScreen extends StatefulWidget {
  @override
  State<TicTacToeScreen> createState() => _TicTacToeScreenState();
}

class _TicTacToeScreenState extends State<TicTacToeScreen> {
  int _counter = 0;
  int _timerSeconds = 10; // Reset po 10 sekundach
  bool _isTimerRunning = false;
  Color _buttonColor = Colors.blue;
  List<int> _topScores = [0, 0, 0];
  final Random _random = Random(); // Generator losowych liczb

  void _incrementCounter() {
    if (!_isTimerRunning) {
      _startTimer();
      setState(() {
        _isTimerRunning = true;
      });
    }

    setState(() {
      _counter++;
      _buttonColor = _generateRandomColor();
    });
  }

  void _resetGame() {
    setState(() {
      _updateTopScores();
      _counter = 0;
      _timerSeconds = 10; // Restartuj czas
      _isTimerRunning = false;
    });
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds <= 0) {
        timer.cancel();
        _resetGame(); // Resetuj grę po zakończeniu czasu
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _updateTopScores() {
    _topScores.sort((a, b) => b.compareTo(a));
    for (int i = 0; i < _topScores.length; i++) {
      if (_counter > _topScores[i]) {
        _topScores[i] = _counter;
        break;
      }
    }
  }

  Color _generateRandomColor() {
    return Color.fromARGB(
      255,
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Odstrestuj się ;)'),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40), // Odstęp od góry
            Text(
              'Pozostały czas: $_timerSeconds s',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Wynik: $_counter',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 50), // Odstęp dla dużego przycisku
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 250, // Duży rozmiar przycisku
              height: 250,
              decoration: BoxDecoration(
                color: _buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _buttonColor.withOpacity(0.6),
                    blurRadius: 25,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: TextButton(
                onPressed: _incrementCounter,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                child: const Text(
                  'Kliknij mnie!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50), // Odstęp od przycinkach
            const Text(
              'Najlepsze wyniki:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            for (int i = 0; i < _topScores.length; i++)
              Text(
                '${i + 1}. ${_topScores[i]} kliknięć',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.amber,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
