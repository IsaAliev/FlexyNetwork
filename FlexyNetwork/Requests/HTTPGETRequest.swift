//
//  HTTPGetRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 21.02.2018.
//  Copyright © 2018 IA. All rights reserved.
//

public protocol HTTPGETRequest: HTTPRequestRepresentable { }

public extension HTTPGETRequest {
    var httpMethod: HTTPMethod { .GET }
    
    var body: Data? {
        get { nil }
        set { }
    }
}
