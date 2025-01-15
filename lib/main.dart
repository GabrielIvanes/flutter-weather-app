import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/views/favorite_page.dart';
import 'package:weather_app/views/home_page.dart';
import 'package:weather_app/views/travel_page.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 1;
  Widget _currentBody = const HomePage();
  String? _selectedCity;

  int get currentIndex => _currentIndex;
  Widget get currentBody => _currentBody;
  String? get selectedCity => _selectedCity;

  void updateIndex(int index, {String? cityName}) {
    _currentIndex = index;
    _selectedCity = cityName;

    switch (index) {
      case 0:
        _currentBody = const FavoritePage();
        break;
      case 1:
        _currentBody = HomePage(key: UniqueKey(), cityName: cityName);
        break;
      case 2:
        _currentBody = const TravelPage();
        break;
    }
    notifyListeners();
  }
}

void main() async {
  try {
    await dotenv.load(fileName: ".env");
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ],
        child: const MainApp(),
      ),
    );
  } catch (e) {
    print('Error loading .env file: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF1E1E2F),
            cardColor: const Color(0xFF2A2A40),
            primaryColor: Colors.white),
        home: const RootPage(),
        debugShowCheckedModeBanner: false);
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: navigationProvider.currentBody,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: navigationProvider
            .currentIndex, // Dynamically update selected index
        onDestinationSelected: (index) {
          navigationProvider.updateIndex(index);
        },
        indicatorColor: Theme.of(context).cardColor,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: const BorderSide(
            color: Colors.white,
            width: 1.0,
          ),
        ),

        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.favorite_border, color: Colors.white),
            label: '',
          ),
          const NavigationDestination(
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: '',
          ),
          NavigationDestination(
            icon: Image.asset(
              'assets/images/travel.png',
              height: 22,
              width: 22,
              color: Colors.white,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
