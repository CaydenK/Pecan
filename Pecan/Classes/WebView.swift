//
//  WebView.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/25.
//

import WebKit

open class WebView: WKWebView {
    private var _uiDelegate : WebViewDelegate = WebViewDelegate()
    
    
    

    
    
    
    
    
    //MARK: initialize override
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        super.uiDelegate = self._uiDelegate
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)!
        super.uiDelegate = self.uiDelegate
    }
    
    //MARK: uiDelegate override
    weak open override var uiDelegate: WKUIDelegate? {
        get { return _uiDelegate.realUIDelegate }
        set {
            super.uiDelegate = _uiDelegate
            _uiDelegate.realUIDelegate = newValue
        }
    }
}

class WebViewDelegate : NSObject, WKUIDelegate {
    internal var realUIDelegate : WKUIDelegate?
    
    //MARK: Special WKUIDelegate
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        //24F20539 为 ferrariBridge 字符串进行adler32算法运算后获得，降低prompt正常用法和bridge的碰撞概率
        if prompt.hasPrefix("ferrariBridge_24F20539") {
            JSCenter.disposePrompt(prompt: prompt as NSString, defaultText: defaultText! as NSString, completionHandler: completionHandler)
        } else if self.realUIDelegate != nil && self.realUIDelegate!.responds(to: #function) {
            self.realUIDelegate?.webView!(webView, runJavaScriptTextInputPanelWithPrompt: prompt, defaultText: defaultText, initiatedByFrame: frame, completionHandler: completionHandler)
        } else {
            completionHandler(defaultText)
        }
    }

    //MARK: WKUIDelegate
    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                return self.realUIDelegate!.webView!(webView, createWebViewWith: configuration, for: navigationAction, windowFeatures: windowFeatures)

            }
        }
        return nil
    }

    
    
    @available(iOS 9.0, *)
    public func webViewDidClose(_ webView: WKWebView) {
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                self.realUIDelegate!.webViewDidClose!(webView)
            }
        }
    }

    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                self.realUIDelegate!.webView!(webView, runJavaScriptAlertPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
            }
        }
    }

    @available(iOS 8.0, *)
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                self.realUIDelegate!.webView!(webView, runJavaScriptConfirmPanelWithMessage: message, initiatedByFrame: frame, completionHandler: completionHandler)
            }
        }
    }

    @available(iOS 10.0, *)
    public func webView(_ webView: WKWebView, shouldPreviewElement elementInfo: WKPreviewElementInfo) -> Bool {
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                return self.realUIDelegate!.webView!(webView, shouldPreviewElement: elementInfo)
            }
        }
        return false
    }

    @available(iOS 10.0, *)
    public func webView(_ webView: WKWebView, previewingViewControllerForElement elementInfo: WKPreviewElementInfo, defaultActions previewActions: [WKPreviewActionItem]) -> UIViewController?{
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                return self.realUIDelegate!.webView!(webView, previewingViewControllerForElement: elementInfo, defaultActions: previewActions)
            }
        }
        return nil
    }

    @available(iOS 10.0, *)
    public func webView(_ webView: WKWebView, commitPreviewingViewController previewingViewController: UIViewController){
        if self.realUIDelegate != nil {
            if self.realUIDelegate!.responds(to: #function) {
                self.realUIDelegate!.webView!(webView, commitPreviewingViewController:previewingViewController)
            }
        }

    }

    
}
