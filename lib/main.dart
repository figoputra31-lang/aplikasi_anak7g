import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/home_screen.dart';
import 'screens/overview_screen.dart';
import 'screens/card_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/add_debt_screen.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

import 'models/transaction_model.dart';
import 'models/debt_model.dart';
import 'models/user_model.dart';
import 'models/budget_model.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Registrasi adapter
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(DebtModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(BudgetModelAdapter());

  // Buka box
  await Hive.openBox<TransactionModel>('transactions');
  await Hive.openBox<DebtModel>('debts');
  await Hive.openBox<UserModel>('user');
  await Hive.openBox('settings'); // ⬅️ untuk PIN, notif, dark mode
  await Hive.openBox<BudgetModel>('budget');

  final userBox = Hive.box<UserModel>('user');
  final bool hasUser = userBox.get('account') != null;

  runApp(KosFinanceApp(hasUser: hasUser));
}

class KosFinanceApp extends StatelessWidget {
  final bool hasUser;

  const KosFinanceApp({super.key, required this.hasUser});

  @override
  Widget build(BuildContext context) {
    final settingsBox = Hive.box('settings');

    return ValueListenableBuilder(
      valueListenable: settingsBox.listenable(keys: ['dark_mode']),
      builder: (context, box, _) {
        final bool isDark =
            box.get('dark_mode', defaultValue: false) ?? false;

        final ThemeData lightTheme = ThemeData(
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF3E9FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        );

        final ThemeData darkTheme = ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6C5CE7),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kos Finance',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          // kalau belum ada user -> register, kalau sudah -> login
          initialRoute: hasUser ? '/login' : '/register',
          routes: {
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/main': (_) => const MainNavigation(),
          },
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late Box<TransactionModel> _txBox;
  late Box<DebtModel> _debtBox;

  List<TransactionModel> get _transactions => _txBox.values.toList();
  List<DebtModel> get _debts => _debtBox.values.toList();

  @override
  void initState() {
    super.initState();
    _txBox = Hive.box<TransactionModel>('transactions');
    _debtBox = Hive.box<DebtModel>('debts');
  }

  Future<void> _addTransaction(TransactionModel tx) async {
    await _txBox.add(tx);
    setState(() {});
  }

  Future<void> _addDebt(DebtModel debt) async {
    await _debtBox.add(debt);
    setState(() {});
  }

  Future<void> _toggleDebtPaid(int index) async {
    final oldDebt = _debts[index];
    final updated = oldDebt.copyWith(isPaid: !oldDebt.isPaid);
    await _debtBox.putAt(index, updated);
    setState(() {});
  }

  Future<void> _deleteTransaction(TransactionModel tx) async {
    final allTx = _txBox.values.toList();
    final index = allTx.indexOf(tx);

    if (index != -1) {
      await _txBox.deleteAt(index);
      setState(() {});
    }
  }

  void _editTransaction(TransactionModel tx) {
    Navigator.push<TransactionModel>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(
          existingTx: tx,
        ),
      ),
    ).then((newTx) async {
      if (newTx != null) {
        final allTx = _txBox.values.toList();
        final index = allTx.indexOf(tx);

        if (index != -1) {
          await _txBox.putAt(index, newTx);
          setState(() {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    switch (_currentIndex) {
      case 0:
        body = HomeScreen(
          transactions: _transactions,
          onDelete: _deleteTransaction,
          onEdit: _editTransaction,
        );
        break;
      case 1:
        body = OverviewScreen(transactions: _transactions);
        break;
      case 2:
        body = CardScreen(
          debts: _debts,
          onTogglePaid: _toggleDebtPaid,
        );
        break;
      case 3:
        body = const ProfileScreen();
        break;
      default:
        body = HomeScreen(
          transactions: _transactions,
          onDelete: _deleteTransaction,
          onEdit: _editTransaction,
        );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Card',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final action = await showModalBottomSheet<String>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (_) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tambah Data',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.add_circle_outline),
                        title: const Text('Tambah Transaksi'),
                        subtitle: const Text('Pemasukan / Pengeluaran harian'),
                        onTap: () {
                          Navigator.pop(context, 'transaction');
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.people_alt_outlined),
                        title: const Text('Tambah Hutang Teman'),
                        subtitle:
                            const Text('Catat hutang ke/dari teman kos'),
                        onTap: () {
                          Navigator.pop(context, 'debt');
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );

          if (action == 'transaction') {
            final newTX = await Navigator.push<TransactionModel>(
              context,
              MaterialPageRoute(
                builder: (_) => const AddTransactionScreen(),
              ),
            );

            if (newTX != null) {
              await _addTransaction(newTX);
            }
          } else if (action == 'debt') {
            final newDebt = await Navigator.push<DebtModel>(
              context,
              MaterialPageRoute(
                builder: (_) => const AddDebtScreen(),
              ),
            );

            if (newDebt != null) {
              await _addDebt(newDebt);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
