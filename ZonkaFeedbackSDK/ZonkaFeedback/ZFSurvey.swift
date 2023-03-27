import UIKit

@objcMembers public class ZFSurvey: NSObject
{
    var db:DBHelper = DBHelper()
    var timer = Timer()
    private let webServiceHelper = WebServiceHelper()
    class var swiftSharedInstance: ZFSurvey {
    struct Singleton {
        static let instance = ZFSurvey()
        }
        return Singleton.instance
    }
  
    public class func sharedInstance() -> ZFSurvey
    {
        return ZFSurvey.swiftSharedInstance
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(UIApplication.didEnterBackgroundNotification.rawValue), object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name(UIApplication.didBecomeActiveNotification.rawValue), object: nil)
    }
    public  func initializeSDK(token: NSString,zfRegion: NSString)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ZFSurvey.updateSession), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ZFSurvey.updateSession),name: UIApplication.didEnterBackgroundNotification,
            object: nil)
        UserDefaults.standard.set(zfRegion, forKey: "zfRegion")
        let UTCDate = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentTime = formatter.string(from: UTCDate)
        if (UserDefaults.standard.value(forKey: "cookieId") == nil)
        {
            let id = "ios-" + self.randomString(length: 24)
            UserDefaults.standard.set(id, forKey: "cookieId")
            UserDefaults.standard.set(currentTime, forKey: "firstSeen")
        }
        UserDefaults.standard.set(token, forKey: "AccessCode")
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async
        {
            self.createContactOnServer()
        }
       
        let validObj = ValidateToken()
        validObj.validateToken(token: token)
    }
     public func clear()
     {
         UserDefaults.standard.removeObject(forKey: "contactId")
         UserDefaults.standard.removeObject(forKey: "anonymousVisitorId")
         UserDefaults.standard.removeObject(forKey: "cookieId")
         UserDefaults.standard.removeObject(forKey: "firstSeen")
         UserDefaults.standard.removeObject(forKey: "lastSeen")
         UserDefaults.standard.removeObject(forKey: "contact_email")
         UserDefaults.standard.removeObject(forKey: "contact_uniqueId")
         UserDefaults.standard.removeObject(forKey: "contact_mobile")
         UserDefaults.standard.removeObject(forKey: "contact_name")
         UserDefaults.standard.removeObject(forKey: "userInfo")
         UserDefaults.standard.synchronize()
         
         let UTCDate = Date()
         let formatter = DateFormatter()
         formatter.timeZone = TimeZone(identifier: "UTC")
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         let currentTime = formatter.string(from: UTCDate)
          let id = "ios-" + self.randomString(length: 24)
          UserDefaults.standard.set(id, forKey: "cookieId")
          UserDefaults.standard.set(currentTime, forKey: "firstSeen")
         let backgroundQueue = DispatchQueue.global(qos: .background)
         backgroundQueue.async
         {
             self.createContactOnServer()
         }
     }
    public func createContactOnServer()
    {
        var Url = Constants.baseUrlContactUS
        if (UserDefaults.standard.value(forKey: "zfRegion") != nil)
        {
            let zfRegion = UserDefaults.standard.value(forKey: "zfRegion") as! String
            if zfRegion == "EU"
            {
                Url =  Constants.baseUrlContactEU
            }
        }
        let token = UserDefaults.standard.value(forKey: "AccessCode") as! String
        let firstSeen = UserDefaults.standard.value(forKey: "firstSeen") as! String
        let ipAddress = ZFDeviceDetails().getIP()
        let deviceOS = "iOS"
        var deviceType = ""

        if UIDevice.current.userInterfaceIdiom == .phone
        {
            deviceType = "Mobile"
        }
        else
        {
            deviceType = "Tablet"
        }
        let deviceOSVersion = UIDevice.current.systemVersion
        let deviceModel = UIDevice.modelName
        let deviceBrand = "Apple"
        let deviceName = UIDevice.current.name
        let requestType = "ios"
        let UTCDate = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let lastSeen = formatter.string(from: UTCDate)
        guard let serviceUrl = URL(string: Url) else { return }
        let parameters = NSMutableDictionary()
        parameters.setValue(requestType, forKey: "requestType")
        parameters.setValue(firstSeen, forKey: "firstSeen")
        parameters.setValue(lastSeen, forKey: "lastSeen")
        parameters.setValue(ipAddress, forKey: "ipAddress")
        parameters.setValue(token, forKey: "uniqueRefCode")
        parameters.setValue(deviceName, forKey: "deviceName")
        parameters.setValue(deviceOS, forKey: "deviceOS")
        parameters.setValue(deviceOSVersion, forKey: "deviceOSVersion")
        parameters.setValue(deviceModel, forKey: "deviceModel")
        parameters.setValue(deviceBrand, forKey: "deviceBrand")
        parameters.setValue(deviceType, forKey: "device")
        parameters.setValue("sdktd", forKey: "jobType")
        if (UserDefaults.standard.value(forKey: "anonymousVisitorId") != nil)
        {
            if UserDefaults.standard.value(forKey:"contactId") != nil
            {
                let contactId = UserDefaults.standard.value(forKey: "contactId") as! String
                parameters.setValue(contactId, forKey: "contactId")
            }
            else
            {
                let cookieId = UserDefaults.standard.value(forKey: "cookieId") as! String
                let anonymousVisitorId = UserDefaults.standard.value(forKey: "anonymousVisitorId") as! String
                parameters.setValue(anonymousVisitorId, forKey: "anonymousVisitorId")
                parameters.setValue(cookieId, forKey: "cookieId")
            }
        }
        else
        {
            let cookieId = UserDefaults.standard.value(forKey: "cookieId") as! String
            parameters.setValue(cookieId, forKey: "cookieId")
        }
        if (UserDefaults.standard.value(forKey: "companyId") != nil)
        {
            let companyId = UserDefaults.standard.value(forKey: "companyId") as! String
            parameters.setValue(companyId, forKey: "companyId")
        }
        if (UserDefaults.standard.object(forKey: "userInfo") != nil)
        {
            let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! NSDictionary
            if userInfo.count > 0
            {
                for(key, value) in userInfo
                {
                    parameters.setValue(value, forKey: key as! String)
                }
            }
        }
        
        self.webServiceHelper.callPost(url: serviceUrl, params: parameters as! [String : Any], finish: { (message: String, data: Data?) in
            do
            {
                if let jsonData = data
                {
                    let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                    if dict.value(forKey: "success") as!Bool == true
                    {
                        let data = dict.value(forKey: "data") as! NSDictionary
                        
                        if data.value(forKey: "contactInfo") is NSDictionary
                        {
                            let contactInfo = data.value(forKey: "contactInfo") as! NSDictionary
                            UserDefaults.standard.set(contactInfo.value(forKey: "_id"), forKey: "contactId")
                        }
                        else
                        {
                            if data.value(forKey: "evd") is NSDictionary
                            {
                                let evdInfo = data.value(forKey: "evd") as! NSDictionary
                                UserDefaults.standard.set(evdInfo.value(forKey: "_id"), forKey: "anonymousVisitorId")
                            }
                        }
                        
                    }

                }
            }
            catch
            {
            }
        })
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
    
    func updateDataBase()
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = formatter.string(from: date)
        
        let state = UIApplication.shared.applicationState
        if state == .background
        {
            let backgroundQueue = DispatchQueue.global(qos: .background)
            backgroundQueue.async
            { [self] in
                self.createContactOnServer()
               
            }
            var bgTask = UIBackgroundTaskIdentifier(rawValue: 1)
                bgTask = UIApplication.shared.beginBackgroundTask(expirationHandler:
                                            {
                    UIApplication.shared.endBackgroundTask(bgTask)
                })
            self.timer = Timer.scheduledTimer(timeInterval: 20.0, target: self, selector: #selector(self.checkForSessionUpdate), userInfo: nil, repeats: false)
            RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
         
        }
        else if state == .active
        {
            timer .invalidate()
            
            let backgroundQueue = DispatchQueue.global(qos: .background)
            backgroundQueue.async
            {
                
                let sessions = self.db.read()
                if sessions.count == 0
                {
                    _ =   self.db.insert(sessionStart: currentDate, sessionEnd: "", sessionState:0)
                }
                else
                {
                    for p in sessions
                    {
                        if p.sessionState == 0
                        {
                            let endDateString = p.sessionEnd
                            if endDateString != ""
                            {
                                let dateFormatter = DateFormatter()
                                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                
                                _ =   self.db.updateSessionTime(sessionEnd: currentDate, sessionState: 0)
                            }
                        }
                        else
                        {
                            _ =   self.db.insert(sessionStart: currentDate, sessionEnd: "", sessionState:0)
                        }
                     }
                    
                }//
                let backgroundQueue = DispatchQueue.global(qos: .background)
                backgroundQueue.async
                { [self] in
                    self.createContactOnServer()
                   
                }
            }
           
        }
        
    }
    
    func checkForSessionUpdate()
    {
        let sessions = self.db.read()
        for p in sessions
        {
            if p.sessionState == 0
            {
                let date = Date()
                let formatter = DateFormatter()
                formatter.timeZone = TimeZone(identifier: "UTC")
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let currentDate = formatter.string(from: date)
            
                _ = self.db.updateSessionTime(sessionEnd: currentDate, sessionState: 0)
                _ = self.db.updateSessionState(id: p.id, sessionState: 1)
                self.sendSessionsToServer()
               
            }
        }
       
    }
    @objc public func updateSession()
    {
        self.updateDataBase()
    }
    public func sendSessionsToServer()
    {
        let ipAddress = ZFDeviceDetails().getIP()
        let sessions = self.db.read()
        var sessionLogArray: [NSMutableDictionary] = []
        let cookieId = UserDefaults.standard.value(forKey: "cookieId") as! String
        if sessions.count > 0
        {
            for p in sessions
            {
                if p.sessionState == 1
                {
                    let sessionDict = NSMutableDictionary()
                    sessionDict.setValue(cookieId, forKey: "cookieId")
                    if (UserDefaults.standard.value(forKey: "anonymousVisitorId") != nil)
                    {
                        let anonymousVisitorId = UserDefaults.standard.value(forKey: "anonymousVisitorId") as! String
                        sessionDict.setValue(anonymousVisitorId, forKey: "anonymousVisitorId")
                    }
                    if (UserDefaults.standard.value(forKey: "contactId") != nil)
                    {
                        let contactId = UserDefaults.standard.value(forKey: "contactId") as! String
                        sessionDict.setValue(contactId, forKey: "contactId")
                    }
                    if (UserDefaults.standard.value(forKey: "companyId") != nil)
                    {
                        let companyId = UserDefaults.standard.value(forKey: "companyId") as! String
                        sessionDict.setValue(companyId, forKey: "companyId")
                    }
                    sessionDict.setValue(ipAddress, forKey: "ipAddress")
                    sessionDict.setValue(p.id, forKey: "uniqueSessId")
                    sessionDict.setValue(p.sessionStarted, forKey: "sessionStartedAt")
                    sessionDict.setValue(p.sessionEnd, forKey: "sessionClosedAt")
                    sessionLogArray.append(sessionDict)
                }
            }
        }
        if sessionLogArray.count > 0
        {
            var Url = Constants.baseUrlUS+"/api/v1/contacts/sessionsUpdate/"
            if (UserDefaults.standard.value(forKey: "zfRegion") != nil)
            {
                let zfRegion = UserDefaults.standard.value(forKey: "zfRegion") as! String
                if zfRegion == "EU"
                {
                    Url =  Constants.baseUrlEU+"/api/v1/contacts/sessionsUpdate/"
                }
            }
            let token = UserDefaults.standard.value(forKey: "AccessCode") as! String
            Url = Url + token
            guard let serviceUrl = URL(string: Url) else { return }
        
            let parameters: [String: Any]
                parameters  = [
                    "deviceType" : "ios",
                    "sessionLogs" : sessionLogArray
                ]
            self.webServiceHelper.callPost(url: serviceUrl, params: parameters, finish: { (message: String, data: Data?) in
                do
                {
                    if let jsonData = data
                    {
                        let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                        if dict.value(forKey: "success") as!Bool == true
                        {
                            let data = dict.value(forKey: "data") as! NSDictionary
                            let savedUniqueSessions = data.value(forKey: "savedUniqueSessions") as! NSArray
                            if savedUniqueSessions.count > 0
                            {
                                for uniqueId in savedUniqueSessions
                                {
                                    _ =    self.db.DeleteRowDatabase(id: uniqueId as! String)
                                }
                            }
                            
                        }
                    }
                }
                catch
                {
                    
                }
            })
        }
            
        }
    public  func userInfo(dict: NSDictionary)
    {
        if dict.count > 0
        {
            UserDefaults.standard.set(dict, forKey: "userInfo")
            for(key, value) in dict
            {
                UserDefaults.standard.set(value, forKey: key as! String)
            }
        }
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async
        {
            self.createContactOnServer()
        }
    }
}
extension Collection {
    func json() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}





