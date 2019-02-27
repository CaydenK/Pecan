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
        
        let _webview = Pecan.WebView(frame: self.view.bounds, configuration: webConfiguration)
        _webview.uiDelegate = self
        return _webview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.webview)
        let url =  Bundle.main.url(forResource: "test", withExtension: "html")
//        self.webview.load(URLRequest(url: URL(string: "https://www.baidu.com")!))
        self.webview.load(URLRequest(url: url!))

        print(self.webview.uiDelegate as Any)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

