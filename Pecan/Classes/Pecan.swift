//
//  Pecan.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/25.
//

import Foundation
import WebKit

open class PecanEngine {
    public static var debug : Bool = false
    
    public static func start() {
        UIWebView().loadHTMLString("", baseURL: nil) //start WebThread
        WKWebView().loadHTMLString("", baseURL: nil) //start thread named 'JavaScriptCore bmalloc scavenger'
    }
    
    public static func test2333() {
        
    }
    
}
