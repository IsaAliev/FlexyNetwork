//
//  PagedRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 26.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

open class PagedRequest<T: Initializable>: HTTPGETRequest {
    open var path: String {
        return ""
    }
    
    open var isPagesDidEnd: Bool = false

    open var parameters: JSON? = [String: Any]()
    open var headerFields: [String : String]?

    public init() {}
    
    open func prepareForNext(with response: T) {

    }

    open func resetToStart() {

    }
}

