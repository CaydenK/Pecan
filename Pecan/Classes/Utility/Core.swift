//
//  Core.swift
//  Pods
//
//  Created by CaydenK on 2019/2/26.
//

import Foundation

public struct PecanExtension<Extend> {
    public let extend: Extend
    
    public init(_ extend: Extend) {
        self.extend = extend
    }
}

public protocol PecanCompatible {
    associatedtype CompatibleType
    
    var pecan: PecanExtension<CompatibleType> { get set }
    
    static var pecan: PecanExtension<CompatibleType>.Type { get set }
}

public extension PecanCompatible {
    public var pecan: PecanExtension<Self> {
        get {
            return PecanExtension(self)
        }
        set {}
    }
    
    public static var pecan: PecanExtension<Self>.Type {
        get {
            return PecanExtension<Self>.self
        }
        set {}
    }
}

extension NSObject: PecanCompatible {}

