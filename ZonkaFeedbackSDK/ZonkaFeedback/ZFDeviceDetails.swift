import UIKit
import CoreTelephony
import SystemConfiguration

@objcMembers public class ZFDeviceDetails: NSObject
{
    public var zf_sdk_device_name: String?
    public var zf_sdk_os: String?
    public var zf_sdk_os_version: String?
    public var zf_sdk_active_start_time: String?
    public var zf_sdk_class_name: String?
    public var zf_sdk_device_brand: String?
    public var zf_sdk_device_type: String?
    public var zf_sdk_network_type: String?
    public var zf_sdk_device_model: String?
    public var zf_sdk_device_resolution: String?
    public var zf_sdk_device_IMEI: String?
    public var zf_sdk_version: String?
    public var zf_sdk_timezone: String?
    public var zf_sdk_app_version_code: String?
    public var zf_sdk_HiddenDict: NSMutableDictionary?
    
    public func getDeviceDetails()-> String
    {
        var urlString: String?
        zf_sdk_device_name = UIDevice.current.name
        zf_sdk_os = "iOS"
        zf_sdk_os_version = UIDevice.current.systemVersion
        zf_sdk_device_brand = "Apple"
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            zf_sdk_device_type = "Mobile"
        }
        else
        {
            zf_sdk_device_type = "Tablet"
        }
        zf_sdk_network_type = self.getConnectionType()
        zf_sdk_device_model = UIDevice.modelName
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth: String = String(format: "%.01f", screenSize.width)
        let screenHeight:String = String(format: "%.01f", screenSize.height)
        zf_sdk_device_resolution = "\(screenWidth) * \(screenHeight)"
        zf_sdk_device_IMEI = UIDevice.current.identifierForVendor!.uuidString
        zf_sdk_version = Bundle(for: self.classForCoder).infoDictionary?["CFBundleShortVersionString"] as? String
        zf_sdk_app_version_code =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        zf_sdk_timezone = TimeZone.current.identifier
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = Date()
        zf_sdk_active_start_time = dateFormatter.string(from: date)
        urlString =  String(format: "?zf_sdk_device_name=%@&zf_sdk_os=%@&zf_sdk_os_version=%@&zf_sdk_device_type=%@&zf_sdk_network_type=%@&zf_sdk_device_model=%@&zf_sdk_device_resolution=%@&zf_sdk_timezone=%@&zf_sdk_device_IMEI=%@",zf_sdk_device_name! ,zf_sdk_os!,zf_sdk_os_version!,zf_sdk_device_type!,zf_sdk_network_type!,zf_sdk_device_model!,zf_sdk_device_resolution!,zf_sdk_timezone!,zf_sdk_device_IMEI!)
        return urlString!
    }
    public func getIP() -> String
   {
       var addresses = [String]()

           // Get list of all interfaces on the local machine:
           var ifaddr : UnsafeMutablePointer<ifaddrs>?
           guard getifaddrs(&ifaddr) == 0 else { return "" }
           guard let firstAddr = ifaddr else { return "" }

           for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
               let flags = Int32(ptr.pointee.ifa_flags)
               let addr = ptr.pointee.ifa_addr.pointee

               // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
               if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                   if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {

                       // Convert interface address to a human readable string:
                       var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                       if (getnameinfo(ptr.pointee.ifa_addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                                       nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                           let address = String(cString: hostname)
                           addresses.append(address)
                       }
                   }
               }
           }

           freeifaddrs(ifaddr)
       return addresses[2]
   }


    func getConnectionType() -> String {
           guard let reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "www.google.com") else {
               return "NO INTERNET"
           }

           var flags = SCNetworkReachabilityFlags()
           SCNetworkReachabilityGetFlags(reachability, &flags)

           let isReachable = flags.contains(.reachable)
           let isWWAN = flags.contains(.isWWAN)

           if isReachable {
               if isWWAN {
                   let networkInfo = CTTelephonyNetworkInfo()
                   let carrierType = networkInfo.serviceCurrentRadioAccessTechnology

                   guard let carrierTypeName = carrierType?.first?.value else {
                       return "UNKNOWN"
                   }

                   switch carrierTypeName {
                   case CTRadioAccessTechnologyGPRS, CTRadioAccessTechnologyEdge, CTRadioAccessTechnologyCDMA1x:
                       return "2G"
                   case CTRadioAccessTechnologyLTE:
                       return "4G"
                   default:
                       return "3G"
                   }
               } else {
                   return "WIFI"
               }
           } else {
               return "NO INTERNET"
           }
       }
}
public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                       return "iPod touch (5th generation)"
            case "iPod7,1":                                       return "iPod touch (6th generation)"
            case "iPod9,1":                                       return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":           return "iPhone 4"
            case "iPhone4,1":                                     return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                        return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                        return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                        return "iPhone 5s"
            case "iPhone7,2":                                     return "iPhone 6"
            case "iPhone7,1":                                     return "iPhone 6 Plus"
            case "iPhone8,1":                                     return "iPhone 6s"
            case "iPhone8,2":                                     return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                        return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                        return "iPhone 7 Plus"
            case "iPhone10,1", "iPhone10,4":                      return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                      return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                      return "iPhone X"
            case "iPhone11,2":                                    return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                      return "iPhone XS Max"
            case "iPhone11,8":                                    return "iPhone XR"
            case "iPhone12,1":                                    return "iPhone 11"
            case "iPhone12,3":                                    return "iPhone 11 Pro"
            case "iPhone12,5":                                    return "iPhone 11 Pro Max"
            case "iPhone13,1":                                    return "iPhone 12 mini"
            case "iPhone13,2":                                    return "iPhone 12"
            case "iPhone13,3":                                    return "iPhone 12 Pro"
            case "iPhone13,4":                                    return "iPhone 12 Pro Max"
            case "iPhone14,4":                                    return "iPhone 13 mini"
            case "iPhone14,5":                                    return "iPhone 13"
            case "iPhone14,2":                                    return "iPhone 13 Pro"
            case "iPhone14,3":                                    return "iPhone 13 Pro Max"
            case "iPhone8,4":                                     return "iPhone SE"
            case "iPhone12,8":                                    return "iPhone SE (2nd generation)"
            case "iPhone14,6":                                    return "iPhone SE (3rd generation)"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":      return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":                 return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":                 return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                          return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                            return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                          return "iPad (7th generation)"
            case "iPad11,6", "iPad11,7":                          return "iPad (8th generation)"
            case "iPad12,1", "iPad12,2":                          return "iPad (9th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":                 return "iPad Air"
            case "iPad5,3", "iPad5,4":                            return "iPad Air 2"
            case "iPad11,3", "iPad11,4":                          return "iPad Air (3rd generation)"
            case "iPad13,1", "iPad13,2":                          return "iPad Air (4th generation)"
            case "iPad13,16", "iPad13,17":                        return "iPad Air (5th generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":                 return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":                 return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":                 return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                            return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                          return "iPad mini (5th generation)"
            case "iPad14,1", "iPad14,2":                          return "iPad mini (6th generation)"
            case "iPad6,3", "iPad6,4":                            return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                            return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":      return "iPad Pro (11-inch) (1st generation)"
            case "iPad8,9", "iPad8,10":                           return "iPad Pro (11-inch) (2nd generation)"
            case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":  return "iPad Pro (11-inch) (3rd generation)"
            case "iPad6,7", "iPad6,8":                            return "iPad Pro (12.9-inch) (1st generation)"
            case "iPad7,1", "iPad7,2":                            return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":      return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                          return "iPad Pro (12.9-inch) (4th generation)"
            case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":return "iPad Pro (12.9-inch) (5th generation)"
            case "AppleTV5,3":                                    return "Apple TV"
            case "AppleTV6,2":                                    return "Apple TV 4K"
            case "AudioAccessory1,1":                             return "HomePod"
            case "AudioAccessory5,1":                             return "HomePod mini"
            case "i386", "x86_64", "arm64":                       return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                              return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
}

