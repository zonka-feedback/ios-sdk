import UIKit
import WebKit
import Network

@objcMembers @IBDesignable public class ZFSurveyViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate,WKUIDelegate, UIScrollViewDelegate
{
    public var token: String = ""
    public var sendCustomAttributes = NSMutableDictionary()
    public var sendDeviceDetails: Bool = true
    private var webView: WKWebView = WKWebView()
    var isInternetActive = Bool()
    public override func viewDidLoad()
    {
        super.viewDidLoad()
       
        token = UserDefaults.standard.value(forKey: "AccessCode") as! String
        self.monitorNetwork()
    }
    
    func addSurvey()
    {
        self.view.backgroundColor = UIColor.clear
        var deviceQueryString: String?
        let surveyView = ZFSurveyView()
        
        if sendDeviceDetails == true
        {
            let varObj = ZFDeviceDetails()
            deviceQueryString = varObj.getDeviceDetails()
            surveyView.deviceDetailsQueryString = deviceQueryString
        }
        if sendCustomAttributes.count > 0
        {
            surveyView.attributesQueryString  = sendCustomAttributes.queryString
        }
        let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! NSDictionary
        if userInfo.count > 0
        {
            surveyView.userInfoQueryString = userInfo.queryString
        }
        if token != ""
        {
           surveyView.frame = view.bounds
           surveyView.surveyType = "Embedded"
           surveyView.loadSurvey(token: token)
           self.view.addSubview(surveyView)
           
        }
        else
        {
          print("Error: Domain or token is nil")
        }
    }
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
    {
    }
    func monitorNetwork()
    {
        let monitor = NWPathMonitor()
       
        monitor.pathUpdateHandler = { path in
        if path.status == .satisfied
        {
            let zfObj = ZFSurvey()
            let backgroundQueue = DispatchQueue.global(qos: .background)
            backgroundQueue.async
            {
               zfObj.createContactOnServer()
            }
            
            let validObj = ValidateToken()
            validObj.validateToken(token: self.token as NSString);
            
            DispatchQueue.main.async
            {
                if UserDefaults.standard.bool(forKey: "ValidationStatus") == true
                {
                    self.addSurvey()
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        self.view.removeFromSuperview()

                    }
                }
            }
        }
        else
        {
            DispatchQueue.main.async
            {
                self.view.removeFromSuperview()

            }
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

extension NSDictionary {
    var queryString: String {
        var output: String = "&"
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output.removeLast()
        return output
    }
}


