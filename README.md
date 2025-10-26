# SQL Editor - Mobile & Desktop SQL Database Manager

A powerful, cross-platform SQL database editor built with Flutter that provides a seamless experience for managing SQLite databases on both mobile and desktop platforms.

## ✨ Features

### 🗄️ Database Management
- **Create New Databases**: Build SQLite databases from scratch
- **Open Existing Databases**: Import and work with existing `.db` files
- **Sample Database**: Auto-generated sample database with users and products tables for testing
- **Database Schema Viewer**: Explore table structures and relationships

### 📝 SQL Editor
- **Smart Query Editor**: Clean, responsive text editor optimized for SQL
- **Monospace Font**: Code-friendly typography with proper spacing
- **Auto-Growing Text Area**: Editor expands dynamically with your content
- **Theme Support**: Adapts to light and dark themes seamlessly

### 🔍 Query Execution & Results
- **Live Query Execution**: Run SQL queries with real-time results
- **Data Table Display**: Clean, scrollable table view for query results
- **Error Handling**: Helpful error messages for debugging SQL issues
- **Row Count Display**: See exactly how many rows your queries return

### 📊 Query History
- **Automatic History**: All executed queries are automatically saved
- **Quick Access**: Tap any historical query to reload it in the editor
- **Swipe to Delete**: Remove individual queries with intuitive gestures
- **Clear All**: Bulk delete entire query history with confirmation
- **Relative Timestamps**: See when queries were executed ("2 minutes ago")

### 🎨 User Interface
- **Material 3 Design**: Modern, beautiful interface following latest design principles
- **Responsive Layout**: Optimized for both mobile and desktop screens
- **Dark/Light Themes**: Toggle between themes with system integration
- **Smooth Animations**: Polished transitions and interactions

### 🔧 Advanced Features
- **File Export**: Share query results and database files
- **Cross-Platform**: Runs on Android, iOS, Linux, macOS, and Windows
- **Offline First**: No internet connection required
- **State Management**: Powered by Riverpod for reliable app state

## 🚀 Installation

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Platform-specific development tools:
  - **Android**: Android Studio/SDK
  - **iOS**: Xcode (macOS only)
  - **Desktop**: Platform-specific build tools

### Clone & Setup
```bash
git clone https://github.com/yourusername/sql_edit.git
cd sql_edit
flutter pub get
```

### Run the App
```bash
# Mobile (Android/iOS)
flutter run

# Desktop
flutter run -d linux    # Linux
flutter run -d macos    # macOS
flutter run -d windows  # Windows
```

## 📱 Usage

### Getting Started
1. **Launch the app** - You'll see the welcome screen with feature overview
2. **Create or Open Database** - Use the Database Manager to start working
3. **Write SQL Queries** - Use the built-in editor with helpful examples
4. **Execute & View Results** - See your data in a clean table format
5. **Review History** - Access previously executed queries anytime

### Sample Queries
The app includes a sample database with example queries:

```sql
-- View all users
SELECT * FROM users LIMIT 5;

-- Filter products by category
SELECT * FROM products WHERE category = 'Electronics';

-- Join users and products with aggregation
SELECT u.name, COUNT(p.id) as product_count
FROM users u, products p
WHERE u.age > 25
GROUP BY u.name;
```

### Database Operations
- **Open Database**: Import existing SQLite files
- **Create Tables**: Use DDL statements to create new tables
- **Insert Data**: Add records with INSERT statements
- **Query Data**: Use SELECT statements to retrieve information
- **Update/Delete**: Modify existing records

## 🏗️ Architecture

### Tech Stack
- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Database**: SQLite with `sqflite` and `sqflite_common_ffi`
- **UI Components**: Material 3, `data_table_2`
- **Typography**: Google Fonts (Inter, JetBrains Mono)
- **File Operations**: `file_picker`, `share_plus`

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── DatabaseInfo.dart
│   ├── QueryResult.dart
│   └── QueryHistory.dart
├── providers/                # Riverpod providers
│   ├── DatabaseServiceProvider.dart
│   ├── QueryServiceProvider.dart
│   └── ThemeProvider.dart
├── screens/                  # UI screens
│   ├── home/
│   ├── sqlEditScreen/
│   ├── database/
│   └── settings/
├── services/                 # Business logic
│   ├── Database.dart
│   ├── Query.dart
│   └── QueryHistory.dart
└── routes/                   # Navigation
    └── routes.dart
```

## 🛠️ Development

### Building for Release
```bash
# Android APK
flutter build apk --release

# iOS IPA (requires macOS)
flutter build ios --release

# Desktop executable
flutter build linux --release
flutter build macos --release
flutter build windows --release
```

### Code Quality
```bash
# Run static analysis
flutter analyze

# Run tests
flutter test

# Format code
flutter format .
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write tests for new features
- Update documentation for API changes
- Ensure cross-platform compatibility

## 📋 Roadmap

### Upcoming Features
- [ ] **Export Formats**: CSV, JSON, XML export options
- [ ] **Query Autocompletion**: Intelligent SQL suggestions
- [ ] **Database Backup**: Automated backup and restore
- [ ] **Multi-tab Editing**: Work with multiple queries simultaneously
- [ ] **Visual Query Builder**: Drag-and-drop query construction
- [ ] **Database Comparison**: Compare schemas and data between databases

### Performance Improvements
- [ ] **Large Dataset Handling**: Pagination for massive result sets
- [ ] **Query Optimization**: Execution plan analysis
- [ ] **Memory Management**: Better handling of large databases

## 🐛 Known Issues

- Line numbers removed from SQL editor to prevent display issues
- Large result sets may impact performance on older devices
- Desktop file picker styling varies by platform

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- SQLite for the robust database engine
- Contributors to the open-source packages used in this project
- Material Design team for the beautiful design system

---

**Built with ❤️ using Flutter**