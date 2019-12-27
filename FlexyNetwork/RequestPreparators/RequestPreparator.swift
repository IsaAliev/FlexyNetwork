//
//  RequestPreparator.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 21.02.2018.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol RequestPreparator {
    mutating func prepareRequest(_ request: inout HTTPRequestRepresentable)
    mutating func mapRedirectRequest(_ request: URLRequest) -> URLRequest?
}

public extension RequestPreparator {
    func addFields(_ fields: [String: String], to request: inout HTTPRequestRepresentable) {
        if request.headerFields != nil {
            request.headerFields?.merge(dict: fields)
        } else {
            request.headerFields = fields
        }
    }
    
    mutating func mapRedirectRequest(_ request: URLRequest) -> URLRequest? {
        nil
    }
}
