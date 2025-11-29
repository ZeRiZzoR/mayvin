import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/windows/sqflite_ffi_setup.dart';
import '../model/audio_item.dart';

class DatabaseHelper{

  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> getDataBase() async {
    if (_database != null) {
      return _database!;
    } else {
      _database = await initDB("playoor.db");
      return _database!;
    }
  }
  Future<Database?> initDB(String filePath) async {
    String dbPath, path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      dbPath = await databaseFactoryFfi.getDatabasesPath();
      path = join(dbPath, filePath);
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: onCreate),
      );
    }
    if (Platform.isAndroid || Platform.isIOS || Platform.isFuchsia) {
      dbPath = await getDatabasesPath();
      path = join(dbPath, filePath);
      return await openDatabase(path, version: 1, onCreate: onCreate);
    }
  }

  FutureOr<void> onCreate(Database db, int version) async {
    return await db.execute("""
    create table audioitem (
    id integer primary key autoincrement,
    assetPath varchar(70) not null,
    title varchar(70) not null,
    artist varchar(70) not null,
    imagePath varchar(70) not null
    );     
    """);
  }

  Future<void> insertAudioItem(AudioItem audioItem) async {
    final db = await getDataBase();
    await db.insert('audioitem', {
      'assetPath': audioItem.assetPath,
      'title': audioItem.title,
      'artist': audioItem.artist,
      'imagePath': audioItem.imagePath,
    });
  }

  Future<List<AudioItem>> getAudioItems() async {
    final db = await getDataBase();
    final maps = await db.query('audioitem');
    final lista = <AudioItem>[];
    for (int i = 0; i < maps.length; i++) {
      lista.add(AudioItem(
        maps[i]['assetPath'] as String,
        maps[i]['title'] as String,
        maps[i]['artist'] as String,
        maps[i]['imagePath'] as String,
      ));
    }
    return lista;
  }

  Future<int> getAudioItemsCount() async {
    final db = await getDataBase();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM audioitem');
    final count = result[0]['count'] as int;
    return count;
  }

}