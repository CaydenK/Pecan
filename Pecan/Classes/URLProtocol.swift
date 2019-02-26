//
//  URLProtocol.swift
//  Pods
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation
import WebKit


class WebURLProtocol: URLProtocol {
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
