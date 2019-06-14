//
//  DecodingProcessor.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 20.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol Initializable {
    static func get() -> Initializable
}

open class DecodingProcessor<T: Initializable> {
    public init() {}
    
    open func decodeFrom(_ data: Data) throws -> T { return T.get() as! T }
}
