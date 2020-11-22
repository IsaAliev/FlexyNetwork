//
//  HTTPPOSTRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol HTTPPOSTRequest: HTTPRequestRepresentable { }

public extension HTTPPOSTRequest {
    var httpMethod: HTTPMethod { .POST }
}
