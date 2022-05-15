//
//  HTTPResponseHandler.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public class HTTPResponseHandler<T: FlexDecodable, E: DecodableError>: ResponseHandler {
    public typealias ResultType = T
    public typealias ErrorType = E
    
    private var isResponseRepresentSimpleType: Bool {
        return
            T.self == Int.self ||
            T.self == String.self ||
            T.self == Double.self ||
            T.self == Float.self
    }
    
    open var errorHandler: ErrorHandler?
    open var successResponseChecker: SuccessResponseChecker = BaseSuccessResponseChecker()
    open var nestedModelGetter: NestedModelGetter?
    open var cacher: Cacher<T>?
    open var headersHandler: HeadersHandler?
    
    public init() {}
    
	public func handleResponse(_ response: ResponseRepresentable) -> (Result<T, E>?, ClientSideError?) {
		if let headers = (response.response as? HTTPURLResponse)?.allHeaderFields {
			headersHandler?.handleHeaders(headers)
		}
		
		if successResponseChecker.isSuccessResponse(response) {
			return processSuccessResponse(response)
		} else {
			return processFailureResponse(response)
		}
	}
    
    private func processSuccessResponse(_ response: ResponseRepresentable) -> (Result<T, E>?, ClientSideError?) {
        guard var data = response.data else {
            return (nil, nil)
        }

        if let nestedModelGetter = nestedModelGetter {
            if let escapedModelJSON = try? nestedModelGetter.getFrom(data) {
                if isResponseRepresentSimpleType {
                    if let result = simpleTypeUsingNestedModelGetter(from: data) {
                        return (.success(result), nil)
                    }
                    
					return (nil, .modelProcessingError)
                } else {
                    guard let model = escapedModelJSON[nestedModelGetter.escapedModelKey],
                        model is JSON || model is [JSON] || model is [Any],
                        let serializedData = try? JSONSerialization.data(withJSONObject: model, options: [])
                        else {
                            return (nil, .modelProcessingError)
                    }
                    
                    data = serializedData
                }
            }
        }

        guard let result = try? T.decodeFrom(data) else {
            return (nil, .modelProcessingError)
        }
        
        cacher?.cache(result)
        return (.success(result), nil)
    }
    
    private func simpleTypeUsingNestedModelGetter(from data: Data) -> T? {
        let getter = nestedModelGetter!
        
        guard let escapedModelJSON = try? getter.getFrom(data) else {
            return nil
        }
        
        guard let result = escapedModelJSON[getter.escapedModelKey] as? T else {
            return nil
        }
        
        return result
    }
    
	
	private func processFailureResponse(_ response: ResponseRepresentable) -> (Result<T, E>?, ClientSideError?) {
		guard let data = response.data,
			  var error = try? E.decodeFrom(data)
        else {
			return (nil, .errorModelProcessingError)
		}
        
        var resultingError = error
        
        if var codeContainer = error as? StatusCodeContaining {
            codeContainer.statusCode = (response.response as? HTTPURLResponse)?.statusCode ?? -1
            resultingError = codeContainer as! E
        }
        
		let res: (Result<T, E>?, ClientSideError?) = (.failure(resultingError), nil)
        errorHandler?.handleError(resultingError)
		
		return res
    }
}
