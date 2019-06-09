//
//  APIBuilder.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

struct DummyDecodable: DecodableError {}

public class APIBuilder<E: DecodableError> {
    var dummyService = FlexNetService<DummyDecodable, DummyDecodable>()
    
    public init() {}
    
    public func setLoger(_ loger: Logger) -> Self {
        dummyService.logger = loger
        
        return self
    }
    
    public func setHeadersHandler(_ handler: HeadersHandler) -> Self {
        dummyService.responseHandler?.headersHandler = handler
        
        return self
    }
    
    public func setRequestPreparator(_ preparator: RequestPreparator) -> Self {
        dummyService.requestPreparator = preparator
        
        return self
    }
    
    public func setNestedModelGetter(_ modelGetter: NestedModelGetter) -> Self {
        dummyService.responseHandler?.nestedModelGetter = modelGetter
        
        return self
    }
    
    public func setSuccessResponseChecker(_ responseChecker: SuccessResponseChecker) -> Self {
        dummyService.responseHandler?.successResponseChecker = responseChecker
        
        return self
    }
    
    public func setRequest(_ request: HTTPRequestRepresentable) -> Self {
        dummyService.request = request
        
        return self
    }
    
    public func build<T>(for responseType: T.Type, andDecodingProcessor processor: ModelDecodingProcessor<T>? = nil) -> FlexNetService<T, E> {
        let service = FlexNetService<T, E>()
        
        service.request = dummyService.request
        service.requestPreparator = dummyService.requestPreparator
        service.logger = dummyService.logger
        service.responseHandler?.headersHandler = dummyService.responseHandler?.headersHandler
        service.responseHandler?.nestedModelGetter = dummyService.responseHandler?.nestedModelGetter
        service.responseHandler?.successResponseChecker = dummyService.responseHandler?.successResponseChecker ?? BaseSuccessResponseChecker()
        
        if let processor = processor  {
            service.responseHandler?.decodingProcessor = processor
        }
        
        return service
    }
}
