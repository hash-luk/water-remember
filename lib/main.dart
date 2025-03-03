import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notification.init();
  runApp(const MyApp());
}

class Notification {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings settings = InitializationSettings(
      android: androidInit,
    );

    await _plugin.initialize(settings);
  }

  static Future<void> scheduleTask(int id, String message, int interval) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'water_warning',
          'Lembrete de água',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.periodicallyShow(
      id,
      'Hora de beber água',
      message,
      RepeatInterval.hourly,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lembrete de água',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _interval = 1;

  @override
  void initState() {
    super.initState();
    _loadInterval();
  }

  Future<void> _loadInterval() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _interval = prefs.getInt('interval') ?? 1;
    });
  }

  Future<void> _saveInterval(int interval) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('interval', interval);
      Notification.scheduleTask(0, 'Beba um copo de água!', interval);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lembrente salvo com sucesso! Você será lembrado em ${interval}h'),
        backgroundColor: Colors.green
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
        Text('Error ao salvar lembrete:${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Lembrete de Água'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Escolha o intervalo (em horas):',
            style: TextStyle(fontSize: 18),
          ),
          Slider(
            value: _interval.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            label: '$_interval h',
            onChanged: (value) {
              setState(() => _interval = value.toInt());
            },
          ),
          ElevatedButton(
            onPressed: () => _saveInterval(_interval),
            child: Text('Salvar Lembrete'),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
