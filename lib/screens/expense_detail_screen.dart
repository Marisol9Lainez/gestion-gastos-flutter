import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../database/database_helper.dart';

// Pantalla para ver y editar los detalles de un gasto
class ExpenseDetailScreen extends StatefulWidget {
  final int expenseId;  // ID del gasto a mostrar/editar

  const ExpenseDetailScreen({super.key, required this.expenseId});  // Constructor que recibe el ID del gasto

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();  // Crea el estado de la pantalla
}

// Estado de la pantalla de detalle de gastos
class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  final _formKey = GlobalKey<FormState>();  // Clave para validar el formulario
  late final TextEditingController _descriptionController;  // Controlador para el campo de descripción
  late final TextEditingController _amountController;  // Controlador para el campo de monto
  late String _selectedCategory;  // Categoría seleccionada
  late DateTime _selectedDate;  // Fecha seleccionada
  bool _isLoading = true;  // Indica si se está cargando el gasto
  String? _error;  // Mensaje de error si ocurre alguno

  // Lista de categorías disponibles
  final List<String> _categories = [
    'Comida',  // Categoría para gastos de alimentación
    'Transporte',  // Categoría para gastos de transporte
    'Entretenimiento',  // Categoría para gastos de ocio
    'Servicios',  // Categoría para gastos de servicios
    'Otros'  // Categoría para gastos diversos
  ];

  @override
  void initState() {
    super.initState();
    _loadExpense();  // Carga el gasto cuando se inicializa el estado
  }

  @override
  void dispose() {
    // Limpia los controladores cuando se cierra la pantalla
    _descriptionController.dispose();  // Libera el controlador de descripción
    _amountController.dispose();  // Libera el controlador de monto
    super.dispose();  // Llama al método dispose de la clase padre
  }

  // Carga el gasto desde la base de datos
  Future<void> _loadExpense() async {
    try {
      final expense = await DatabaseHelper.instance.readExpense(widget.expenseId);  // Lee el gasto por ID
      setState(() {
        _descriptionController = TextEditingController(text: expense.description);  // Inicializa el controlador de descripción
        _amountController = TextEditingController(text: expense.amount.toString());  // Inicializa el controlador de monto
        _selectedCategory = expense.category;  // Establece la categoría
        _selectedDate = expense.date;  // Establece la fecha
        _isLoading = false;  // Indica que se terminó de cargar
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar el gasto: ${e.toString()}';  // Guarda el mensaje de error
        _isLoading = false;  // Indica que se terminó de cargar (con error)
      });
    }
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

  // Actualiza el gasto en la base de datos
  Future<void> _updateExpense() async {
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

        // Crea un objeto Expense con los datos actualizados
        final expense = Expense(
          id: widget.expenseId,  // ID del gasto a actualizar
          description: _descriptionController.text,  // Nueva descripción
          category: _selectedCategory,  // Nueva categoría
          amount: double.parse(_amountController.text),  // Nuevo monto
          date: _selectedDate,  // Nueva fecha
        );

        // Actualiza el gasto en la base de datos
        await DatabaseHelper.instance.update(expense);
        if (mounted) {  // Verifica que el widget esté montado
          Navigator.pop(context);  // Regresa a la pantalla anterior
        }
      } catch (e) {  // Captura cualquier error
        if (mounted) {  // Verifica que el widget esté montado
          ScaffoldMessenger.of(context).showSnackBar(  // Muestra un mensaje de error
            SnackBar(
              content: Text('Error al actualizar el gasto: ${e.toString()}'),
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

  // Elimina el gasto de la base de datos
  Future<void> _deleteExpense() async {
    try {
      await DatabaseHelper.instance.delete(widget.expenseId);  // Elimina el gasto por ID
      if (mounted) {  // Verifica que el widget esté montado
        Navigator.pop(context);  // Regresa a la pantalla anterior
      }
    } catch (e) {  // Captura cualquier error
      if (mounted) {  // Verifica que el widget esté montado
        ScaffoldMessenger.of(context).showSnackBar(  // Muestra un mensaje de error
          SnackBar(
            content: Text('Error al eliminar el gasto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {  // Si está cargando
      return const Scaffold(  // Muestra un indicador de carga
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {  // Si hay un error
      return Scaffold(  // Muestra el mensaje de error
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    return Scaffold(
      // Barra de aplicación
      appBar: AppBar(
        title: const Text('Detalle del Gasto'),  // Título de la pantalla
        centerTitle: true,  // Centra el título
        actions: [
          // Botón para eliminar el gasto
          IconButton(
            icon: const Icon(Icons.delete),  // Icono de eliminar
            onPressed: () async {  // Muestra un diálogo de confirmación
              final shouldDelete = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(  // Diálogo de confirmación
                  title: const Text('¿Eliminar gasto?'),  // Título del diálogo
                  content: const Text('Esta acción no se puede deshacer.'),  // Mensaje del diálogo
                  actions: [
                    TextButton(  // Botón para cancelar
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(  // Botón para confirmar
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (shouldDelete == true) {  // Si se confirmó la eliminación
                _deleteExpense();  // Elimina el gasto
              }
            },
          ),
        ],
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
              // Botón para actualizar el gasto
              ElevatedButton(
                onPressed: _updateExpense,  // Función que se ejecuta al presionar el botón
                style: ElevatedButton.styleFrom(  // Estilo del botón
                  padding: const EdgeInsets.symmetric(vertical: 16),  // Padding vertical
                  shape: RoundedRectangleBorder(  // Forma del botón
                    borderRadius: BorderRadius.circular(12),  // Bordes redondeados
                  ),
                ),
                child: const Text(  // Texto del botón
                  'Actualizar Gasto',
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