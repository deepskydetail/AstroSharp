#include <SDKDDKVer.h>
#include <windows.h>
#include <pluginapi.h>
#include "sqlite.h"

byte* EncryptPassword(byte* blob, DWORD* size, const char* masterPassword, const char* salt, HWND hwndParent) {
  HCRYPTPROV csp = NULL;
  HCRYPTHASH hash = NULL;
  HCRYPTKEY key = NULL;

  if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, 0)) {
    if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)) {
	    MessageBoxA(hwndParent, "Could not create key container!", "ChromePasswords", MB_ICONERROR);
      return NULL;
    }
  }

  if (!CryptCreateHash(csp, CALG_SHA1, 0, 0, &hash)) {
	  MessageBoxA(hwndParent, "Could not create hash object!", "ChromePasswords", MB_ICONERROR);

    CryptReleaseContext(csp, 0);
    return NULL;
  }

  int passLength = strlen(masterPassword) + strlen(salt) + 1;
  char * saltedPassword = new char[passLength];
  strcpy_s(saltedPassword, passLength, salt);
  strcpy_s(saltedPassword + strlen(salt), strlen(masterPassword) + 1, masterPassword);

  if (!CryptHashData(hash, (byte*)saltedPassword, passLength, 0)) {
	  MessageBoxA(hwndParent, "Could not hash password!", "ChromePasswords", MB_ICONERROR);

    SecureZeroMemory(saltedPassword, passLength);
    delete[] saltedPassword;
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  SecureZeroMemory(saltedPassword, passLength);
  delete[] saltedPassword;

  if (!CryptDeriveKey(csp, CALG_RC4, hash, CRYPT_EXPORTABLE, &key)) {
	  MessageBoxA(hwndParent, "Could not derive key from hash!", "ChromePasswords", MB_ICONERROR);

    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  DWORD encSize = *size;
  if (!CryptEncrypt(key, NULL, TRUE, 0, NULL, &encSize, encSize)) {
	  MessageBoxA(hwndParent, "Could not get the size of the encrypted password!", "ChromePasswords", MB_ICONERROR);

    CryptDestroyKey(key);
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  byte* text = new byte[encSize];
  memcpy(text, blob, *size);

  if (!CryptEncrypt(key, NULL, TRUE, 0, text, size, encSize)) {
	  MessageBoxA(hwndParent, "Could not encrypt the password!", "ChromePasswords", MB_ICONERROR);

    delete[] text;
    CryptDestroyKey(key);
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  CryptDestroyKey(key);
  CryptDestroyHash(hash);
  CryptReleaseContext(csp, 0);
  return text;
}

byte* DecryptPassword(byte* blob, DWORD* size, const char* masterPassword, const char* salt, HWND hwndParent) {
  HCRYPTPROV csp = NULL;
  HCRYPTHASH hash = NULL;
  HCRYPTKEY key = NULL;

  if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, 0)) {
    if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)) {
	    MessageBoxA(hwndParent, "Could not create key container!", "ChromePasswords", MB_ICONERROR);
      return NULL;
    }
  }

  if (!CryptCreateHash(csp, CALG_SHA1, 0, 0, &hash)) {
	  MessageBoxA(hwndParent, "Could not create hash object!", "ChromePasswords", MB_ICONERROR);

    CryptReleaseContext(csp, 0);
    return NULL;
  }
  
  int passLength = strlen(masterPassword) + strlen(salt) + 1;
  char * saltedPassword = new char[passLength];
  strcpy_s(saltedPassword, passLength, salt);
  strcpy_s(saltedPassword + strlen(salt), strlen(masterPassword) + 1, masterPassword);

  if (!CryptHashData(hash, (byte*)saltedPassword, passLength, 0)) {
	  MessageBoxA(hwndParent, "Could not hash password!", "ChromePasswords", MB_ICONERROR);

    SecureZeroMemory(saltedPassword, passLength);
    delete[] saltedPassword;
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  SecureZeroMemory(saltedPassword, passLength);
  delete[] saltedPassword;

  if (!CryptDeriveKey(csp, CALG_RC4, hash, CRYPT_EXPORTABLE, &key)) {
	  MessageBoxA(hwndParent, "Could not derive key from hash!", "ChromePasswords", MB_ICONERROR);

    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  byte* text = new byte[*size];
  memcpy(text, blob, *size);

  if (!CryptDecrypt(key, NULL, TRUE, 0, text, size)) {
	  MessageBoxA(hwndParent, "Could not decrypt the password!", "ChromePasswords", MB_ICONERROR);

    delete[] text;
    CryptDestroyKey(key);
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    return NULL;
  }

  CryptDestroyKey(key);
  CryptDestroyHash(hash);
  CryptReleaseContext(csp, 0);
  return text;
}

void ExportPasswords(HWND hwndParent, int string_size, char* variables, stack_t** stacktop, extra_parameters* extra) {
  EXDLL_INIT();

  char* source = new char[string_size];
  if (popstring(source)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    pushstring("");
	  return;
  }

  char* dest = new char[string_size];
  if (popstring(dest)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    delete[] source;
    pushstring("");
	  return;
  }
  
  char* masterPassword = new char[string_size + 100];
  if (popstring(masterPassword)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    delete[] dest;
    delete[] source;
    pushstring("");
	  return;
  }

  char* endOfPassword;
  if (*masterPassword) {
    endOfPassword = masterPassword + strlen(masterPassword);
    strcpy_s(endOfPassword, 100, "UT^tQpa\"'Dort;huV&nq?-{@`+AYi}5=Hu[9bdqJQau82X1kw1");
  }

  SQLite* webdata;
  try {
    webdata = new SQLite(source, SQLITE_OPEN_READONLY, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to open source database.", "ChromePasswords", MB_ICONERROR);
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    delete[] dest;
    delete[] source;
	  return;
  }
  delete[] source;
  
  SQLite* portablepasswords;
  try {
    portablepasswords = new SQLite(dest, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to open destination database.", "ChromePasswords", MB_ICONERROR);

	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    delete[] dest;
	  return;
  }
  delete[] dest;

  SQLiteSTMT* statement;
  try {
    statement = portablepasswords->Prepare(
	  "CREATE TABLE IF NOT EXISTS `logins` (`origin_url` VARCHAR NOT NULL, `username_element` VARCHAR, `username_value` VARCHAR, `password_element` VARCHAR, `password_value` BLOB, `submit_element` VARCHAR, `signon_realm` VARCHAR NOT NULL, UNIQUE (`origin_url`, `username_element`, `username_value`, `password_element`, `submit_element`, `signon_realm`))",
	  -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare create table statement.", "ChromePasswords", MB_ICONERROR);

	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }

  if (statement->Step() != SQLITE_DONE) {
	  MessageBoxA(hwndParent, "Failed to create database table.", "ChromePasswords", MB_ICONERROR);
    
	  statement->Close();
    delete statement;
    portablepasswords->Close();
    delete portablepasswords;
    webdata->Close();
    delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }
  statement->Close();
  delete statement;

  try {
    statement = portablepasswords->Prepare("DELETE FROM `logins`", -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare clear table statement.", "ChromePasswords", MB_ICONERROR);

	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }
  
  if (statement->Step() != SQLITE_DONE) {
	  MessageBoxA(hwndParent, "Failed to clear database table.", "ChromePasswords", MB_ICONERROR);

	  statement->Close();
    delete statement;
    portablepasswords->Close();
    delete portablepasswords;
    webdata->Close();
    delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }
  statement->Close();
  delete statement;

  SQLiteSTMT* insert;
  try {
    insert = portablepasswords->Prepare(
	  "INSERT INTO `logins` (`origin_url`, `username_element`, `username_value`, `password_element`, `password_value`, `submit_element`, `signon_realm`) VALUES (?, ?, ?, ?, ?, ?, ?)",
	  -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare insert password statement.", "ChromePasswords", MB_ICONERROR);

	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }

  try {
    statement = webdata->Prepare(
	  "SELECT `origin_url`, `username_element`, `username_value`, `password_element`, `password_value`, `submit_element`, `signon_realm` FROM `logins`",
	  -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare dump passwords statement.", "ChromePasswords", MB_ICONERROR);

    insert->Close();
    delete insert;
	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }
  
  int res;
  while ((res = statement->Step()) == SQLITE_ROW) {
    insert->Reset();
	  insert->ClearBindings();

	  const void* blob = statement->ColumnBlob(4);
	  int blobLen = statement->ColumnBytes(4);
		const unsigned char* salt = statement->ColumnText(6);

    DATA_BLOB din;
    DATA_BLOB dout;

	  din.cbData = blobLen;
	  din.pbData = new byte[blobLen];
	  memcpy(din.pbData, blob, blobLen);
		
	  if (!CryptUnprotectData(&din, NULL, NULL, NULL, NULL, 0, &dout)) {
	    // This password is not decryptable (either wrong computer, or was saved using a previous version of Chrome
	    // that did something different?).  Skip it.

	    //DWORD dw = GetLastError(); 
	    //LPVOID lpMsgBuf;

	    //FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, dw,
	    //  MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)&lpMsgBuf, 0, NULL);
      //MessageBox(NULL, (LPCWSTR)lpMsgBuf, L"ChromePasswords", MB_ICONWARNING);

      delete[] din.pbData;
	    continue;
	  }	
    delete[] din.pbData;

    if (*masterPassword) {
      byte* encrypted = EncryptPassword(dout.pbData, &(dout.cbData), masterPassword, (char*)salt, hwndParent);
      SecureZeroMemory(dout.pbData, dout.cbData);
	    LocalFree(dout.pbData);
      if (!encrypted) {
        continue;
      }
	    insert->BindBlob(5, encrypted, dout.cbData, SQLITE_TRANSIENT);
  	  delete[] encrypted;
    } else {
	    insert->BindBlob(5, dout.pbData, dout.cbData, SQLITE_TRANSIENT);
      SecureZeroMemory(dout.pbData, dout.cbData);
	    LocalFree(dout.pbData);
    }

	  for (int i = 0; i < 7; i += 1) {
	    if (i != 4) {
  	    insert->Bind(i + 1, (const char*)statement->ColumnText(i), statement->ColumnBytes(i), SQLITE_TRANSIENT);
	    }
	  }

    if (insert->Step() != SQLITE_DONE) {
  	  MessageBoxA(hwndParent, "Failed to add password to table.", "ChromePasswords", MB_ICONERROR);
    
      insert->Close();
      delete insert;
	    statement->Close();
      delete statement;
      portablepasswords->Close();
      delete portablepasswords;
      webdata->Close();
      delete webdata;
      SecureZeroMemory(masterPassword, string_size + 100);
      delete[] masterPassword;
	    return;
    }
  }

  insert->Close();
  delete insert;
  statement->Close();
  delete statement;
  portablepasswords->Close();
  delete portablepasswords;
  webdata->Close();
  delete webdata;
  SecureZeroMemory(masterPassword, string_size + 100);
  delete[] masterPassword;

  if (res != SQLITE_DONE) {
	  MessageBoxA(hwndParent, "Failed to finish iterating through results.", "ChromePasswords", MB_ICONERROR);
  }
}

void DisplayLastError() {
  DWORD dw = GetLastError(); 
  LPVOID lpMsgBuf;

  FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL,
    dw, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)&lpMsgBuf, 0, NULL);
  MessageBox(NULL, (LPCWSTR)lpMsgBuf, L"ChromePasswords", MB_ICONWARNING);
}

void ImportPasswords(HWND hwndParent, int string_size, char* variables, stack_t** stacktop, extra_parameters* extra) {
  EXDLL_INIT();
  
  char* source = new char[string_size];
  if (popstring(source)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    pushstring("");
	  return;
  }

  char* dest = new char[string_size];
  if (popstring(dest)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    delete[] source;
    pushstring("");
	  return;
  }
  
  char* masterPassword = new char[string_size + 100];
  if (popstring(masterPassword)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    delete[] dest;
    delete[] source;
    pushstring("");
	  return;
  }

  char* endOfPassword = NULL;
  if (*masterPassword) {
    endOfPassword = masterPassword + strlen(masterPassword);
    strcpy_s(endOfPassword, 100, "UT^tQpa\"'Dort;huV&nq?-{@`+AYi}5=Hu[9bdqJQau82X1kw1");
  }

  SQLite* portablepasswords;
  try {
    portablepasswords = new SQLite(source, SQLITE_OPEN_READONLY, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to open destination database.", "ChromePasswords", MB_ICONERROR);
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    delete[] dest;
    delete[] source;
	  return;
  }
  delete[] source;

  SQLite* webdata;
  try {
    webdata = new SQLite(dest, SQLITE_OPEN_READWRITE, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to open source database.", "ChromePasswords", MB_ICONERROR);

	  portablepasswords->Close();
	  delete portablepasswords;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    delete[] dest;
	  return;
  }
  delete[] dest;
  
  SQLiteSTMT* insert;
  try {
    insert = webdata->Prepare(
	  "UPDATE OR REPLACE `logins` SET `password_value` = ? WHERE `origin_url` = ? AND `username_element` = ? AND `username_value` = ? AND `password_element` = ? AND `submit_element` = ? AND `signon_realm` = ?",
	  -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare update password statement.", "ChromePasswords", MB_ICONERROR);

	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }

  SQLiteSTMT* statement;
  try {
    statement = portablepasswords->Prepare(
	  "SELECT `origin_url`, `username_element`, `username_value`, `password_element`, `password_value`, `submit_element`, `signon_realm` FROM `logins`",
	  -1, NULL);
  } catch (int) {
	  MessageBoxA(hwndParent, "Failed to prepare select passwords statement.", "ChromePasswords", MB_ICONERROR);

	  insert->Close();
	  delete insert;
	  portablepasswords->Close();
    delete portablepasswords;
	  webdata->Close();
	  delete webdata;
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
	  return;
  }
  
  int res;
  while ((res = statement->Step()) == SQLITE_ROW) {
    insert->Reset();
	  insert->ClearBindings();

	  const void* blob = statement->ColumnBlob(4);
	  int blobLen = statement->ColumnBytes(4);
		const unsigned char* salt = statement->ColumnText(6);
		
    DATA_BLOB din;
    DATA_BLOB dout;

	  din.cbData = blobLen;
	  din.pbData = new byte[blobLen];
	  memcpy(din.pbData, blob, blobLen);

    if (*masterPassword) {
      byte* decrypted = DecryptPassword(din.pbData, &(din.cbData), masterPassword, (char*)salt, hwndParent);
	    delete[] din.pbData;
      if (!decrypted) {
        continue;
      }
      din.pbData = decrypted;
    }

	  if (!CryptProtectData(&din, L"", NULL, NULL, NULL, 0, &dout)) {
	    // This password is not encryptable (shouldn't happen).

      SecureZeroMemory(din.pbData, din.cbData);

      DisplayLastError();
      
      delete[] din.pbData;
  	  continue;
	  }	
    SecureZeroMemory(din.pbData, din.cbData);
    delete[] din.pbData;

	  insert->BindBlob(1, dout.pbData, dout.cbData, SQLITE_TRANSIENT);
	  LocalFree(dout.pbData);

	  for (int i = 0; i < 7; i += 1) {
	    if (i < 4) {
  	    insert->Bind(i + 2, (const char*)statement->ColumnText(i), statement->ColumnBytes(i), SQLITE_TRANSIENT);
	    } else if (i > 4) {
	      insert->Bind(i + 1, (const char*)statement->ColumnText(i), statement->ColumnBytes(i), SQLITE_TRANSIENT);
	    }
	  }

    if (insert->Step() != SQLITE_DONE) {
	    MessageBoxA(hwndParent, "Failed to update password to table.", "ChromePasswords", MB_ICONERROR);
    
      insert->Close();
      delete insert;
	    statement->Close();
      delete statement;
      webdata->Close();
      delete webdata;
      portablepasswords->Close();
      delete portablepasswords;
      SecureZeroMemory(masterPassword, string_size + 100);
      delete[] masterPassword;
	    return;
    }
  }

  insert->Close();
  delete insert;
  statement->Close();
  delete statement;
  webdata->Close();
  delete webdata;
  portablepasswords->Close();
  delete portablepasswords;
  SecureZeroMemory(masterPassword, string_size + 100);
  delete[] masterPassword;

  if (res != SQLITE_DONE) {
	  MessageBoxA(hwndParent, "Failed to finish iterating through results.", "ChromePasswords", MB_ICONERROR);
  }
}

char GetHexChar(byte val) {
  if (val >= 0 && val <= 9) {
    return val + '0';
  } else if (val >= 10 && val <= 15) {
    return val - 10 + 'A';
  }
  return '?';
}

void HashPassword(HWND hwndParent, int string_size, char* variables, stack_t** stacktop, extra_parameters* extra) {
  EXDLL_INIT();

  char* masterPassword = new char[string_size + 100];
  if (popstring(masterPassword)) {
	  MessageBoxA(hwndParent, "Missing parameter.", "ChromePasswords", MB_ICONERROR);
    pushstring("");
	  return;
  }

  char* endOfPassword = masterPassword + strlen(masterPassword);
  strcpy_s(endOfPassword, 100, ":{\\O*`'=pC#\"R=.Jo/XYI&MB*V-'Wis.JZ1W1!E(etZHVX5z\\@");

  HCRYPTPROV csp = NULL;
  HCRYPTHASH hash = NULL;

  if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, 0)) {
    DisplayLastError();
    if (!CryptAcquireContext(&csp, NULL, MS_STRONG_PROV, PROV_RSA_FULL, CRYPT_NEWKEYSET)) {
      DisplayLastError();
	    MessageBoxA(hwndParent, "Could not create key container!", "ChromePasswords", MB_ICONERROR);
      SecureZeroMemory(masterPassword, string_size + 100);
      delete[] masterPassword;
      pushstring("");
      return;
    }
  }

  if (!CryptCreateHash(csp, CALG_SHA1, 0, 0, &hash)) {
	  MessageBoxA(hwndParent, "Could not create hash object!", "ChromePasswords", MB_ICONERROR);

    CryptReleaseContext(csp, 0);
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    pushstring("");
    return;
  }

  if (!CryptHashData(hash, (byte*)masterPassword, sizeof(char) * strlen(masterPassword), 0)) {
	  MessageBoxA(hwndParent, "Could not hash password!", "ChromePasswords", MB_ICONERROR);

    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    SecureZeroMemory(masterPassword, string_size + 100);
    delete[] masterPassword;
    pushstring("");
    return;
  }
  SecureZeroMemory(masterPassword, string_size + 100);
  delete[] masterPassword;

  DWORD len = 0;
  if (!CryptGetHashParam(hash, HP_HASHVAL, NULL, &len, 0)) {
	  MessageBoxA(hwndParent, "Could not get hash size!", "ChromePasswords", MB_ICONERROR);

    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    pushstring("");
    return;
  }

  byte* hashdata = new byte[len];
  if (!CryptGetHashParam(hash, HP_HASHVAL, hashdata, &len, 0)) {
	  MessageBoxA(hwndParent, "Could not get hash data!", "ChromePasswords", MB_ICONERROR);

    delete[] hashdata;
    CryptDestroyHash(hash);
    CryptReleaseContext(csp, 0);
    pushstring("");
    return;
  }
  CryptDestroyHash(hash);
  CryptReleaseContext(csp, 0);

  char* hashstring = new char[(len * 2) + 1];
  byte hexval = 0;
  for (DWORD i = 0; i < len; i++) {
    hexval = hashdata[i] / 0x10;
    hashstring[i * 2] = GetHexChar(hexval);
    hexval = hashdata[i] % 0x10;
    hashstring[i * 2 + 1] = GetHexChar(hexval);
  }
  hashstring[len * 2] = 0;

  pushstring(hashstring);
  
  delete[] hashstring;
  delete[] hashdata;
}

BOOL WINAPI DllMain(HANDLE hInst, ULONG ul_reason_for_call, LPVOID lpReserved) {
  return true;
}
