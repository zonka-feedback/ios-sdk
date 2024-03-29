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
        let className = self.view.superview?.parentViewController?.className
        if sendDeviceDetails == true
        {
            let varObj = ZFDeviceDetails()
            deviceQueryString = varObj.getDeviceDetails()
            deviceQueryString =  String(format: "%@&zf_sdk_screen=%@",deviceQueryString!, className!)
            surveyView.deviceDetailsQueryString = deviceQueryString
        }
        if sendCustomAttributes.count > 0
        {
            surveyView.attributesQueryString  = sendCustomAttributes.queryString
        }
        if (UserDefaults.standard.object(forKey: "userInfo") != nil)
        {
            let userInfo = UserDefaults.standard.object(forKey: "userInfo") as! NSDictionary
            if userInfo.count > 0
            {
                surveyView.userInfoQueryString = userInfo.queryString
            }
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
            var showSurvey = true
            if (UserDefaults.standard.value(forKey: "includeSegment") != nil)
            {
                let includeSegment = UserDefaults.standard.value(forKey: "includeSegment") as! NSDictionary
                let list = includeSegment.value(forKey: "list") as! NSArray
                if list.count > 0
                {
                    showSurvey = false
                    if (UserDefaults.standard.value(forKey: "segmentList") != nil)
                    {
                        let segmentList = UserDefaults.standard.value(forKey: "segmentList") as! NSArray
                        if segmentList.count > 0
                        {
                            for i in 0..<segmentList.count
                            {
                                if list.contains(segmentList[i])
                                {
                                    showSurvey = true
                                    break
                                }
                            }
                
                        }
                    }
                }
            }
            if (UserDefaults.standard.value(forKey: "excludeSegment") != nil)
            {
                let excludeSegment = UserDefaults.standard.value(forKey: "excludeSegment") as! NSDictionary
                let list = excludeSegment.value(forKey: "list") as! NSArray
                if list.count > 0
                {
                    if (UserDefaults.standard.value(forKey: "segmentList") != nil)
                    {
                        let segmentList = UserDefaults.standard.value(forKey: "segmentList") as! NSArray
                        if segmentList.count > 0
                        {
                            for i in 0..<segmentList.count
                            {
                                if list.contains(segmentList[i])
                                {
                                    showSurvey = false
                                    break
                                }
                            }
                        }
                    }
                }
            }
            DispatchQueue.main.async
            {
                if showSurvey && UserDefaults.standard.bool(forKey: "ValidationStatus") == true
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
extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}
extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}
