//
//  JSCenter.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation

class JSCenter {

    static func disposePrompt(prompt:NSString, defaultText:NSString, completionHandler: @escaping (String?) -> Void) {
        print(defaultText.length)
        
        completionHandler(defaultText as String)
        
    }

}
