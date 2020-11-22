//
//  ResponseHandler.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

public typealias JSON = [String: Any]

public protocol DecodableError: Error, FlexDecodable {}

public struct FlexNever: DecodableError, Decodable {}

public protocol ResponseHandler {
    associatedtype ResultType
    associatedtype ErrorType: DecodableError
    
    func handleResponse(_ response: ResponseRepresentable,
                        completion: (Result<ResultType, ErrorType>?, ClientSideError?) -> ())
}
