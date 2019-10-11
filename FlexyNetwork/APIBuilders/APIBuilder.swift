//
//  APIBuilder.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

open class APIBuilder {
    var dummyService = FlexNetService<FlexNever, FlexNever>()
    
    public init() {}
    
    open func setLogger(_ logger: Logger) -> Self {
        dummyService.logger = logger
        
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
    
    open func build<T, E>(for responseType: T.Type, orError errorType: E.Type) -> FlexNetService<T, E> {
        let service = FlexNetService<T, E>()
        
        service.request = dummyService.request
        service.requestPreparator = dummyService.requestPreparator
        service.logger = dummyService.logger
        service.responseHandler?.headersHandler = dummyService.responseHandler?.headersHandler
        service.responseHandler?.nestedModelGetter = dummyService.responseHandler?.nestedModelGetter
        service.responseHandler?.successResponseChecker = dummyService.responseHandler?.successResponseChecker ?? BaseSuccessResponseChecker()

        return service
    }
}
