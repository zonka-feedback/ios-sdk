import UIKit
import Network

class ValidateToken: NSObject
{
   var isInternetActive = Bool()
   private let webServiceHelper = WebServiceHelper()
    
   public func validateToken(token: NSString)
    {
        self.monitorNetwork()
        let backgroundQueue = DispatchQueue.global(qos: .background)
        backgroundQueue.async {
            
                if self.isInternetActive
                { 
                    self.validateTokenOnWeb(token: token)
                }
        }
        
    }
    func validateTokenOnWeb(token:NSString)
    {
        var urlString = Constants.baseUrlUS + "/api/v1/distribution/validateCode/returnResponse/"+(token as String)
        if (UserDefaults.standard.value(forKey: "zfRegion") != nil)
        {
            let zfRegion = UserDefaults.standard.value(forKey: "zfRegion") as! String
            if zfRegion == "EU"
            {
                urlString =  Constants.baseUrlEU + "/api/v1/distribution/validateCode/returnResponse/"+(token as String)
            }
        }
        if UserDefaults.standard.value(forKey:"contact_email") != nil
        {
            let email = UserDefaults.standard.value(forKey: "contact_email") as! String
            urlString =  String(format: "%@?contact_email=%@",urlString,email)
            
        }
        let url = URL(string:urlString)! // note, https, not http
        webServiceHelper.callGet(url: url) { (message: String, data: Data?) in
            do
            {
                if let jsonData = data
                {
                    let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
                    if dict.value(forKey: "success") as!Bool == true
                    {
                        let data = dict.value(forKey: "data") as! NSDictionary
                        if data.value(forKey: "distributionInfo") is NSDictionary
                        {
                            let companyInfo = data.value(forKey: "distributionInfo") as! NSDictionary
                            UserDefaults.standard.set(companyInfo.value(forKey: "isWidgetActive"), forKey: "ValidationStatus")
                            if companyInfo.value(forKey: "_id") is NSString
                            {
                                UserDefaults.standard.set(companyInfo.value(forKey: "companyId"), forKey: "companyId")
                            }
                            
                        }
                    }
                    else
                        
                    {
                        UserDefaults.standard.set(false, forKey: "ValidationStatus")
                        print("Error: Token is not valid")
                        
                    }
                  

                }
            }
            catch
            {
            }
        }
    }
    func monitorNetwork()
    {
        let monitor = NWPathMonitor()
       
        monitor.pathUpdateHandler = { path in
        if path.status == .satisfied
        {
            self.isInternetActive = true
        }
        else
        {
            self.isInternetActive = false
        }
          }
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    public enum InterfaceType {

           /// A virtual or otherwise unknown interface type
           case other

           /// A Wi-Fi link
           case wifi

           /// A Cellular link
           case cellular

           /// A Wired Ethernet link
           case wiredEthernet

           /// The Loopback Interface
           case loopback
   }
}


