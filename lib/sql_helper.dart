import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;



class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    name TEXT,
    offPrice TEXT,
    date TEXT,
    fro TEXT,
    before TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
    await database.execute("""CREATE TABLE itemsOn(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    onPrice TEXT,
    date1 TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);
  }

  // static Future<void> createTables1(sql.Database database) async {
  //   await database.execute("""CREATE TABLE itemsOn(
  //   id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  //   onPrice TEXT,
  //   date1 TEXT,
  //   createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  //   )
  //   """);
  // }


  static Future<sql.Database> db() async {
    return sql.openDatabase('dbtech.db', version: 1,
        onCreate: (sql.Database database, int version) async {
          print('...создание таблицы...');
          await createTables(database);
          // await createTables1(database);
        });
  }

  static Future<int> createItem(
      String name, String offPrice, String date, String fro, String before) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'offPrice': offPrice,
      'date': date,
      'fro': fro,
      'before': before
    };
    final id = await db.insert('items', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('items', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('items', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(int id, String name, String offPrice, String date, String fro, String before) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
      'offPrice': offPrice,
      'date': date,
      'fro': fro,
      'before': before,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('items', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('items', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('O`chirishda xatolik');
    }
  }


  static Future<int> createItem1(String onPrice, String date1) async {
    final db = await SQLHelper.db();

    final data = {
      'onPrice': onPrice,
      'date1': date1
    };
    final id = await db.insert('itemsOn', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems1() async {
    final db = await SQLHelper.db();
    return db.query('itemsOn', orderBy: 'id');
  }

  static Future<List<Map<String, dynamic>>> getItem1(int id) async {
    final db = await SQLHelper.db();
    return db.query('itemsOn', where: 'id = ?', whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem1(int id, String onPrice, String date1) async {
    final db = await SQLHelper.db();

    final data = {
      'onPrice': onPrice,
      'date1': date1,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('itemsOn', data, where: 'id = ?', whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem1(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete('itemsOn', where: 'id = ?', whereArgs: [id]);
    } catch (err) {
      debugPrint('O`chirishda xatolik');
    }
  }
}
