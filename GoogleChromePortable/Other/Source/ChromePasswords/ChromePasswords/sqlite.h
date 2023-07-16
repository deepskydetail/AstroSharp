#pragma once

#include <sqlite3.h>

class SQLiteSTMT {
  public:
    SQLiteSTMT(sqlite3*, const char*, int, const char**);
    SQLiteSTMT(sqlite3*, const void*, int, const void**);
    ~SQLiteSTMT();

	int Bind(int, double);
	int Bind(int, sqlite3_int64);
	int Bind(int);
	int Bind(int, const char*, int, void(void*));
	int Bind(int, const sqlite3_value*);
	int BindBlob(int, const void*, int, void(void*));
	int BindInt(int, int);
	int BindText16(int, const void*, int, void(void*));
	int BindZeroBlob(int, int);

	int ClearBindings();
	int Close();
	
	const void* ColumnBlob(int);
	int ColumnBytes(int);
	int ColumnBytes16(int);
	double ColumnDouble(int);
	int ColumnInt(int);
	sqlite3_int64 ColumnInt64(int);
    const unsigned char* ColumnText(int);
    const void* ColumnText16(int);
    int ColumnType(int);
    sqlite3_value* ColumnValue(int);

	int Reset();
	int Step();

  private:
   sqlite3* db;
   sqlite3_stmt* handle;
};

class SQLite {
  public:
    SQLite(const char*);
    SQLite(const char*, int, const char*);
    SQLite(const void*);
    ~SQLite();
	int Close();
	SQLiteSTMT* Prepare(const char*, int, const char**);
	SQLiteSTMT* Prepare(const void*, int, const void**);

  private:
	sqlite3* handle;
};
