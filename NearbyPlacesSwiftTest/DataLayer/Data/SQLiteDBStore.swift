//
//  SQLiteDBStore.swift
//
//  Created by Abhishek Darak 
//

import UIKit
import Foundation
import os.log
import SQLite3

public class SQLiteDBStore {
    
    // Get the URL to db store file
    let dbURL: URL
    
    // The database pointer.
    var db: OpaquePointer?
    
    // Prepared statement https://www.sqlite.org/c3ref/stmt.html to insert an event into Table.
    // we use prepared statements for efficiency and safe guard against sql injection.
    var insertEntryStmt: OpaquePointer?
    var readEntryStmt: OpaquePointer?
    var updateEntryStmt: OpaquePointer?
    var deleteEntryStmt: OpaquePointer?
    
    let oslog = OSLog(subsystem: "myDB", category: "SQLiteIntegretion")
    
    init() {
        do {
            do {
                dbURL = try FileManager.default
                    .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent("mydb.db")
                print(dbURL.path)
            } catch {
                os_log("Some error occurred. Returning empty path.")
                dbURL = URL(fileURLWithPath: "")
                return
            }
            try openDB()
        } catch {
            //TODO: Handle the error gracefully after logging
            os_log("Some error occurred. Returning.")
            return
        }
    }
    
    // Open the DB at the given path. If file does not exists, it will create one for you
    func openDB() throws {
        if sqlite3_open(dbURL.path, &db) != SQLITE_OK { // error mostly because of corrupt database
            os_log("error opening database at %s", log: oslog, type: .error, dbURL.absoluteString)
            //            deleteDB(dbURL: dbURL)
            throw SqliteError(message: "error opening database \(dbURL.absoluteString)")
        }
    }
    
    // Code to delete a db file. Useful to invoke in case of a corrupt DB and re-create another
    func deleteDB(dbURL: URL) {
        os_log("removing db", log: oslog)
        do {
            try FileManager.default.removeItem(at: dbURL)
        } catch {
            os_log("exception while removing db %s", log: oslog, error.localizedDescription)
        }
    }
    
    func createTables() throws {
        
        
        self.compareDBSchema()
        
        // create the tables if they dont exist.
        // TODO the concern table will Define the create table statement and will be called here,
        var ret:Int32
        
        var sql = ""
        for table in DBSchema.TablesName {
            
            let table_vars = self.getTableVars(table_name: table)
            let column_fields = table_vars["fields"] as! [Int32:String]
            let column_type = table_vars["field_type"] as! [String:String]
            sql = self.getCreateTableSql(column_fields: column_fields, table_name: table, column_type:column_type)
            print(sql)
            ret =  sqlite3_exec(db, sql, nil, nil, nil)
            if (ret != SQLITE_OK) { // corrupt database.
                logDbErr("Error creating db table - \(table)")
                throw SqliteError(message: "unable to create table \(table)")
            }
            
        }
    }
    
    func compareDBSchema() {
        var db_tables = [String]()
        do {
            db_tables = try self.getDBSchema()
        } catch {
            print("error")
        }
        
        if db_tables.isEmpty == false && db_tables.count > 0 {
            for table in db_tables { //
                let columns = self.getTableColumns(sql: "SELECT * FROM " + table + " LIMIT 0 ")
                let table_vars = self.getTableVars(table_name: table)
                var is_table_updated = false
                var new_schema = [Int32:String]()
                if table_vars.count > 0 {
                    new_schema = table_vars["fields"] as! [Int32:String]
                } else {
                    is_table_updated = true
                }
                if is_table_updated == false && new_schema.count != columns.count {
                    is_table_updated = true
                    print("difference Found")
                }
                if is_table_updated == true {
                    for (_,column) in new_schema {
                        if is_table_updated == false && columns.contains(column) == false {
                            is_table_updated = true
                            print("difference Found ")
                        }
                    }
                }
                if is_table_updated == true {
                    print( "table = \(table) is to remove \(is_table_updated)" )
                    self.dropTables(table_name:table)
                }
            }
        }
    }
    
    func getDBSchema() throws -> [String]  {
        self.readEntryStmt = nil
        var columns = [String]()
        // ensure statements are created on first usage if nil
        guard self.prepareGetSchemaStmt() == SQLITE_OK else { throw SqliteError(message: "Error in prepareGetSchemaStmt") }
        
        defer {
            sqlite3_reset(self.readEntryStmt)
        }
        while sqlite3_step(readEntryStmt) == SQLITE_ROW {
            
            if let cString = sqlite3_column_text(readEntryStmt,0) {
                let value = String(cString: cString)
                columns.append(value)
            }
        }
        return columns
    }
    
    
    func deleteTables(table_name:String)   {
        
        let table_to_delete = table_name as String
        let tables = DBSchema.TablesName
        if table_to_delete == "all" {
            for tbl in tables {
                let drop3_sql =  "DELETE FROM " + tbl
                let ret =  sqlite3_exec(db, drop3_sql, nil, nil, nil)
                if (ret != SQLITE_OK) { // corrupt database.
                    logDbErr("Error dropping db table - \(tbl)")
                }
            }
        } else {
            if tables.contains(table_to_delete) {
                let drop3_sql =  "DELETE FROM " + table_to_delete
                let ret =  sqlite3_exec(db, drop3_sql, nil, nil, nil)
                if (ret != SQLITE_OK) { // corrupt database.
                    logDbErr("Error dropping db table - \(table_to_delete)")
                }
            }
        }
    }
    
    
    func dropTables(table_name:String)   {
        let drop3_sql =  "DROP TABLE IF EXISTS " + table_name
        let ret =  sqlite3_exec(db, drop3_sql, nil, nil, nil)
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error dropping db table - \(table_name)")
        }
    }
    
    func deleteRowByField(table_name:String, update_field:String, update_id:String) {
        
        // ensure statements are created on first usage if nil
        guard self.prepareDeleteRowStmt(table_name:table_name, field_name:update_field ) == SQLITE_OK else { return  }
        defer {
            sqlite3_reset(self.deleteEntryStmt)
        }
        if sqlite3_bind_text(self.deleteEntryStmt, 1, (update_id as NSString).utf8String, -1, nil) != SQLITE_OK {
            logDbErr("sqlite3_bind_text(deleteEntryStmt) ")
        }
        
        let r = sqlite3_step(self.deleteEntryStmt)
        
        if r != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure deleting \(table_name): \(errmsg)")
            logDbErr("sqlite3_step(deleteEntryStmt)")
            return
        }
        return
    }
    
    func getSaveFields(table_name:String, data:[String:Any], update_field:String) -> [String:Any] {
        let table_data = self.getTableVars(table_name: table_name)
        var result = [String:Any]()
        var values = data
        var is_update = false
        
        if update_field.isEmpty == false {
            is_update = true
        } else {
            let row_id =  UUID().uuidString
            values.updateValue(row_id, forKey: "id")
        }
        
        let table_fields:[Int32:String] = table_data["fields"] as! [Int32 : String]
        let field_types:[String:String] = table_data["field_type"] as! [String:String]
        
        var tbl_fields = [Int32:String]()
        
        for (field, _) in values {
            let key = table_fields.keysForValue(value: field)
            if key.count > 0 {
                tbl_fields.updateValue(field, forKey: key[0])
            } else {
                print("INVALID FIELD NAME = \(field)")
                return result
            }
        }
        
        result.updateValue(field_types, forKey: "field_types")
        result.updateValue(tbl_fields, forKey: "tbl_fields")
        result.updateValue(is_update, forKey: "is_update")
        
        return result
    }
    
    func save(table_name:String, data:[String:Any], update_field:String) {
        
        let table_data = self.getTableVars(table_name: table_name)
        
        var values = data
        var is_update = false
        
        if update_field.isEmpty == false {
            is_update = true
        } else {
            let row_id =  UUID().uuidString
            values.updateValue(row_id, forKey: "id")
        }
        
        let table_fields:[Int32:String] = table_data["fields"] as! [Int32 : String]
        let field_types:[String:String] = table_data["field_type"] as! [String:String]
        
        var tbl_fields = [Int32:String]()
        
        for (field, value) in values {
            let key = table_fields.keysForValue(value: field)
            if key.count > 0 {
                tbl_fields.updateValue(field, forKey: key[0])
            } else {
                print("INVALID FIELD NAME = \(field)")
                return
            }
        }
        
        // ensure statements are created on first usage if nil
        if is_update {
            guard self.prepareUpdateStmt(tbl_fields: tbl_fields, where_field: update_field, table_name: table_name) == SQLITE_OK else { return  }
        } else {
            guard self.prepareInsertEntryStmt(tbl_fields: tbl_fields,  table_name: table_name) == SQLITE_OK else { return  }
        }
        defer {
            sqlite3_reset(self.insertEntryStmt)
        }
        
        var i:Int32 = 0
        var other_field_value:String = ""
        
        let fields = tbl_fields.sorted(by: { $0.key < $1.key})
        for (_, field) in fields {
            
            let value = values[field]
            var field_type = "TEXT"
            if field_types[field] != nil {
                field_type = field_types[field]!
            }
            
            
            if field == update_field {
                other_field_value = value as! String
                continue
            }
            i = i + 1
            
            if field_type == "TEXT" {
                
                if sqlite3_bind_text(self.insertEntryStmt, i, (value as! NSString).utf8String, -1, nil) != SQLITE_OK {
                    logDbErr("sqlite3_bind_text(insertEntryStmt) String values")
                    return
                }
            } else if  field_type == "FLOAT"  {
                
                if sqlite3_bind_double(self.insertEntryStmt, i, value as! Double) != SQLITE_OK {
                    logDbErr("sqlite3_bind_text(insertEntryStmt) Double Value")
                    return
                }
            } else if field_type == "INTEGER"  {
                if sqlite3_bind_int(self.insertEntryStmt, i, Common.getInt32Value(value: value ?? 0)) != SQLITE_OK {
                    logDbErr("sqlite3_bind_text(insertEntryStmt) Int Value")
                    return
                }
            }
        }
        if is_update {
            
            
            if sqlite3_bind_text(self.insertEntryStmt, i+1, (other_field_value as NSString).utf8String, -1, nil) != SQLITE_OK {
                logDbErr("sqlite3_bind_text(insertEntryStmt) where in update")
            }
        }
        
        let r = sqlite3_step(self.insertEntryStmt)
        
        if r != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting foo: \(errmsg)")
            
            logDbErr("sqlite3_step(updateEntryStmt)")
            return
        }
        return
        
    }
    
    func bulkInsert(rowObjects: [Any], table_name:String)  {
        
        guard let dict = rowObjects as? [[String: Any]] else {
            print("conversion failed")
            return
        }
        
        let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
        var compiledStatement: OpaquePointer?
        
        sqlite3_exec(db, "BEGIN IMMEDIATE TRANSACTION", nil, nil, nil)

        let field_data = self.getSaveFields(table_name: table_name, data: dict.first!, update_field: "")
        //        is_update TODO
        let field_types:[String:String] = field_data["field_types"] as! [String:String]
        let tbl_fields:[Int32:String] = field_data["tbl_fields"] as! [Int32:String]
        let is_update = field_data["is_update"] as! Bool
        
        let update_field = ""
        
        guard self.prepareInsertEntryStmt(tbl_fields: tbl_fields, table_name: table_name) == SQLITE_OK
            else { return }
        
        //Bind or variables and execute each statement
        for row in dict
        {
            defer {
                // reset the prepared statement on exit.
                sqlite3_reset(self.insertEntryStmt)
            }
            var i:Int32 = 0
            var other_field_value:String = ""
            
            let fields = tbl_fields.sorted(by: { $0.key < $1.key})
            for (_, field) in fields {
                
                var value = row[field]
                if is_update == false && field == "id" {
                    value =  UUID().uuidString
                }
                var field_type = "TEXT"
                if field_types[field] != nil {
                    field_type = field_types[field]!
                }
                
                
                if field == update_field {
                    other_field_value = value as! String
                    continue
                }
                i = i + 1
                
                if field_type == "TEXT" {
                    
                    if sqlite3_bind_text(self.insertEntryStmt, i, (value as! NSString).utf8String, -1, nil) != SQLITE_OK {
                        logDbErr("sqlite3_bind_text(insertEntryStmt) String values")
                        return
                    }
                } else if  field_type == "FLOAT"  {
                    
                    if sqlite3_bind_double(self.insertEntryStmt, i, Common.getDoubleValue(value: value as Any)) != SQLITE_OK {
                        logDbErr("sqlite3_bind_text(insertEntryStmt) Double Value")
                        return
                    }
                } else if field_type == "INTEGER"  {
                    if sqlite3_bind_int(self.insertEntryStmt, i, Common.getInt32Value(value: value as Any)) != SQLITE_OK {
                        logDbErr("sqlite3_bind_text(insertEntryStmt) Int Value")
                        return
                    }
                }
            }
            if is_update {
                if sqlite3_bind_text(self.insertEntryStmt, i+1, (other_field_value as NSString).utf8String, -1, nil) != SQLITE_OK {
                    logDbErr("sqlite3_bind_text(insertEntryStmt) where in update")
                }
            }
            
            let r = sqlite3_step(self.insertEntryStmt)
            if r != SQLITE_DONE {
                logDbErr("sqlite3_step(insertEntryStmt) \(r)")
                if sqlite3_close_v2(db) != SQLITE_OK { print("error closing the database") }
                return
            }
        }
        
        if (sqlite3_finalize(compiledStatement) != SQLITE_OK){
            NSLog("%s",sqlite3_errmsg(db));
        }//Finally, let's commit our transaction
        
        if (sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil) != SQLITE_OK) {
            NSLog("%s",sqlite3_errmsg(db));
        }
        print("Transaction commited")
        //Close our DB
        if sqlite3_close_v2(db) != SQLITE_OK {
            print("error closing the database")
        }
        return
    }
    
    
    
    func getCreateTableSql(column_fields:[Int32:String], table_name:String, column_type:[String:String]) -> String {
        var sql:String = ""
        sql = "CREATE TABLE IF NOT EXISTS " + table_name + " ("
        let fields = column_fields.sorted(by: { $0.key < $1.key})
        var fields_with_type = [String]()
        for (_, field) in fields {
            var field_str:String = ""
            if field == "id" {
                field_str =  field + " TEXT UNIQUE PRIMARY KEY "
            } else {
                field_str =  field + " " + (column_type[field] ?? "TEXT") + " "
            }
            fields_with_type.append(field_str)
        }
        sql += fields_with_type.joined(separator: ", ")
        sql += ")"
        
        return sql
    }
    
    func getResultByQuery(sql:String) -> [Any] {
        var result = [Any]()
        readEntryStmt = nil
        print("getResultByQuery called query = \(sql)")
        guard readEntryStmt == nil else { return result }
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        
        defer {
            sqlite3_reset(self.readEntryStmt)
        }
        
        while sqlite3_step(readEntryStmt) == SQLITE_ROW {
            var row = [String:Any]()
            for n in 0...sqlite3_column_count(readEntryStmt)-1 {
                var name:String = ""
                var value:String = ""
                if let cName = sqlite3_column_name(readEntryStmt,n) {
                    name = String(cString: cName)
                }
                
                if let cString = sqlite3_column_text(readEntryStmt,n) {
                    value = String(cString: cString)
                }
                
                row[name] = value
            }
            result.append(row)
        }
        return result
    }
    func logDbErr(_ msg: String) {
        let errmsg = String(cString: sqlite3_errmsg(db)!)
        os_log("ERROR %s : %s", log: oslog, type: .error, msg, errmsg)
    }
    
    
    
    func getTableColumns(sql:String) -> [String] {
        var result = [String]()
        readEntryStmt = nil
        
        guard readEntryStmt == nil else { return result }
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        
        defer {
            sqlite3_reset(self.readEntryStmt)
        }
        
        for n in 0...sqlite3_column_count(readEntryStmt)-1 {
            var name:String = ""
            if let cName = sqlite3_column_name(readEntryStmt,n) {
                name = String(cString: cName)
            }
            result.append(name)
        }
        
        return result
    }
    
    func executeQuery(sql:String)  throws {
        let ret =  sqlite3_exec(db, sql, nil, nil, nil)
        if (ret != SQLITE_OK) { // corrupt database.
            logDbErr("Error dropping db table - test")
            throw SqliteError(message: "unable to execute SQL")
        }
    }
    
    
    
    
    func prepareGetSchemaStmt() -> Int32 {
        guard readEntryStmt == nil else { return SQLITE_OK }
        
        let sql = "SELECT name FROM   sqlite_master WHERE  type ='table' AND name NOT LIKE 'sqlite_%'"
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &readEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare readEntryStmt")
        }
        return r
    }
    
    func getTableVars(table_name:String) -> [String:Any] {

        var result = [String:Any]()
        if table_name == "my_venue" {
            result.updateValue(DBSchema.MyVenueColumns, forKey: "fields")
            result.updateValue(DBSchema.MyVenueColumnsType, forKey: "field_type")
        } else if table_name == "user_profile" {
            result.updateValue(DBSchema.UserProfileColumns, forKey: "fields")
            result.updateValue(DBSchema.UserProfileColumnsType, forKey: "field_type")
        }

        return result
    }
    
    
    
    func prepareUpdateStmt(tbl_fields:[Int32:String],  where_field:String, table_name:String) -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        var sql = "UPDATE " + table_name + " SET "
        
        let fields = tbl_fields.sorted(by: { $0.key < $1.key})
        var fields_with_type = [String]()
        for (_, field) in fields {
            if field != where_field {
                let field_str = field + " = ? "
                fields_with_type.append(field_str)
            }
        }
        
        sql += fields_with_type.joined(separator: ", ")
        sql += " WHERE " + where_field + " = ? "
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
    
    
    
    func prepareDeleteRowStmt(table_name:String, field_name:String) -> Int32 {
        guard deleteEntryStmt == nil else { return SQLITE_OK }
        var sql = "DELETE FROM " + table_name
        
        sql += " WHERE " + field_name + " = ? "
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &deleteEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare deleteEntryStmt")
        }
        return r
    }
    
    
    
    // INSERT/CREATE operation prepared statement
    func prepareInsertEntryStmt(tbl_fields:[Int32:String], table_name:String) -> Int32 {
        guard insertEntryStmt == nil else { return SQLITE_OK }
        var sql = "INSERT INTO " + table_name + " ("
        let fields = tbl_fields.sorted(by: { $0.key < $1.key})
        var fields_with_type = [String]()
        var placeholder_arr = [String]()
        for (_, field) in fields {
            fields_with_type.append(field)
            placeholder_arr.append("?")
        }
        sql += fields_with_type.joined(separator: ", ")
        sql += ") VALUES ("
        sql += placeholder_arr.joined(separator: ", ")
        sql += ")"
        print(sql)
        //preparing the query
        let r = sqlite3_prepare(db, sql, -1, &insertEntryStmt, nil)
        if  r != SQLITE_OK {
            logDbErr("sqlite3_prepare insertEntryStmt")
        }
        return r
    }
}

// Indicates an exception during a SQLite Operation.
class SqliteError : Error {
    var message = ""
    var error = SQLITE_ERROR
    init(message: String = "") {
        self.message = message
    }
    init(error: Int32) {
        self.error = error
    }
}


extension Dictionary where Value: Equatable {
    /// Returns all keys mapped to the specified value.
    /// ```
    /// let dict = ["A": 1, "B": 2, "C": 3]
    /// let keys = dict.keysForValue(2)
    /// assert(keys == ["B"])
    /// assert(dict["B"] == 2)
    /// ```
    func keysForValue(value: Value) -> [Key] {
        return compactMap { (key: Key, val: Value) -> Key? in
            value == val ? key : nil
        }
    }
}


