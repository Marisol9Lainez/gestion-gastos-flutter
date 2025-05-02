PROYECTO DE GESTIÓN DE GASTOS - FLUTTER
=====================================

Este proyecto es una aplicación móvil desarrollada en Flutter para la gestión de gastos personales.

REQUISITOS DEL SISTEMA
---------------------
1. Flutter SDK (versión 3.0.0 o superior)
2. Dart SDK (versión 2.17.0 o superior)
3. Android Studio o Visual Studio Code
4. Android SDK (para desarrollo en Android)
5. Xcode (para desarrollo en iOS, solo en macOS)
6. Git (opcional, para control de versiones)

CONFIGURACIÓN DEL ENTORNO
------------------------
1. Instalar Flutter:
   - Descargar Flutter SDK desde: https://flutter.dev/docs/get-started/install
   - Extraer el archivo descargado en una ubicación deseada
   - Agregar la ruta de Flutter al PATH del sistema

2. Verificar la instalación:
   - Abrir una terminal o línea de comandos
   - Ejecutar: flutter doctor
   - Seguir las instrucciones para instalar los componentes faltantes

3. Instalar un IDE:
   - Android Studio: https://developer.android.com/studio
   - Visual Studio Code: https://code.visualstudio.com/
   - Instalar las extensiones de Flutter y Dart en el IDE elegido

CONFIGURACIÓN DEL PROYECTO
-------------------------
1. Clonar o descargar el proyecto:
   - Clonar con Git: git clone [https://github.com/Marisol9Lainez/gestion-gastos-flutter]
   - O descargar el código fuente como ZIP

2. Abrir el proyecto:
   - En Android Studio: File -> Open -> Seleccionar la carpeta del proyecto
   - En VS Code: File -> Open Folder -> Seleccionar la carpeta del proyecto

3. Obtener las dependencias:
   - Ejecutar en la terminal: flutter pub get
   - O usar el IDE: Tools -> Flutter -> Flutter Pub Get

ESTRUCTURA DEL PROYECTO
----------------------
lib/
├── main.dart              # Punto de entrada de la aplicación
├── models/
│   └── expense.dart       # Modelo de datos para los gastos
├── database/
│   └── database_helper.dart # Clase helper para la base de datos SQLite
└── screens/
    ├── add_expense_screen.dart    # Pantalla para agregar gastos
    └── expense_detail_screen.dart # Pantalla para ver/editar gastos

DEPENDENCIAS
-----------
El proyecto utiliza las siguientes dependencias (ver pubspec.yaml):
- sqflite: ^2.3.0        # Para la base de datos SQLite
- path: ^1.8.3          # Para manejo de rutas
- intl: ^0.18.1         # Para formateo de fechas
- path_provider: ^2.1.1 # Para acceso a directorios del sistema

EJECUTAR EL PROYECTO
-------------------
1. Conectar un dispositivo físico o iniciar un emulador
2. En la terminal:
   - flutter devices (para ver dispositivos disponibles)
   - flutter run (para ejecutar la aplicación)

3. Desde el IDE:
   - Seleccionar el dispositivo de destino
   - Presionar el botón de ejecución (▶️)

FUNCIONALIDADES
--------------
- Agregar nuevos gastos
- Editar gastos existentes
- Eliminar gastos
- Categorizar gastos
- Ver total de gastos
- Ver historial de gastos
- Selección de fechas
- Validación de campos

BASE DE DATOS
------------
- Nombre: proyecto-flutter.db
- Ubicación: Directorio de documentos de la aplicación
- Tabla: expenses
  - id (INTEGER PRIMARY KEY AUTOINCREMENT)
  - description (TEXT NOT NULL)
  - category (TEXT NOT NULL)
  - amount (REAL NOT NULL)
  - date (TEXT NOT NULL)

NOTAS IMPORTANTES
----------------
1. La aplicación utiliza SQLite para almacenar los datos localmente
2. Los datos se guardan en el dispositivo y no se sincronizan con la nube
3. Se recomienda hacer copias de seguridad periódicas de los datos
4. La aplicación está optimizada para dispositivos móviles
5. Se requiere permiso de almacenamiento para la base de datos

SOLUCIÓN DE PROBLEMAS
--------------------
1. Si la aplicación no se ejecuta:
   - Verificar que Flutter esté correctamente instalado
   - Ejecutar flutter doctor para diagnosticar problemas
   - Limpiar el proyecto: flutter clean

2. Si hay problemas con la base de datos:
   - Verificar los permisos de almacenamiento
   - Reinstalar la aplicación
   - Verificar la estructura de la base de datos

3. Si hay errores de compilación:
   - Actualizar las dependencias: flutter pub upgrade
   - Verificar la versión de Flutter
   - Limpiar la caché: flutter clean

CONTACTO Y SOPORTE
-----------------
Para soporte técnico o reporte de errores:
- Desarrollador: Marisol Lainez
- Correo: yesenia.9ayala@gmail.com
- GitHub: https://github.com/Marisol9Lainez/gestion-gastos-flutter

CRÉDITOS
--------
Desarrollado por Marisol Lainez para el proyecto de gestión de gastos personales.
