import UIKit
import WebKit
import QuartzCore

@objcMembers @IBDesignable public class ZFSurveyView: UIView, WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate
{
    
  // MARK: Properties
  private var domainUrl = "http://us1.zonka.co/"
    //private var domainUrl = "http://s.zf1.zonkaplatform.com/"
  private var webView: WKWebView = WKWebView()
  private var baseView: UIView = UIView()
  private var closeButton: UIButton = UIButton()
  private let surveyResponseHandler = WKUserContentController()
  private let loader: UIActivityIndicatorView = UIActivityIndicatorView()
  public var params: [String: String] = [:]
  public var surveyType: String?
  public var deviceDetailsQueryString: String?
  public var attributesQueryString: String?
  public var userInfoQueryString: String?
  private let webServiceHelper = WebServiceHelper()
  @IBInspectable public var token: String?
  
  // MARK: Initialization
  override init(frame: CGRect)
{
    super.init(frame: frame)
    let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
    self.backgroundColor = bgColor
    if (UserDefaults.standard.value(forKey: "zfRegion") != nil)
    {
        let zfRegion = UserDefaults.standard.value(forKey: "zfRegion") as! String
        if zfRegion == "EU"
        {
            domainUrl = "http://e.zonka.co/"
        }
    }
    addSurveyView()
    
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  // MARK: Private methods
  private func addSurveyView()
  {
     self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      self.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    let config = WKWebViewConfiguration()
      let source: String = "var meta = document.createElement('meta');" +
          "meta.name = 'viewport';" +
          "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
          "var head = document.getElementsByTagName('head')[0];" +
          "head.appendChild(meta);"
      let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    surveyResponseHandler.add(self, name: "mobileApp")
    surveyResponseHandler.addUserScript(script)
      if #available(iOS 13.0, *) {
          let preferences = WKWebpagePreferences()
          config.defaultWebpagePreferences = preferences
      } else
      {
         
      }
    
    config.userContentController = surveyResponseHandler
    webView = WKWebView(frame: bounds, configuration: config)
    webView.scrollView.bounces = false
    webView.scrollView.alwaysBounceVertical = false;
    webView.scrollView.alwaysBounceHorizontal = false;
    
    webView.navigationDelegate = self
    webView.uiDelegate = self
      webView.scrollView.delegate = self
    webView.backgroundColor = .white
    addSubview(webView)
      webView.reload()
      
    closeButton = UIButton()
      if let image = UIImage(named: "close", in: Bundle(for: ZFSurveyViewController.self), compatibleWith: nil)
      {
          closeButton.setImage(image, for: .normal)
      }
    closeButton.layer.cornerRadius = 25
    closeButton.layer.masksToBounds = false
    closeButton.backgroundColor = UIColor.white
    closeButton.addTarget(self, action: #selector(closeSDKAction), for: .touchUpInside)
    self.addSubview(closeButton)
    self.addSubview(loader)
    webView.navigationDelegate = self
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.centerXAnchor.constraint(equalTo: webView.centerXAnchor).isActive = true
    loader.centerYAnchor.constraint(equalTo: webView.centerYAnchor).isActive = true
    loader.hidesWhenStopped = true
    webView.bringSubviewToFront(loader)
      self.setLayout(type: "Embedded")
  }
  private func setLayout(type: String? = nil)
  {
      switch type
      {
      case "Full":
          webView.frame=bounds
      case "Embedded":
          webView.frame = CGRect(x:0, y: 0, width:320, height:270)
      case "Dialog":
          webView.frame = CGRect(x:0, y: 0, width:320, height:480)
      default:
          webView.frame=bounds
      }
      webView.center = self.center
      webView.layer.cornerRadius = 8.0
      webView.layer.shadowColor = UIColor.lightGray.cgColor
      webView.layer.masksToBounds = false
      webView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
      webView.layer.shadowRadius = 8.0
      webView.layer.shadowOpacity = 1.0
      let shadowPath = UIBezierPath(roundedRect: webView.bounds, cornerRadius: webView.layer.cornerRadius)
      webView.layer.shadowPath = shadowPath.cgPath
      webView.layer.masksToBounds = true
      webView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin,.flexibleLeftMargin,.flexibleRightMargin]
      let model = UIDevice.current.model as NSString
      
      if model == "iPhone Simulator" || model == "iPhone"
      {

          closeButton.frame = CGRect(x:webView.center.x+110, y:webView.frame.origin.y-10, width:27, height:27)

      }
      else
      {
          closeButton.frame = CGRect(x:webView.bounds.origin.x+507, y:webView.frame.origin.y-10, width:27, height:27)
      }
     
      closeButton.translatesAutoresizingMaskIntoConstraints = false
         
      let widthContraints =  NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 27)
         
         let heightContraints = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 27)
      
         let xContraints = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: webView, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -15)
        let yContraints = NSLayoutConstraint(item: closeButton, attribute: NSLayoutConstraint.Attribute.topMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: webView, attribute: NSLayoutConstraint.Attribute.topMargin, multiplier: 1, constant: -10)
         
         NSLayoutConstraint.activate([widthContraints,heightContraints,xContraints,yContraints])
      
   }
    @objc func closeSDKAction(button: UIButton)
    {
        webView.reload()
        webView.removeFromSuperview()
        self.superview?.removeFromSuperview()
     }
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
  {
     loader.stopAnimating()
  }
  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error)
    {
    loader.stopAnimating()
  }
  public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage)
 {
    let response = message.body as! NSDictionary
     if response.value(forKey: "event") as! String == "zf-embed-submit-close"
     {
         webView.reload()
         webView.removeFromSuperview()
         self.superview?.removeFromSuperview()
     }
     if response.value(forKey: "event") as! String == "zf-embed-expand-widget"
     {
         if UIDevice.current.userInterfaceIdiom == .phone
         {
             let size = UIScreen.main.bounds.size
             if size.width < size.height
             {
                 surveyType = "Dialog"
                 self.setLayout(type: "Dialog")
             }
         }
         else
         {
             surveyType = "Dialog"
             self.setLayout(type: "Dialog")
         }
        
     }
  }

  // MARK: Public method
public func loadSurvey(token: String? = nil)
{
    loader.startAnimating()
    self.token = token != nil ? token! : self.token
    var urlString = domainUrl + token!
    if deviceDetailsQueryString != nil
    {
        urlString = urlString + deviceDetailsQueryString!
    }
    if attributesQueryString != nil
    {
        urlString = urlString + attributesQueryString!
    }
    if userInfoQueryString != nil
    {
        urlString = urlString + userInfoQueryString!
    }
    if (UserDefaults.standard.value(forKey: "contactId") != nil)
    {
        let contactId = UserDefaults.standard.value(forKey: "contactId") as! String
        urlString =  String(format: "%@&contactId=%@",urlString,contactId)
    }
    else if (UserDefaults.standard.value(forKey: "anonymousVisitorId") is NSDictionary)
    {
        let anonymousVisitorId = UserDefaults.standard.value(forKey: "anonymousVisitorId") as! String
        urlString =  String(format: "%@&externalVisitorId=%@",urlString,anonymousVisitorId)
    }
    if surveyType == "Embedded"
    {
        if deviceDetailsQueryString != nil
        {
            urlString = urlString + "&zf_embed=1&zf_embedwidgetvariant=micro&zf_embedstrictui=micro&zf_sendexternalappevent=1"
        }
        else
        {
            urlString = urlString + "?zf_embed=1&zf_embedwidgetvariant=micro&zf_embedstrictui=micro&zf_sendexternalappevent=1"
        }
    }
    else
    {
        urlString = urlString + "&zf_sendexternalappevent=1"
    }

    urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
    if self.token != nil
    {
        let  url =  URL(string: urlString)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    else {
          print("Error: Domain or token is nil")
    }
    if UserDefaults.standard.bool(forKey: "ValidationStatus") == false
    {
        self.superview?.removeFromSuperview()
    }
  }
}
extension ZFSurveyView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
         scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}





