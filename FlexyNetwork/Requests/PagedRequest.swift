//
//  PagedRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 26.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public class PagedRequest<T: Decodable>: HTTPGETRequest {
    public var path: String {
        return ""
    }
    
    var isPagesDidEnd: Bool = false

    public var parameters: JSON? = [String: Any]()
    public var headerFields: [String : String]?

    func prepareForNext(with response: T) {

    }

    func resetToStart() {

    }
}

