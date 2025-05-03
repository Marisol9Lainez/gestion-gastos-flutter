import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/expense.dart';

// Clase helper para manejar la base de datos SQLite
class DatabaseHelper {
  // Patrón Singleton para tener una única instancia
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // Constructor privado
  DatabaseHelper._init();

  // Obtiene la base de datos, la crea si no existe
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('proyecto-flutter.db');
    return _database!;
  }

  // Inicializa la base de datos en el directorio de documentos
  Future<Database> _initDB(String filePath) async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, filePath);
    
    developer.log('Intentando crear/abrir base de datos en: $path');
    
    try {
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
      developer.log('Base de datos creada/abierta exitosamente');
      return db;
    } catch (e) {
      developer.log('Error al crear/abrir base de datos: $e');
      rethrow;
    }
  }

  // Crea la tabla de gastos
  Future<void> _createDB(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE expenses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,  
          description TEXT NOT NULL,  
          category TEXT NOT NULL,  
          amount REAL NOT NULL,  
          date TEXT NOT NULL  
        )
      ''');
      developer.log('Tabla expenses creada exitosamente');
    } catch (e) {
      developer.log('Error al crear la tabla: $e');
      rethrow;
    }
  }

  // Verifica el estado de la base de datos
  Future<void> verifyDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'proyecto-flutter.db');
    final file = File(path);
    
    developer.log('Verificando base de datos...');
    developer.log('Ruta completa: $path');
    developer.log('¿Existe el archivo?: ${await file.exists()}');
    if (await file.exists()) {
      developer.log('Tamaño del archivo: ${await file.length()} bytes');
    }
  }

  // Crea un nuevo gasto
  Future<int> create(Expense expense) async {
    final db = await instance.database;
    final id = await db.insert('expenses', expense.toMap());
    developer.log('Gasto creado con ID: $id');
    return id;
  }

  // Lee todos los gastos ordenados por fecha
  Future<List<Expense>> readAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    developer.log('Total de gastos leídos: ${result.length}');
    return result.map((json) => Expense.fromMap(json)).toList();
  }

  // Lee un gasto específico por ID
  Future<Expense> readExpense(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      developer.log('Gasto encontrado con ID: $id');
      return Expense.fromMap(maps.first);
    } else {
      developer.log('Gasto no encontrado con ID: $id');
      throw Exception('ID $id not found');
    }
  }

  // Actualiza un gasto existente
  Future<int> update(Expense expense) async {
    final db = await instance.database;
    final result = await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    developer.log('Gasto actualizado: $result filas afectadas');
    return result;
  }

  // Elimina un gasto
  Future<int> delete(int id) async {
    final db = await instance.database;
    final result = await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
    developer.log('Gasto eliminado: $result filas afectadas');
    return result;
  }

  // Calcula el total de gastos
  Future<double> getTotalExpenses() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT SUM(amount) as total FROM expenses');
    final total = result.first['total'] as double? ?? 0.0;
    developer.log('Total de gastos calculado: $total');
    return total;
  }

  // Imprime todos los datos de la base de datos
  Future<void> printAllData() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('expenses');
    
    developer.log('=== Contenido de la base de datos ===');
    for (var map in maps) {
      developer.log('ID: ${map['id']}');
      developer.log('Descripción: ${map['description']}');
      developer.log('Categoría: ${map['category']}');
      developer.log('Monto: ${map['amount']}');
      developer.log('Fecha: ${map['date']}');
      developer.log('-------------------');
    }
    developer.log('Total de registros: ${maps.length}');
  }
} 
