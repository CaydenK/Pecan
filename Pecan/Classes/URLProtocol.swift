//
//  URLProtocol.swift
//  Pods
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation
import WebKit

private let kWebURLProtocolKey = "kWebURLProtocolKey"

class WebURLProtocol: URLProtocol,URLSessionDelegate, URLSessionDataDelegate {
    
    private var webTask: URLSessionTask?
    private var session: URLSession?
    private var data: Data?
    private var webThread: Thread?

    
    open override class func canInit(with request: URLRequest) -> Bool{
        
        return (URLProtocol.property(forKey: kWebURLProtocolKey, in: request) == nil);
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest{
        return request;
    }
    
    open override func startLoading(){
        let request = self.request;
        print(request)
        
        guard (self.request.url?.lastPathComponent) != nil else{
            return
        }
        
        URLProtocol.setProperty(true, forKey: kWebURLProtocolKey, in: request as! NSMutableURLRequest)
        let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
        self.webTask = session.dataTask(with: request)
        self.task?.resume()
    }
    
    open override func stopLoading() {
        if self.webTask != nil{
            self.webTask?.cancel()
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.client?.urlProtocolDidFinishLoading(self)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        print(proposedResponse)
        
        completionHandler(proposedResponse);
    }

}



fileprivate class Context {
    let cls : AnyClass
    let register : Selector
    let unregister : Selector
    
    static let browser = Context()
    private init(){
        self.cls = (WKWebView().value(forKey: "browsingContextController") as! NSObject).classForCoder
        self.register = Selector(("registerSchemeForCustomProtocol:"))
        self.unregister = Selector(("unregisterSchemeForCustomProtocol:"))
    }
}

extension PecanExtension where Extend : URLProtocol {
    static func registerScheme(scheme : NSString) {
        let cls : AnyClass = Context.browser.cls
        Thread.detachNewThreadSelector(Context.browser.register, toTarget: cls, with: scheme)
    }
    static func unregisterScheme(scheme : NSString) {
        let cls : AnyClass = Context.browser.cls
        Thread.detachNewThreadSelector(Context.browser.unregister, toTarget: cls, with: scheme)
    }
}

