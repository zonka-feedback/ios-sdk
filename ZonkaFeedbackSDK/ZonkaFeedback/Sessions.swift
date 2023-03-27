import Foundation

class Sessions
{
    var id: String = ""
    var sessionStarted: String = ""
    var sessionEnd: String = ""
    var sessionState: Int = 0
    
    init(id:String,sessionStarted:String, sessionEnd:String, sessionState:Int)
    {
        self.id = id
        self.sessionStarted = sessionStarted
        self.sessionEnd = sessionEnd
        self.sessionState = sessionState
    }
}
