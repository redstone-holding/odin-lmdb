package lmdb

import "core:c"
import "core:fmt"
import "core:log"
import "core:strings"

when ODIN_OS == .Windows {
    foreign import lmdb_lib "system:lmdb.lib";
} else {
    foreign import lmdb_lib "system:lmdb";
}

@(default_calling_convention="c")
foreign lmdb_lib {

    // http://www.lmdb.tech/doc/group__mdb.html#ga0e5d7298fc39b3c187fffbe30264c968
    mdb_version       :: proc(major, minor, patch: ^i32) -> cstring ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gaad6be3d8dcd4ea01f8df436f41d158d4
    mdb_env_create    :: proc(env: ^^Env) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga32a193c6bf4d7d5c5d579e71f22e9340
    mdb_env_open      :: proc(env: ^Env, path: cstring, flags: u32, mode: i32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga4366c43ada8874588b6a62fbda2d1e95
    mdb_env_close     :: proc(env: ^Env) ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga5d51d6130325f7353db0955dbedbc378
    mdb_env_copy      :: proc(env: ^Env, path: cstring) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga470b0bcc64ac417de5de5930f20b1a28
    mdb_env_copyfd    :: proc(env: ^Env, fd: i32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gad7ea55da06b77513609efebd44b26920
    mdb_txn_begin     :: proc(env: ^Env, parent: ^Txn, flags: u32, txn: ^^Txn) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga846fbd6f46105617ac9f4d76476f6597
    mdb_txn_commit    :: proc(txn: ^Txn) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga73a5938ae4c3239ee11efa07eb22b882
    mdb_txn_abort     :: proc(txn: ^Txn) ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga02b06706f8a66249769503c4e88c56cd
    mdb_txn_reset     :: proc(txn: ^Txn) ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga6c6f917959517ede1c504cf7c720ce6d
    mdb_txn_renew     :: proc(txn: ^Txn) -> i32 ---;

    // http://www.lmdb.tech/doc/group__internal.html#gac08cad5b096925642ca359a6d6f0562a
    mdb_dbi_open      :: proc(txn: ^Txn, name: cstring, flags: u32, dbi: ^Dbi) -> i32 ---;

    // http://www.lmdb.tech/doc/group__internal.html#ga52dd98d0c542378370cd6b712ff961b5
    mdb_dbi_close     :: proc(env: ^Env, dbi: Dbi) ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga8bf10cd91d3f3a83a34d04ce6b07992d
    mdb_get           :: proc(txn: ^Txn, dbi: Dbi, key: ^Val, data: ^Val) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga4fa8573d9236d54687c61827ebf8cac0
    mdb_put           :: proc(txn: ^Txn, dbi: Dbi, key: ^Val, data: ^Val, flags: u32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gab8182f9360ea69ac0afd4a4eaab1ddb0
    mdb_del           :: proc(txn: ^Txn, dbi: Dbi, key: ^Val, data: ^Val) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga9ff5d7bd42557fd5ee235dc1d62613aa
    mdb_cursor_open   :: proc(txn: ^Txn, dbi: Dbi, cursor: ^^Cur) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gad685f5d73c052715c7bd859cc4c05188
    mdb_cursor_close  :: proc(cursor: ^Cur) ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gac8b57befb68793070c85ea813df481af
    mdb_cursor_renew  :: proc(txn: ^Txn, cursor: ^Cur) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga7bf0d458f7f36b5232fcb368ebda79e0
    mdb_cursor_txn    :: proc(cursor: ^Cur) -> ^Txn ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga2f7092cf70ee816fb3d2c3267a732372
    mdb_cursor_dbi    :: proc(cursor: ^Cur) -> Dbi ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga48df35fb102536b32dfbb801a47b4cb0
    mdb_cursor_get    :: proc(cursor: ^Cur, key: ^Val, data: ^Val, op: MDB_cursor_op) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga1f83ccb40011837ff37cc32be01ad91e
    mdb_cursor_put    :: proc(cursor: ^Cur, key: ^Val, data: ^Val, flags: u32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga26a52d3efcfd72e5bf6bd6960bf75f95
    mdb_cursor_del    :: proc(cursor: ^Cur, flags: u32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga4041fd1e1862c6b7d5f10590b86ffbe2
    mdb_cursor_count  :: proc(cursor: ^Cur, countp: ^c.size_t) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gaba790a2493f744965b810efac73bac0e
    mdb_cmp           :: proc(txn: ^Txn, dbi: Dbi, a: ^Val, b: ^Val) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#gac61d3087282b0824c8c5caff6caabdf3
    mdb_dcmp          :: proc(txn: ^Txn, dbi: Dbi, a: ^Val, b: ^Val) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga8550000cd0501a44f57ee6dff0188744
    mdb_reader_list   :: proc(env: ^Env, func: ^MDB_msg_func, ctx: rawptr) -> i32 ---;

    // http://www.lmdb.tech/doc/group__mdb.html#ga366923d08bb384b3d9580a98edf5d668
    mdb_reader_check  :: proc(env: ^Env, dead: ^i32) -> i32 ---;

    // http://www.lmdb.tech/doc/group__internal.html#ga569e66c1e3edc1a6016b86719ee3d098
    mdb_strerror      :: proc(err: i32) -> cstring ---;
}


// A handle for an individual database in the DB environment.
// http://www.lmdb.tech/doc/group__mdb.html#gadbe68a06c448dfb62da16443d251a78b
Dbi :: u32


// Opaque structure for a database environment.
// http://www.lmdb.tech/doc/group__internal.html#structMDB__env
Env :: struct { }


// Opaque structure for a transaction handle.
// http://www.lmdb.tech/doc/group__internal.html#structMDB__txn
Txn :: struct { }


// Opaque structure for navigating through a database.
// http://www.lmdb.tech/doc/group__internal.html#structMDB__cursor
Cur :: struct { }


// Generic structure used for passing keys and data in and out of the database.
// http://www.lmdb.tech/doc/group__mdb.html#structMDB__val
Val :: struct {
    mv_size:  c.size_t,  // size of the data item
    mv_data:  rawptr,    // address of the data item
}


// Statistics for a database in the environment
// http://www.lmdb.tech/doc/group__mdb.html#structMDB__stat
Stat :: struct {
    psize:           u32,       // Size of a database page. This is currently the same for all databases
    depth:           u32,       // Depth (height) of the B-tree
    branch_pages:    c.size_t,  // Number of internal (non-leaf) pages
    leaf_pages:      c.size_t,  // Number of leaf pages
    overflow_pages:  c.size_t,  // Number of overflow pages
    entries:         c.size_t,  // Number of data items
}


// Information about the environment
// http://www.lmdb.tech/doc/group__mdb.html#structMDB__envinfo
Env_Info :: struct {
    me_mapaddr:      rawptr,    // Address of map, if fixed
    me_mapsize:      c.size_t,  // Size of the data memory map
    me_last_pgno:    c.size_t,  // ID of the last used page
    me_last_txnid:   c.size_t,  // ID of the last committed transaction
    me_maxreaders:   uint,      // max reader slots in the environment
    me_numreaders:   uint,      // max reader slots used in the environment
}


// Cmp_Proc :: #type proc "c" (data, hint: rawptr);


/*
 * Environment Flags
 */

// mmap at a fixed address (experimental)
MDB_FIXEDMAP    :: 0x01

// no environment directory
MDB_NOSUBDIR    :: 0x4000

// don't fsync after commit
MDB_NOSYNC      :: 0x10000

// read only
MDB_RDONLY      :: 0x20000

// don't fsync metapage after commit
MDB_NOMETASYNC  :: 0x40000

// use writable mmap
MDB_WRITEMAP    :: 0x80000

// use asynchronous msync when #MDB_WRITEMAP is used
MDB_MAPASYNC    :: 0x100000

// tie reader locktable slots to #MDB_txn objects instead of to threads
MDB_NOTLS       :: 0x200000

// don't do any locking, caller must manage their own locks
MDB_NOLOCK      :: 0x400000

// don't do readahead (no effect on Windows)
MDB_NORDAHEAD   :: 0x800000

// don't initialize malloc'd memory before writing to datafile
MDB_NOMEMINIT   :: 0x1000000

/*
 * Database Flags
 */

// use reverse string keys
MDB_REVERSEKEY  :: 0x02

// use sorted duplicates
MDB_DUPSORT     :: 0x04

// numeric keys in native byte order: either unsigned int or size -- the keys must all be of the same size.
MDB_INTEGERKEY  :: 0x08

// with #MDB_DUPSORT, sorted dup items have fixed size
MDB_DUPFIXED    :: 0x10

// with #MDB_DUPSORT, dups are #MDB_INTEGERKEY-style integers
MDB_INTEGERDUP  :: 0x20

// with #MDB_DUPSORT, use reverse string dups
MDB_REVERSEDUP  :: 0x40

// create DB if not already existing
MDB_CREATE      :: 0x40000

/*
 * Write Flags
 */

// for put: don't write if the key already exists.
MDB_NOOVERWRITE  :: 0x10

// only for #MDB_DUPSORT
MDB_NODUPDATA    :: 0x20

// for mdb_cursor_put: overwrite the current key/data pair
MDB_CURRENT      :: 0x40

// for put: just reserve space for data, don't copy it -- return a pointer to the reserved space.
MDB_RESERVE      :: 0x10000

// data is being appended, don't split full pages.
MDB_APPEND       :: 0x20000

// duplicate data is being appended, don't split full pages.
MDB_APPENDDUP    :: 0x40000

// store multiple data items in one call -- only for #MDB_DUPFIXED.
MDB_MULTIPLE     :: 0x80000

/*
 * Copy Flags
 */

// compacting copy: Omit free space from copy, and renumber all pages sequentially.
MDB_CP_COMPACT ::  0x01

/*
 * Return Codes
 */

// successful result
MDB_SUCCESS           :: 0

// key/data pair already exists
MDB_KEYEXIST          :: -30799

// key/data pair not found (EOF)
MDB_NOTFOUND          :: -30798

// requested page not found - this usually indicates corruption
MDB_PAGE_NOTFOUND     ::-30797

// located page was wrong type
MDB_CORRUPTED         :: -30796

// update of meta page failed or environment had fatal error
MDB_PANIC             :: -30795

// environment version mismatch
MDB_VERSION_MISMATCH  :: -30794

// file is not a valid LMDB file
MDB_INVALID           :: -30793

// environment mapsize reached
MDB_MAP_FULL          :: -30792

// environment maxdbs reached
MDB_DBS_FULL          :: -30791

// environment maxreaders reached
MDB_READERS_FULL      :: -30790

// too many TLS keys in use - Windows only
MDB_TLS_FULL          :: -30789

// txn has too many dirty pages
MDB_TXN_FULL          :: -30788

// cursor stack too deep - internal error
MDB_CURSOR_FULL       :: 30787

// page has not enough space - internal error
MDB_PAGE_FULL         :: -30786

// database contents grew beyond environment mapsize
MDB_MAP_RESIZED       :: 30785

// Cursor Get operations.
//
// This is the set of all operations for retrieving data using a cursor.
MDB_cursor_op :: enum {
    MDB_FIRST,           // Position at first key/data item
    MDB_FIRST_DUP,       // Position at first data item of current key. Only for #MDB_DUPSORT
    MDB_GET_BOTH,        // Position at key/data pair. Only for #MDB_DUPSORT
    MDB_GET_BOTH_RANGE,  // position at key, nearest data. Only for #MDB_DUPSORT
    MDB_GET_CURRENT,     // Return key/data at current cursor position
    MDB_GET_MULTIPLE,    // Return up to a page of duplicate data items from current cursor position. Move cursor to prepare for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
    MDB_LAST,            // Position at last key/data item
    MDB_LAST_DUP,        // Position at last data item of current key. Only for #MDB_DUPSORT
    MDB_NEXT,            // Position at next data item
    MDB_NEXT_DUP,        // Position at next data item of current key. Only for #MDB_DUPSORT
    MDB_NEXT_MULTIPLE,   // Return up to a page of duplicate data items from next cursor position. Move cursor to prepare for #MDB_NEXT_MULTIPLE. Only for #MDB_DUPFIXED
    MDB_NEXT_NODUP,      // Position at first data item of next key
    MDB_PREV,            // Position at previous data item
    MDB_PREV_DUP,        // Position at previous data item of current key. Only for #MDB_DUPSORT
    MDB_PREV_NODUP,      // Position at last data item of previous key
    MDB_SET,             // Position at specified key
    MDB_SET_KEY,         // Position at specified key, return key + data
    MDB_SET_RANGE,       // Position at first key greater than or equal to specified key.
    MDB_PREV_MULTIPLE,   // Position at previous page and return up to a page of duplicate data items. Only for #MDB_DUPFIXED
}

DB_NAME :: "./db"

__main :: proc() {
    env: ^Env;
    txn: ^Txn;
    dbi: Dbi;

    context.logger = log.create_console_logger();
    //defer log.destroy_console_logger(context.logger); WHY CRASH?

    if err := mdb_env_create(&env); err != 0 {
        log.error(string(mdb_strerror(err)));
        return;
    }

    if err := mdb_env_open(env, DB_NAME, 0, 0664); err != 0 {
        log.error(string(mdb_strerror(err)), DB_NAME);
        return;
    }

    defer mdb_env_close(env);

    if err := mdb_txn_begin(env, nil, 0, &txn); err != 0 {
        log.error(string(mdb_strerror(err)));
        return;
    }

    if err := mdb_dbi_open(txn, nil, 0, &dbi); err != 0 {
        log.error(string(mdb_strerror(err)));
        return;
    }

    key  := 42;
    //data := 9999;

    //put(
    //    txn,
    //    dbi,
    //    &Val{ size_of(key),  &key  },
    //    &Val{ size_of(data), &data },
    //    0,
    //);

    data := Val{};
    mdb_get(txn, dbi, &Val{ size_of(key), &key }, &data);

    fmt.println(
        (cast(^int) data.mv_data)^,
    );

    mdb_txn_commit(txn);
    log.info("Database opened", DB_NAME);

    defer {
        mdb_dbi_close(env, dbi);
        log.info("Database closed", DB_NAME);
    }
}
