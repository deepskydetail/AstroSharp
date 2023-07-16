#include "sqlite.h"

SQLite::SQLite(const char* filename) {
  handle = 0;
  int ret;
  if ((ret = sqlite3_open(filename, &handle)) != SQLITE_OK || !handle) {
	Close();
	throw ret;
  }
}

SQLite::SQLite(const char* filename, int flags, const char* zVfs) {
  handle = 0;
  int ret;
  if ((ret = sqlite3_open_v2(filename, &handle, flags, zVfs)) != SQLITE_OK || !handle) {
	Close();
	throw ret;
  }
}

SQLite::SQLite(const void* filename) {
  handle = 0;
  int ret;
  if ((ret = sqlite3_open16(filename, &handle)) != SQLITE_OK || !handle) {
	Close();
	throw ret;
  }
}

SQLite::~SQLite() {
  Close();
}

int SQLite::Close() {
  if (!handle) {
	return SQLITE_OK;
  }

  int ret = sqlite3_close(handle);
  handle = 0;
  return ret;
}

SQLiteSTMT* SQLite::Prepare(const char* zSql, int nByte, const char** pzTail) {
  return new SQLiteSTMT(handle, zSql, nByte, pzTail);
}

SQLiteSTMT* SQLite::Prepare(const void* zSql, int nByte, const void** pzTail) {
  return new SQLiteSTMT(handle, zSql, nByte, pzTail);
}

SQLiteSTMT::SQLiteSTMT(sqlite3* db, const char* zSql, int nByte, const char** pzTail) {
  this->db = db;
  handle = 0;
  int ret;
  if ((ret = sqlite3_prepare_v2(db, zSql, nByte, &handle, pzTail)) != SQLITE_OK || !handle) {
	Close();
	throw ret;
  }
}

SQLiteSTMT::SQLiteSTMT(sqlite3* db, const void* zSql, int nByte, const void** pzTail) {
  this->db = db;
  handle = 0;
  int ret;
  if ((ret = sqlite3_prepare16_v2(db, zSql, nByte, &handle, pzTail)) != SQLITE_OK || !handle) {
	Close();
	throw ret;
  }
}

SQLiteSTMT::~SQLiteSTMT() {
  Close();
}

int SQLiteSTMT::Bind(int iCol, double value) {
  return sqlite3_bind_double(handle, iCol, value);
}

int SQLiteSTMT::Bind(int iCol, sqlite3_int64 value) {
  return sqlite3_bind_int64(handle, iCol, value);
}

int SQLiteSTMT::Bind(int iCol) {
  return sqlite3_bind_null(handle, iCol);
}

int SQLiteSTMT::Bind(int iCol, const char* value, int len, void destructor(void*)) {
  return sqlite3_bind_text(handle, iCol, value, len, destructor);
}

int SQLiteSTMT::Bind(int iCol, const sqlite3_value* value) {
  return sqlite3_bind_value(handle, iCol, value);
}

int SQLiteSTMT::BindBlob(int iCol, const void* value, int len, void destructor(void*)) {
  return sqlite3_bind_blob(handle, iCol, value, len, destructor);
}

int SQLiteSTMT::BindInt(int iCol, int value) {
  return sqlite3_bind_int(handle, iCol, value);
}

int SQLiteSTMT::BindText16(int iCol, const void* value, int len, void destructor(void*)) {
  return sqlite3_bind_text16(handle, iCol, value, len, destructor);
}

int SQLiteSTMT::BindZeroBlob(int iCol, int len) {
  return sqlite3_bind_zeroblob(handle, iCol, len);
}

int SQLiteSTMT::ClearBindings() {
  return sqlite3_clear_bindings(handle);
}

int SQLiteSTMT::Close() {
  if (!handle) {
	return SQLITE_OK;
  }

  int ret = sqlite3_finalize(handle);
  handle = 0;
  return ret;
}

const void* SQLiteSTMT::ColumnBlob(int iCol) {
  return sqlite3_column_blob(handle, iCol);
}

int SQLiteSTMT::ColumnBytes(int iCol) {
  return sqlite3_column_bytes(handle, iCol);
}

int SQLiteSTMT::ColumnBytes16(int iCol) {
  return sqlite3_column_bytes16(handle, iCol);
}

double SQLiteSTMT::ColumnDouble(int iCol) {
  return sqlite3_column_double(handle, iCol);
}

int SQLiteSTMT::ColumnInt(int iCol) {
  return sqlite3_column_int(handle, iCol);
}

sqlite3_int64 SQLiteSTMT::ColumnInt64(int iCol) {
  return sqlite3_column_int64(handle, iCol);
}
   
const unsigned char* SQLiteSTMT::ColumnText(int iCol) {
  return sqlite3_column_text(handle, iCol);
}
   
const void* SQLiteSTMT::ColumnText16(int iCol) {
  return sqlite3_column_text16(handle, iCol);
}

int SQLiteSTMT::ColumnType(int iCol) {
  return sqlite3_column_type(handle, iCol);
}

sqlite3_value* SQLiteSTMT::ColumnValue(int iCol) {
  return sqlite3_column_value(handle, iCol);
}

int SQLiteSTMT::Reset() {
  return sqlite3_reset(handle);
}

int SQLiteSTMT::Step() {
  return sqlite3_step(handle);
}