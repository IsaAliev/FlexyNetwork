//
//  HTTPResponseHandler.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public class HTTPResponseHandler<T: Decodable, E: DecodableError>: ResponseHandler {
    public typealias ResultType = T
    public typealias ErrorType = E
    
    private var isResponseRepresentSimpleType: Bool {
        return
            T.self == Int.self ||
            T.self == String.self ||
            T.self == Double.self ||
            T.self == Float.self
    }
    
    var errorHandler: ErrorHandler?
    var successResponseChecker: SuccessResponseChecker = BaseSuccessResponseChecker()
    var decodingProcessor = ModelDecodingProcessor<T>()
    var nestedModelGetter: NestedModelGetter?
    var cacher: Cacher<T>?
    var headersHandler: HeadersHandler?
    
    public func handleResponse(_ response: ResponseRepresentable, completion: (Result<T, E>?, ClientSideError?) -> ()) {
        if let headers = (response.response as? HTTPURLResponse)?.allHeaderFields {
            headersHandler?.handleHeaders(headers)
        }
        
        if successResponseChecker.isSuccessResponse(response) {
            processSuccessResponse(response, completion: completion)
        } else {
            processFailureResponse(response, completion: completion)
        }
    }
    
    private func processSuccessResponse(_ response: ResponseRepresentable, completion: (Result<T, E>?, ClientSideError?) -> ()) {
        guard var data = response.data else {
            return
        }

        if let nestedModelGetter = nestedModelGetter {
            if let escapedModelJSON = try? nestedModelGetter.getFrom(data) {
                if isResponseRepresentSimpleType {
                    if let result = simpleTypeUsingNestedModelGetter(from: data) {
                        completion(.success(result), nil)
                        return
                    }
                    
                    completion(nil, .modelProcessingError)
                    return
                } else {
                    guard let model = escapedModelJSON[nestedModelGetter.escapedModelKey],
                        model is JSON || model is [JSON],
                        let serializedData = try? JSONSerialization.data(withJSONObject: model, options: [])
                        else {
                            completion(nil, .modelProcessingError)
                            return
                    }
                    
                    data = serializedData
                }
            }
        }

        guard let result = try? decodingProcessor.decodeFrom(data) else {
            completion(nil, .modelProcessingError)
            
            return
        }
        
        cacher?.cache(result)
        completion(.success(result), nil)
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
    
    
    private func processFailureResponse(_ response: ResponseRepresentable, completion: (Result<T, E>?, ClientSideError?) -> ()) {
        guard let data = response.data,
            let error = try? JSONDecoder().decode(E.self, from: data) else {
                completion(nil, .errorModelProcessingError)
            
            return
        }
        
        completion(.failure(error), nil)
        errorHandler?.handleError(error)
    }
}
