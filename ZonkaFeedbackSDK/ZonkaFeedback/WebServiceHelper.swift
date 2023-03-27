import Foundation
import Network
public class WebServiceHelper
{
        public func callPost(url:URL, params:[String:Any], finish: @escaping ((message:String, data:Data?)) -> Void)
        {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
               guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            else {
                   return
               }
            request.httpBody = httpBody
            var result:(message:String, data:Data?) = (message: "Fail", data: nil)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in

                if(error != nil)
                {
                    result.message = "Fail Error not null : \(error.debugDescription)"
                }
                else
                {
                    result.message = "Success"
                    result.data = data
                }

                finish(result)
            }
            task.resume()
        }
    public func callGet(url:URL, finish: @escaping ((message:String, data:Data?)) -> Void)
    {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        var result:(message:String, data:Data?) = (message: "Fail", data: nil)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in

            if(error != nil)
            {
                result.message = "Fail Error not null : \(error.debugDescription)"
            }
            else
            {
                result.message = "Success"
                result.data = data
            }

            finish(result)
        }
        task.resume()
    }
}


