import 'package:flutter/material.dart';  // Importa el framework de Flutter para la interfaz de usuario
import 'package:intl/intl.dart';  // Importa la librería para formatear fechas
import '../models/expense.dart';  // Importa el modelo de gastos
import '../database/database_helper.dart';  // Importa el helper de la base de datos

// Pantalla para agregar nuevos gastos
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});  // Constructor que recibe una clave opcional

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();  // Crea el estado de la pantalla
}

// Estado de la pantalla de agregar gastos
class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();  // Clave para validar el formulario
  final _descriptionController = TextEditingController();  // Controlador para el campo de descripción
  final _amountController = TextEditingController();  // Controlador para el campo de monto
  String _selectedCategory = 'Comida';  // Categoría seleccionada por defecto
  DateTime _selectedDate = DateTime.now();  // Fecha actual por defecto

  // Lista de categorías disponibles
  final List<String> _categories = [
    'Comida',  // Categoría para gastos de alimentación
    'Transporte',  // Categoría para gastos de transporte
    'Entretenimiento',  // Categoría para gastos de ocio
    'Servicios',  // Categoría para gastos de servicios
    'Otros'  // Categoría para gastos diversos
  ];

  @override
  void dispose() {
    // Limpia los controladores cuando se cierra la pantalla
    _descriptionController.dispose();  // Libera el controlador de descripción
    _amountController.dispose();  // Libera el controlador de monto
    super.dispose();  // Llama al método dispose de la clase padre
  }

  // Muestra el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(  // Muestra el selector de fecha
      context: context,  // Contexto de la aplicación
      initialDate: _selectedDate,  // Fecha inicial seleccionada
      firstDate: DateTime(2000),  // Fecha mínima permitida
      lastDate: DateTime(2100),  // Fecha máxima permitida
    );
    if (picked != null && picked != _selectedDate) {  // Si se seleccionó una fecha diferente
      setState(() {
        _selectedDate = picked;  // Actualiza la fecha seleccionada
      });
    }
  }

  // Guarda el nuevo gasto en la base de datos
  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {  // Valida el formulario
      try {
        // Verifica que los campos no estén vacíos
        if (_descriptionController.text.isEmpty || _amountController.text.isEmpty) {
          if (mounted) {  // Verifica que el widget esté montado
            ScaffoldMessenger.of(context).showSnackBar(  // Muestra un mensaje de error
              const SnackBar(
                content: Text('Por favor complete todos los campos'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;  // Sale de la función si hay campos vacíos
        }

        // Crea un nuevo objeto Expense con los datos del formulario
        final expense = Expense(
          description: _descriptionController.text,  // Descripción del gasto
          category: _selectedCategory,  // Categoría seleccionada
          amount: double.parse(_amountController.text),  // Monto convertido a número
          date: _selectedDate,  // Fecha seleccionada
        );

        // Guarda el gasto en la base de datos
        await DatabaseHelper.instance.create(expense);
        if (mounted) {  // Verifica que el widget esté montado
          Navigator.pop(context);  // Regresa a la pantalla anterior
        }
      } catch (e) {  // Captura cualquier error
        if (mounted) {  // Verifica que el widget esté montado
          ScaffoldMessenger.of(context).showSnackBar(  // Muestra un mensaje de error
            SnackBar(
              content: Text('Error al guardar el gasto: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {  // Si el formulario no es válido
      if (mounted) {  // Verifica que el widget esté montado
        ScaffoldMessenger.of(context).showSnackBar(  // Muestra un mensaje de error
          const SnackBar(
            content: Text('Por favor complete todos los campos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de aplicación
      appBar: AppBar(
        title: const Text('Agregar Gasto'),  // Título de la pantalla
        centerTitle: true,  // Centra el título
      ),
      // Cuerpo de la pantalla
      body: SingleChildScrollView(  // Permite desplazamiento cuando el teclado está abierto
        padding: const EdgeInsets.all(16.0),  // Padding alrededor del contenido
        child: Form(  // Formulario para validar los campos
          key: _formKey,  // Clave para validar el formulario
          autovalidateMode: AutovalidateMode.onUserInteraction,  // Valida automáticamente al interactuar
          child: Column(  // Organiza los elementos verticalmente
            crossAxisAlignment: CrossAxisAlignment.stretch,  // Estira los elementos horizontalmente
            children: [
              // Tarjeta con el formulario
              Card(
                elevation: 4,  // Elevación de la tarjeta
                shape: RoundedRectangleBorder(  // Forma de la tarjeta
                  borderRadius: BorderRadius.circular(16),  // Bordes redondeados
                ),
                child: Padding(  // Padding dentro de la tarjeta
                  padding: const EdgeInsets.all(20.0),
                  child: Column(  // Organiza los campos del formulario
                    children: [
                      // Campo de texto para la descripción
                      TextFormField(
                        controller: _descriptionController,  // Controlador del campo
                        decoration: InputDecoration(  // Decoración del campo
                          labelText: 'Descripción',  // Etiqueta del campo
                          border: OutlineInputBorder(  // Borde del campo
                            borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                          ),
                          prefixIcon: const Icon(Icons.description),  // Icono del campo
                          filled: true,  // Rellena el fondo
                          fillColor: Colors.grey[50],  // Color del fondo
                          errorStyle: const TextStyle(fontSize: 12),  // Estilo del mensaje de error
                        ),
                        validator: (value) {  // Validador del campo
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una descripción';
                          }
                          if (value.length < 3) {
                            return 'La descripción debe tener al menos 3 caracteres';
                          }
                          return null;
                        },
                        onChanged: (value) {  // Se ejecuta cuando cambia el texto
                          if (_formKey.currentState != null) {
                            _formKey.currentState!.validate();
                          }
                        },
                      ),
                      const SizedBox(height: 20),  // Espacio entre campos
                      // Campo de texto para el monto
                      TextFormField(
                        controller: _amountController,  // Controlador del campo
                        decoration: InputDecoration(  // Decoración del campo
                          labelText: 'Monto',  // Etiqueta del campo
                          border: OutlineInputBorder(  // Borde del campo
                            borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                          ),
                          prefixIcon: const Icon(Icons.attach_money),  // Icono del campo
                          filled: true,  // Rellena el fondo
                          fillColor: Colors.grey[50],  // Color del fondo
                          errorStyle: const TextStyle(fontSize: 12),  // Estilo del mensaje de error
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),  // Teclado numérico con decimales
                        validator: (value) {  // Validador del campo
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese un monto';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Por favor ingrese un número válido';
                          }
                          if (amount <= 0) {
                            return 'El monto debe ser mayor a 0';
                          }
                          if (amount > 1000000) {
                            return 'El monto no puede ser mayor a 1,000,000';
                          }
                          return null;
                        },
                        onChanged: (value) {  // Se ejecuta cuando cambia el texto
                          if (_formKey.currentState != null) {
                            _formKey.currentState!.validate();
                          }
                        },
                      ),
                      const SizedBox(height: 20),  // Espacio entre campos
                      // Selector de categoría
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,  // Valor seleccionado
                        decoration: InputDecoration(  // Decoración del campo
                          labelText: 'Categoría',  // Etiqueta del campo
                          border: OutlineInputBorder(  // Borde del campo
                            borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                          ),
                          prefixIcon: const Icon(Icons.category),  // Icono del campo
                          filled: true,  // Rellena el fondo
                          fillColor: Colors.grey[50],  // Color del fondo
                          errorStyle: const TextStyle(fontSize: 12),  // Estilo del mensaje de error
                        ),
                        items: _categories.map((String category) {  // Crea los items del menú
                          return DropdownMenuItem<String>(
                            value: category,  // Valor del item
                            child: Text(category),  // Texto del item
                          );
                        }).toList(),
                        onChanged: (String? newValue) {  // Se ejecuta cuando se selecciona una categoría
                          if (newValue != null) {
                            setState(() {
                              _selectedCategory = newValue;  // Actualiza la categoría seleccionada
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),  // Espacio entre campos
                      // Selector de fecha
                      InkWell(  // Hace que el contenedor sea clickeable
                        onTap: () => _selectDate(context),  // Muestra el selector de fecha al hacer clic
                        borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                        child: Container(  // Contenedor para el selector de fecha
                          padding: const EdgeInsets.all(16),  // Padding interno
                          decoration: BoxDecoration(  // Decoración del contenedor
                            border: Border.all(color: Colors.grey[300]!),  // Borde gris
                            borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                            color: Colors.grey[50],  // Color de fondo
                          ),
                          child: Row(  // Organiza los elementos horizontalmente
                            children: [
                              const Icon(Icons.calendar_today),  // Icono de calendario
                              const SizedBox(width: 16),  // Espacio entre el icono y el texto
                              Text(  // Muestra la fecha seleccionada
                                DateFormat('dd/MM/yyyy').format(_selectedDate),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),  // Espacio antes del botón
              // Botón para guardar el gasto
              ElevatedButton(
                onPressed: _saveExpense,  // Función que se ejecuta al presionar el botón
                style: ElevatedButton.styleFrom(  // Estilo del botón
                  padding: const EdgeInsets.symmetric(vertical: 16),  // Padding vertical
                  shape: RoundedRectangleBorder(  // Forma del botón
                    borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                  ),
                ),
                child: const Text(  // Texto del botón
                  'Guardar Gasto',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 