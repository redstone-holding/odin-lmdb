package lmdb

import "core:c"
import "core:log"

/*
 * TODO: Split binding into separate file
 */

when ODIN_OS == .Windows {
  foreign import lmdb_lib "system:lmdb.lib";
} else {
  foreign import lmdb_lib "system:lmdb";
}

ENABLE_LOGGING :: true;

Some_Flags :: enum {

  // MMAP at a fixed address (experimental)
  Fixed_Map = 0x01,

  // No environment directory
  No_Sub_Dir = 0x4000,

  // Don't fsync after commit
  No_Sync = 0x10000,

  // Read only
  Read_Only = 0x20000,

  // Don't fsync metapage after commit
  No_Meta_Sync = 0x40000,

  // Use writable mmap
  Write_Map = 0x80000,

  // Use asynchronous msync when #MDB_WRITEMAP is used
  Map_Async = 0x100000,

  // Tie reader locktable slots to #MDB_txn objects instead of to threads
  No_Tls = 0x200000,

  // Don't do any locking, caller must manage their own locks
  No_Lock = 0x400000,

  // Don't do readahead (no effect on Windows)
  No_Read_Ahead = 0x800000,

  // Don't initialize malloc'd memory before writing to datafile
  No_Mem_Init = 0x1000000,
}


Open_Flags :: enum u32 {

  None = 0x0,

  // Use reverse string keys
  Reverse_Key = 0x02,

  // Use sorted duplicates
  Dup_Sort = 0x04,

  // Numeric keys in native byte order: either unsigned int or size_t.  The keys must all be of the same size.
  Integer_Key = 0x08,

  // With #Dup_Sort, sorted dup items have fixed size
  Dup_Fixed = 0x10,

  // With #Dup_Sort, dups are #Integer_Key-style integers
  Integer_Dup = 0x20,

  // Create DB if not already existing
  Create = 0x40000,
}


// Cursor Get operations.
//
// This is the set of all operations for retrieving data using a cursor.
//
// http://www.lmdb.tech/doc/group__mdb.html#ga1206b2af8b95e7f6b0ef6b28708c9127
Cursor_Op :: enum {
  First,            // Position at first key/data item
  First_Dup,        // Position at first data item of current key. Only for #MDB_DUPSORT
  Get_Both,         // Position at key/data pair. Only for #MDB_DUPSORT
  Get_Both_Range,   // position at key, nearest data. Only for #MDB_DUPSORT
  Get_Current,      // Return key/data at current cursor position
  Get_Multiple,     // Return up to a page of duplicate data items from current cursor position. Move cursor to prepare for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
  Last,             // Position at last key/data item
  Last_Dup,         // Position at last data item of current key. Only for #MDB_DUPSORT
  Next,             // Position at next data item
  Next_Dup,         // Position at next data item of current key. Only for #MDB_DUPSORT
  Next_Multiple,    // Return up to a page of duplicate data items from next cursor position. Move cursor to prepare for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
  Next_Nodup,       // Position at first data item of next key
  Prev,             // Position at previous data item
  Prev_Dup,         // Position at previous data item of current key. Only for #MDB_DUPSORT
  Prev_Nodup,       // Position at last data item of previous key
  Set,              // Position at specified key
  Set_Key,          // Position at specified key, return key + data
  Set_Range,        // Position at first key greater than or equal to specified key.
  Prev_Multiple,    // Position at previous page and return up to a page of duplicate data items. Only for #MDB_DUPFIXED
}


Error :: enum {
  Ok,
  Key_Exist        = -30799,  // key/data pair already exists
  Not_Found        = -30798,  // key/data pair not found (EOF)
  Page_Not_Found   = -30797,  // Requested page not found - this usually indicates corruption
  Corrupted        = -30796,  // Located page was wrong type
  Panic            = -30795,  // Update of meta page failed or environment had fatal error
  Version_Mismatch = -30794,  // Environment version mismatch
  Invalid          = -30793,  // File is not a valid LMDB file
  Map_Full         = -30792,  // Environment mapsize reached
  Dbs_Full         = -30791,  // Environment maxdbs reached
  Readers_Full     = -30790,  // Environment maxreaders reached
  Tls_Full         = -30789,  // Too many TLS keys in use - Windows only
  Txn_Full         = -30788,  // Txn has too many dirty pages
  Cursor_Full      = -30787,  // Cursor stack too deep - internal error
  Page_Full        = -30786,  // Page has not enough space - internal error
  Map_Resized      = -30785,  // Database contents grew beyond environment mapsize
}


Ctx :: struct {
  env: ^Env,
	txn: ^Txn,
	dbi: Dbi,
}


create_environment :: #force_inline proc() -> (^Env, Error) {
  db_env: ^Env;

  if err := mdb_env_create(&db_env); err != 0 {
    return nil, Error(err);
  }

  return db_env, .Ok;
}


open_environment :: #force_inline proc(env: ^Env, path: cstring, flags: Open_Flags, mode: i32) -> Error {
  if err := mdb_env_open(env, cstring(path), u32(flags), mode); err != 0 {
    return Error(err);
  }

  return .Ok;
}


close_environment :: #force_inline proc(env: ^Env) {
  mdb_env_close(env);
}


open_dbi :: #force_inline proc(txn: ^Txn, name: cstring, flags: Open_Flags) -> (u32, Error) {
  dbi: Dbi
  
  if err := mdb_dbi_open(txn, name, u32(flags), &dbi); err != 0 {
    return 0, Error(err)
  }

  return dbi, .Ok;
}


close_dbi :: #force_inline proc(env: ^Env, dbi: Dbi) {
  mdb_dbi_close(env, dbi);
}


begin_transaction :: #force_inline proc(env: ^Env) -> (^Txn, Error) {
  txn: ^Txn;

  if err := mdb_txn_begin(env, nil, 0, &txn); err != 0 {
    return nil, Error(err);
  }

  return txn, .Ok;  
}


commit_transaction :: #force_inline proc(txn: ^Txn) -> Error {
  if err := mdb_txn_commit(txn); err != 0 {
    return Error(err);
  }

  return .Ok;
}


get :: #force_inline proc(txn: ^Txn, dbi: Dbi, key: ^Val) -> (Val, Error) {
  data := Val{}

  if err := mdb_get(txn, dbi, key, &data); err != 0 {
    return data, Error(err);
  }

  return data, .Ok;
}


put :: #force_inline proc(txn: ^Txn, dbi: Dbi, key: ^Val, data: ^Val, flags: u32) -> Error {
  if err := mdb_put(txn, dbi, key, data, flags); err != 0 {
    return Error(err);
  }

  return .Ok;
}


error_string :: proc (err: Error) -> string {
  return string(mdb_strerror(i32(err)));
}


example :: proc() -> Error {
  env := create_environment() or_return;
  open_environment(env, "./db", .None, 0644) or_return
  defer close_environment(env);

  txn := begin_transaction(env) or_return;
  defer commit_transaction(txn);

	dbi := open_dbi(txn, nil, .None) or_return;
  defer close_dbi(env, dbi);

  {
    key := 42;
    str := "Hey LDMB";
    kv  := Val{size_of(key), &key};
    dv  := Val{len(str), &str};
    put(txn, dbi, &kv, &dv, 0) or_return;
  }

  return .Ok;
}


// Temporary example program
main :: proc() {
  when (ENABLE_LOGGING) {
    context.logger = log.create_console_logger();
  }

  err := example();

  if err != .Ok {
    log.error(error_string(err));
  }
}