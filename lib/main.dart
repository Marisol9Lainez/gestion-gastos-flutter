import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/expense.dart';
import 'database/database_helper.dart';
import 'screens/add_expense_screen.dart';
import 'screens/expense_detail_screen.dart';

// Función principal que inicia la aplicación
void main() {
  runApp(const MyApp());
}

// Widget raíz de la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Gastos',  // Título de la aplicación
      theme: ThemeData(
        // Tema de la aplicación con color verde
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 64, 94, 41),
          brightness: Brightness.light,
        ),
        useMaterial3: true,  // Usa Material Design 3
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const MyHomePage(title: 'Gestión de Gastos'),  // Pantalla principal
    );
  }
}

// Widget de la página principal
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// Estado de la página principal
class _MyHomePageState extends State<MyHomePage> {
  List<Expense> _expenses = [];  // Lista de gastos
  double _totalExpenses = 0.0;  // Total de gastos

  @override
  void initState() {
    super.initState();
    _initializeApp();  // Inicializa la aplicación al cargar
  }

  // Inicializa la aplicación y carga los gastos
  Future<void> _initializeApp() async {
    await DatabaseHelper.instance.verifyDatabase();  // Verifica la base de datos
    _loadExpenses();  // Carga los gastos
  }

  // Carga los gastos y el total desde la base de datos
  Future<void> _loadExpenses() async {
    final expenses = await DatabaseHelper.instance.readAllExpenses();
    final total = await DatabaseHelper.instance.getTotalExpenses();
    setState(() {
      _expenses = expenses;
      _totalExpenses = total;
    });
  }

  // Muestra información sobre la aplicación
  Future<void> _printDatabaseContent() async {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Acerca de la Aplicación'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Gastos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Esta aplicación fue desarrollada por Yesenia Marisol Ayala Lainez, como parte de un proyecto de desarrollo móvil con Flutter.',
              ),
              SizedBox(height: 8),
              Text(
                'El proyecto forma parte de los requisitos académicos de la Escuela Superior de Ingeniería y Tecnología (ESIT).',
              ),
              SizedBox(height: 8),
              Text(
                'La aplicación permite gestionar gastos personales, incluyendo:',
              ),
              SizedBox(height: 8),
              Text('• Agregar nuevos gastos'),
              Text('• Editar gastos existentes'),
              Text('• Eliminar gastos'),
              Text('• Categorizar gastos'),
              Text('• Ver total de gastos'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de aplicación
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.storage),
            onPressed: _printDatabaseContent,
            tooltip: 'ver informacion de la aplicacion',
          ),
        ],
      ),
      // Cuerpo de la aplicación
      body: Column(
        children: [
          // Tarjeta con el total de gastos
          Container(
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Gastos Totales',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${_totalExpenses.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Lista de gastos
          Expanded(
            child: ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExpenseDetailScreen(
                              expenseId: expense.id!,  // Pasa el ID del gasto en lugar del objeto completo
                            ),
                          ),
                        ).then((_) => _loadExpenses());  // Recarga la lista después de volver
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Icono según la categoría
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Información del gasto
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.description,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${expense.category} - ${DateFormat('dd/MM/yyyy').format(expense.date)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Monto del gasto
                            Text(
                              '\$${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 197, 12, 27),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Botón flotante para agregar gastos
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Navega a la pantalla de agregar gasto
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
          _loadExpenses();  // Recarga los gastos al volver
        },
        icon: const Icon(Icons.add),
        label: const Text('Agregar Gasto'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  // Obtiene el icono correspondiente a la categoría
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Comida':
        return Icons.restaurant;
      case 'Transporte':
        return Icons.directions_car;
      case 'Entretenimiento':
        return Icons.movie;
      case 'Servicios':
        return Icons.home_repair_service;
      default:
        return Icons.category;
    }
  }
}
