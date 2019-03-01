//
//  JSCenter.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation
import HandyJSON

protocol Dictable {}
extension Dictionary: Dictable {}

typealias Dict = Dictionary<String, Any>

struct AjaxMessage : HandyJSON{
    var callbackID : String?
    var method : String?
    var url : String?
    var headers: Dict?
    var data : Dict?
}


class JSCenter {
    

    
//    static func callbackJS(callbackID:String, callbackParams : Any) {
//
//
//        [webView evaluateJavaScript:compJS completionHandler:NULL];
//
//    }
    
    static func proxyAjaxRequest(webVew:WebView, ajaxMessage:String) {
        /* ajaxMessage demo value
        {
            "data":{
                "0":"fname=Bill&lname=Gates"
            },
            "method":"POST",
            "url":"http://www.w3school.com.cn/ajax/demo_post2.asp",
            "headers":{
                "Content-type":"application/x-www-form-urlencoded"
            }
        }
        */
        let message : AjaxMessage? = AjaxMessage.deserialize(from: ajaxMessage)
        let url : URL? = URL(string: message?.url ?? "", relativeTo: webVew.url)
        print(url)
        
        if url != nil {
            var request : URLRequest = URLRequest(url: url!)
            request.httpMethod = message?.method
            request.allHTTPHeaderFields = message?.headers as? [String : String]
            let  jsonData = try? JSONSerialization.data(withJSONObject: message?.data, options: .prettyPrinted)
            request.httpBody = jsonData//?.base64EncodedData()
            
            let session : URLSession = URLSession(configuration: URLSessionConfiguration.default)
            let task : URLSessionTask = session.dataTask(with: request) { (data : Data?, aResponse : URLResponse?, error : Error?) in
                let response = aResponse as! HTTPURLResponse
                if error != nil {
                    
                } else {
                    let statusCode = response.statusCode
                    let allHeaders = response.allHeaderFields
//                    let responseText = String(data: data ?? Data(), encoding: .utf8)
                    let responseText = String(decoding: data!, as: UTF8.self)

                    let callbackDict : [String:Any] = [
                        "status":statusCode,
                        "data":responseText ,
                        "headers":allHeaders
                    ]
                    
                    let callbackData = try! JSONSerialization.data(withJSONObject: callbackDict, options: .prettyPrinted)
                    let callbackParamsString = String(data: callbackData, encoding: .utf8)
                    
                    
                    let callbackMethod = "AjaxBridge.callJS('\(message!.callbackID!)','stateChange',\(callbackParamsString!));"
                    print(callbackMethod)

                    
                    DispatchQueue.main.async {
                        webVew.evaluateJavaScript(callbackMethod, completionHandler: { (res : Any?, error:Error?) in
                            print(error)
                        })
                    }

                    
                }
            }
            task.resume()
        }
        
        

        
    }

    static func disposePrompt(prompt:NSString, defaultText:NSString, completionHandler: @escaping (String?) -> Void) {
        

        print(defaultText.length)
        
        completionHandler(defaultText as String)
        
    }

}
