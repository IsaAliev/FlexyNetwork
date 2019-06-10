//
//  APIBuilder.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

struct DummyDecodable: DecodableError {}

open class APIBuilder<E: DecodableError> {
    var dummyService = FlexNetService<DummyDecodable, DummyDecodable>()
    
    public init() {}
    
    open func setLoger(_ loger: Logger) -> Self {
        dummyService.logger = loger
        
        return self
    }
    
    open func setHeadersHandler(_ handler: HeadersHandler) -> Self {
        dummyService.responseHandler?.headersHandler = handler
        
        return self
    }
    
    open func setRequestPreparator(_ preparator: RequestPreparator) -> Self {
        dummyService.requestPreparator = preparator
        
        return self
    }
    
    open func setNestedModelGetter(_ modelGetter: NestedModelGetter) -> Self {
        dummyService.responseHandler?.nestedModelGetter = modelGetter
        
        return self
    }
    
    open func setSuccessResponseChecker(_ responseChecker: SuccessResponseChecker) -> Self {
        dummyService.responseHandler?.successResponseChecker = responseChecker
        
        return self
    }
    
    open func setRequest(_ request: HTTPRequestRepresentable) -> Self {
        dummyService.request = request
        
        return self
    }
    
    open func build<T>(for responseType: T.Type, andDecodingProcessor processor: ModelDecodingProcessor<T>? = nil) -> FlexNetService<T, E> {
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
