// Modelo de datos para representar un gasto
class Expense {
  int? id;  // Identificador único del gasto (puede ser null si es nuevo)
  final String description;  // Descripción del gasto
  final String category;  // Categoría del gasto
  final double amount;  // Monto del gasto
  final DateTime date;  // Fecha del gasto

  // Constructor para crear un nuevo gasto
  Expense({
    this.id,  // ID opcional
    required this.description,  // Descripción requerida
    required this.category,  // Categoría requerida
    required this.amount,  // Monto requerido
    required this.date,  // Fecha requerida
  });

  // Constructor para crear un gasto desde un mapa (usado al leer de la base de datos)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],  // Obtiene el ID del mapa
      description: map['description'],  // Obtiene la descripción
      category: map['category'],  // Obtiene la categoría
      amount: map['amount'],  // Obtiene el monto
      date: DateTime.parse(map['date']),  // Convierte la fecha de string a DateTime
    );
  }

  // Convierte el gasto a un mapa (usado al guardar en la base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,  // Incluye el ID si existe
      'description': description,  // Incluye la descripción
      'category': category,  // Incluye la categoría
      'amount': amount,  // Incluye el monto
      'date': date.toIso8601String(),  // Convierte la fecha a string ISO 8601
    };
  }
} 