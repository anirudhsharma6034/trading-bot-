import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('trading_bot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Increment to reset demo password 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        balance REAL NOT NULL,
        available_cash REAL NOT NULL,
        profile_picture TEXT
      )
    ''');

    // Stocks table
    await db.execute('''
      CREATE TABLE stocks (
        symbol TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        current_price REAL NOT NULL,
        previous_close REAL NOT NULL,
        open REAL NOT NULL,
        high REAL NOT NULL,
        low REAL NOT NULL,
        volume INTEGER NOT NULL,
        change REAL NOT NULL,
        change_percent REAL NOT NULL,
        sector TEXT NOT NULL
      )
    ''');

    // Watchlist table
    await db.execute('''
      CREATE TABLE watchlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        FOREIGN KEY (symbol) REFERENCES stocks (symbol) ON DELETE CASCADE
      )
    ''');

    // Bots table
    await db.execute('''
      CREATE TABLE bots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        strategy_name TEXT NOT NULL,
        initial_capital REAL NOT NULL,
        current_capital REAL NOT NULL,
        risk_level TEXT NOT NULL,
        stop_loss REAL NOT NULL,
        take_profit REAL NOT NULL,
        max_trades_per_day INTEGER NOT NULL,
        max_open_positions INTEGER NOT NULL,
        position_size REAL NOT NULL,
        timeframe TEXT NOT NULL,
        status TEXT NOT NULL,
        pnl REAL NOT NULL,
        trades_count INTEGER NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        type TEXT NOT NULL,
        side TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        stop_price REAL,
        status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Positions table
    await db.execute('''
      CREATE TABLE positions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        average_price REAL NOT NULL,
        current_price REAL NOT NULL,
        pnl REAL NOT NULL,
        pnl_percent REAL NOT NULL
      )
    ''');

    // Trades table
    await db.execute('''
      CREATE TABLE trades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        symbol TEXT NOT NULL,
        side TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        entry_price REAL NOT NULL,
        exit_price REAL NOT NULL,
        pnl REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Portfolio table
    await db.execute('''
      CREATE TABLE portfolio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_value REAL NOT NULL,
        available_cash REAL NOT NULL,
        invested_amount REAL NOT NULL,
        today_pnl REAL NOT NULL,
        overall_pnl REAL NOT NULL
      )
    ''');

    // Backtests table
    await db.execute('''
      CREATE TABLE backtests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        strategy_name TEXT NOT NULL,
        symbol TEXT NOT NULL,
        initial_capital REAL NOT NULL,
        final_capital REAL NOT NULL,
        net_profit REAL NOT NULL,
        total_trades INTEGER NOT NULL,
        win_rate REAL NOT NULL,
        max_drawdown REAL NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Bot logs table
    await db.execute('''
      CREATE TABLE bot_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bot_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        FOREIGN KEY (bot_id) REFERENCES bots (id) ON DELETE CASCADE
      )
    ''');

    // Insert default demo user and initial data
    await _insertInitialData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Recreating the default test user so the new strict password rule is satisfied
      await db.execute("DELETE FROM users WHERE email = 'trader@example.com'");
      await db.insert('users', {
        'name': 'Trader Demo',
        'email': 'trader@example.com',
        'password': 'password123!', // Now includes a special character to fit regex
        'balance': 100000.0,
        'available_cash': 75000.0,
        'profile_picture': null,
      });
    }
  }

  Future<void> _insertInitialData(Database db) async {
    await db.insert('users', {
      'name': 'Trader Demo',
      'email': 'trader@example.com',
      'password': 'password123!', // Fits strict regex
      'balance': 100000.0,
      'available_cash': 75000.0,
      'profile_picture': null,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    final initialStocks = [
      {'symbol': 'RELIANCE', 'name': 'Reliance Industries Ltd', 'current_price': 2850.50, 'previous_close': 2820.00, 'open': 2830.00, 'high': 2865.00, 'low': 2825.00, 'volume': 5420000, 'change': 30.50, 'change_percent': 1.08, 'sector': 'Energy'},
      {'symbol': 'TCS', 'name': 'Tata Consultancy Services', 'current_price': 4120.00, 'previous_close': 4150.00, 'open': 4140.00, 'high': 4160.00, 'low': 4105.00, 'volume': 2100000, 'change': -30.00, 'change_percent': -0.72, 'sector': 'IT'},
      {'symbol': 'INFY', 'name': 'Infosys Limited', 'current_price': 1650.25, 'previous_close': 1635.00, 'open': 1640.00, 'high': 1660.00, 'low': 1638.00, 'volume': 3800000, 'change': 15.25, 'change_percent': 0.93, 'sector': 'IT'},
      {'symbol': 'HDFCBANK', 'name': 'HDFC Bank Ltd', 'current_price': 1520.00, 'previous_close': 1510.00, 'open': 1515.00, 'high': 1530.00, 'low': 1512.00, 'volume': 7200000, 'change': 10.00, 'change_percent': 0.66, 'sector': 'Banking'},
      {'symbol': 'SBIN', 'name': 'State Bank of India', 'current_price': 780.40, 'previous_close': 775.00, 'open': 778.00, 'high': 785.00, 'low': 775.50, 'volume': 9500000, 'change': 5.40, 'change_percent': 0.70, 'sector': 'Banking'},
      {'symbol': 'ICICIBANK', 'name': 'ICICI Bank Ltd', 'current_price': 1110.80, 'previous_close': 1105.00, 'open': 1108.00, 'high': 1120.00, 'low': 1104.00, 'volume': 6100000, 'change': 5.80, 'change_percent': 0.52, 'sector': 'Banking'},
      {'symbol': 'ITC', 'name': 'ITC Limited', 'current_price': 445.60, 'previous_close': 448.00, 'open': 447.00, 'high': 450.00, 'low': 444.00, 'volume': 8300000, 'change': -2.40, 'change_percent': -0.54, 'sector': 'FMCG'},
      {'symbol': 'LT', 'name': 'Larsen & Toubro Ltd', 'current_price': 3560.00, 'previous_close': 3520.00, 'open': 3530.00, 'high': 3580.00, 'low': 3525.00, 'volume': 1900000, 'change': 40.00, 'change_percent': 1.14, 'sector': 'Construction'},
      {'symbol': 'WIPRO', 'name': 'Wipro Limited', 'current_price': 525.30, 'previous_close': 520.00, 'open': 522.00, 'high': 530.00, 'low': 521.00, 'volume': 4100000, 'change': 5.30, 'change_percent': 1.02, 'sector': 'IT'},
      {'symbol': 'AXISBANK', 'name': 'Axis Bank Ltd', 'current_price': 1150.90, 'previous_close': 1145.00, 'open': 1148.00, 'high': 1160.00, 'low': 1145.00, 'volume': 4800000, 'change': 5.90, 'change_percent': 0.52, 'sector': 'Banking'},
    ];

    for (var stock in initialStocks) {
      await db.insert('stocks', stock, conflictAlgorithm: ConflictAlgorithm.ignore);
      if (initialStocks.indexOf(stock) < 5) {
        await db.insert('watchlist', {'symbol': stock['symbol']}, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    }

    await db.insert('portfolio', {
      'total_value': 100000.0,
      'available_cash': 75000.0,
      'invested_amount': 25000.0,
      'today_pnl': 1250.0,
      'overall_pnl': 3400.0,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
