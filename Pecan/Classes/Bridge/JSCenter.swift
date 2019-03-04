//
//  JSCenter.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation
import HandyJSON

enum AjaxAction : String, HandyJSONEnum{
    case send = "send"
    case abort = "abort"
}

struct AjaxMessage : HandyJSON {
    var taskName : String?
    var action : AjaxAction?
    var params : Dictionary<String, Any>?
}

var taskDict : [String : URLSessionTask] = [String : URLSessionTask]()

class JSCenter {
    
    static func proxyAjaxRequest(webVew:WebView, ajaxMessage:String) {
        if let message : AjaxMessage = AjaxMessage.deserialize(from: ajaxMessage) {
            if let taskName = message.taskName, let action = message.action {
                //方法分发
                switch action {
                case .send:
                    if let params = message.params {
                        let urlStr : String = params["url"] as! String
                        if let url : URL = URL(string: urlStr, relativeTo: webVew.url) {
                            self.send(taskName: taskName, url: url, params: params, comp: {
                                callbackMethod in
                                DispatchQueue.main.async {
                                    webVew.evaluateJavaScript(callbackMethod, completionHandler: nil)
                                }
                            })
                        }
                    }
                case .abort:
                    self.abort(taskName: taskName)
                default:
                    print("\(action) is temporarily not supported")
                }
            }
        }
        
        
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
    }
    
    static func abort(taskName:String) {
        if let task : URLSessionTask = taskDict[taskName] {
            task.cancel()
        }
    }
    
    static func send(taskName:String, url : URL, params:[String:Any], comp:@escaping (String)->Void) {
        var request : URLRequest = URLRequest(url: url)
        request.httpMethod = params["method"] as? String
        request.allHTTPHeaderFields = params["headers"] as? [String : String]
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366", forHTTPHeaderField: "user-agent")
        if request.httpMethod?.uppercased() == "POST" {
            let  jsonData = try? JSONSerialization.data(withJSONObject: params["data"] ?? "", options: .prettyPrinted)
            request.httpBody = jsonData//?.base64EncodedData()
        }
        
        
        let session : URLSession = URLSession(configuration: URLSessionConfiguration.default)
        let task : URLSessionTask = session.dataTask(with: request) { (data : Data?, aResponse : URLResponse?, error : Error?) in
            if error != nil {
                
            } else {
                let response = aResponse as! HTTPURLResponse
                let statusCode = response.statusCode
                let allHeaders = response.allHeaderFields
                //                    let responseText = String(data: data ?? Data(), encoding: .utf8)
                
                var enc : UInt
                if let contentType = allHeaders["Content-Type"] as? String {
                    if contentType.contains("GB2312") {
                        enc = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0632)).rawValue
                    } else {
                        enc = String.Encoding.utf8.rawValue
                    }
                } else {
                    enc = String.Encoding.utf8.rawValue
                }
                
//                let responseText = String(decoding: data!, as: UTF8.self)
                let responseText = NSString(data: data!, encoding: enc)


                let callbackDict : [String:Any] = [
                    "status":statusCode,
                    "data":responseText ?? "" ,
                    "headers":allHeaders
                ]
                
                let callbackData = try! JSONSerialization.data(withJSONObject: callbackDict, options: .prettyPrinted)
                let callbackParamsString = String(data: callbackData, encoding: .utf8)
                
                
                let callbackMethod = "AjaxBridge.callJS('\(taskName)','stateChange',\(callbackParamsString!));"
//                print(callbackMethod)
                comp(callbackMethod)
            }
            //成功或失败后，task任务已完成，执行释放操作
            taskDict[taskName] = nil
        }
        taskDict[taskName] = task
        task.resume()
    }

    
    static func disposePrompt(prompt:NSString, defaultText:NSString, completionHandler: @escaping (String?) -> Void) {
        print(defaultText.length)
        completionHandler(defaultText as String)
    }
}
