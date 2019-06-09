//
//  Service.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public enum ClientSideError: String, Error {
    case unknown = "Unknown"
    case modelProcessingError = "Failed to decode success model"
    case errorModelProcessingError = "Failed to decode error model"
    case sslPinningDidFail = "SSL pinning did fail"
    
    public func message() -> String {
        return rawValue
    }
}

public protocol Service {
    associatedtype ResultType: Decodable
    associatedtype ServerSideErrorType: DecodableError
    
    typealias SuccessHandlerBlock = (ResultType) -> ()
    typealias FailureHandlerBlock = (ServerSideErrorType) -> ()
    typealias ClientSideErrorHandlerBlock = (ClientSideError, ResponseRepresentable?) -> ()
    
    var request: HTTPRequestRepresentable? { get set }
    var responseHandler: HTTPResponseHandler<ResultType, ServerSideErrorType>? { get set }
  
    func sendRequest() -> Self?
}
