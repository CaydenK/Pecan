//
//  Cache.swift
//  Pecan
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation
import YYCache

class CacheCenter {
//    static func <#name#>(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}

fileprivate class CacheSingleton {
    let disk : YYDiskCache?
    let memory : YYMemoryCache
    
    static let shared = CacheSingleton()
    private init(){
        let docPath = NSHomeDirectory() + "/Documents/PecanCache"
        self.disk = YYDiskCache(path: docPath)
        self.memory = YYMemoryCache()
        self.memory.name = "PecanCache"
        self.memory.didReceiveMemoryWarningBlock = { (cache:YYMemoryCache?) in
            cache?.removeAllObjects()
        }
    }
}

