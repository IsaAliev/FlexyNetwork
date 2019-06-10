//
//  PagedRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 26.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

open class PagedRequest<T: Decodable>: HTTPGETRequest {
    open var path: String {
        return ""
    }
    
    open var isPagesDidEnd: Bool = false

    open var parameters: JSON? = [String: Any]()
    open var headerFields: [String : String]?

    open func prepareForNext(with response: T) {

    }

    open func resetToStart() {

    }
}

