//
//  ViewController.swift
//  Pecan
//
//  Created by caydenk on 02/25/2019.
//  Copyright (c) 2019 caydenk. All rights reserved.
//

import UIKit
import Pecan
import WebKit
//import TestModule

class ViewController: UIViewController,WKUIDelegate {
    lazy var webview: Pecan.WebView = {
        let hookAjaxPath = Bundle.main.path(forResource: "HookAjax", ofType: "js")
        
        let hookAjax = try? String(contentsOfFile: hookAjaxPath!)
        
        let webConfiguration = WKWebViewConfiguration()
        let ucc = WKUserContentController()
        let us = WKUserScript(source: hookAjax ?? "", injectionTime: .atDocumentStart, forMainFrameOnly: false)
        ucc.addUserScript(us)
        webConfiguration.userContentController = ucc
        
        var bounds : CGRect = self.view.bounds;
        bounds.origin.y += 64;
        bounds.size.height -= 64;
        
        let _webview = Pecan.WebView(frame: bounds, configuration: webConfiguration)
        _webview.uiDelegate = self
        return _webview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.webview)
//        let url =  Bundle.main.url(forResource: "test", withExtension: "html")
//        let urlContent = try? String(contentsOf: url!)
        self.webview.load(URLRequest(url: URL(string: "https://www.taobao.com")!))
//        self.webview.loadHTMLString(urlContent!, baseURL: URL(string: "http://www.w3school.com.cn"))

        print(self.webview.uiDelegate as Any)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

