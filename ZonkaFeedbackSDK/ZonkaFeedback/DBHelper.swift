import Foundation
import SQLite3

class DBHelper
{
    init()
    {
       db = openDatabase()
       createTable()
    }
    
    let dbPath: String = "database.sqlite3"
    var db:OpaquePointer?

    func openDatabase() -> OpaquePointer?
    {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
            .appendingPathComponent(dbPath)
        
        // try to open existing database (but don't create); if successful, return immediately
        
        if sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE, nil) == SQLITE_OK {
            print("Database has been opened with path \(fileURL.path)")
            return db
        }
        
        // if you got here, clean up and then try creating database
        
        sqlite3_close(db) // clean up after the above `sqlite3_open` call
        
        guard sqlite3_open_v2(fileURL.path, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil) == SQLITE_OK else {
            print("There is error in creating DB: ")
            sqlite3_close(db) // if creation failed, make sure to again clean up
            db = nil
            return db
        }
        return db
    }
        func createTable()
        {
            let createTableString = "CREATE TABLE IF NOT EXISTS sessionLog(Id TEXT,sessionStart TEXT,sessionEnd TEXT,sessionState INTEGER);"
            var createTableStatement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK
            {
                if sqlite3_step(createTableStatement) == SQLITE_DONE
                {
                   
                }
            else
            {
               
            }
        } else {
          
        }
        sqlite3_finalize(createTableStatement)
    }

    func insert(sessionStart:String,sessionEnd:String , sessionState:Int)-> Bool
    {
        var id = self.randomString(length: 24)
        id = "ios-" + id
        let insertStatementString = "INSERT INTO sessionLog (Id, sessionStart, sessionEnd,sessionState) VALUES (?, ?, ?, ?);"
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1,(id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (sessionStart as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (sessionEnd as NSString).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, Int32(sessionState))

            if sqlite3_step(insertStatement) == SQLITE_DONE {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    func updateSessionState(id:String, sessionState:Int)-> Bool
    {
        let queryStatementString = "UPDATE sessionLog SET sessionState = '\(sessionState)' WHERE id = '\(id)';"
         var queryStatement: OpaquePointer? = nil
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_DONE {
                      return true
                } else {
                       return false
                }
              } else {
                  return false
              }
    }
    func updateSessionTime(sessionEnd:String, sessionState:Int)-> Bool
    {
        let queryStatementString = "UPDATE sessionLog SET sessionEnd = '\(sessionEnd)' WHERE sessionState = '\(sessionState)';"
         var queryStatement: OpaquePointer? = nil
         if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                if sqlite3_step(queryStatement) == SQLITE_DONE {
                    return true
                } else {
                    return false
                }
              } else {
                  return false
              }
    }
    func read() -> [Sessions]
    {
        let queryStatementString = "SELECT * FROM sessionLog;"
        var queryStatement: OpaquePointer? = nil
        var sessions : [Sessions] = []
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK
        {
            while sqlite3_step(queryStatement) == SQLITE_ROW
            {
                let id = String(describing: String(cString: sqlite3_column_text(queryStatement, 0)))
                let sessionStart = String(describing: String(cString: sqlite3_column_text(queryStatement, 1)))
                let sessionEnd = String(describing: String(cString: sqlite3_column_text(queryStatement, 2)))
                let sessionState = sqlite3_column_int(queryStatement, 3)
                sessions.append(Sessions(id: id, sessionStarted: sessionStart,sessionEnd: sessionEnd ,sessionState: Int(sessionState)))
               
            }
        } else {
            
        }
        sqlite3_finalize(queryStatement)
        return sessions
    }
    func DeleteRowDatabase(id:String) -> Bool
    {
        let deleteStatementStirng = "DELETE FROM sessionLog WHERE id = ?;"

           var deleteStatement: OpaquePointer? = nil
           if sqlite3_prepare_v2(db, deleteStatementStirng, -1, &deleteStatement, nil) == SQLITE_OK {

               sqlite3_bind_text(deleteStatement, 1, (id as NSString).utf8String, -1, nil)
               
               if sqlite3_step(deleteStatement) == SQLITE_DONE {
                   return true
               } else {
                   return false
               }
           } else {
               return false
           }

    }
    
    func randomString(length: Int) -> String
    {
        let letters : NSString = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let len = UInt32(letters.length)
        var randomString = ""

        for _ in 0 ..< length
        {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
    
}

