//
//  APIBuilder.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

open class APIBuilder {
    private var logger: Logger?
    private var headersHandler: HeadersHandler?
    private var requestPreparator: RequestPreparator?
    private var nestedModelGetter: NestedModelGetter?
    private var successResponseChecker: SuccessResponseChecker?
    private var request: HTTPRequestRepresentable?
    private var errorHandler: ErrorHandler?
    
    public init() {}
    
    open func setLogger(_ logger: Logger) -> Self {
        self.logger = logger
        
        return self
    }
    
    open func setHeadersHandler(_ handler: HeadersHandler) -> Self {
        headersHandler = handler
        
        return self
    }
    
    open func setRequestPreparator(_ preparator: RequestPreparator) -> Self {
        requestPreparator = preparator
        
        return self
    }
    
    open func setNestedModelGetter(_ modelGetter: NestedModelGetter) -> Self {
        nestedModelGetter = modelGetter
        
        return self
    }
    
    open func setSuccessResponseChecker(_ responseChecker: SuccessResponseChecker) -> Self {
        successResponseChecker = responseChecker
        
        return self
    }
    
    open func setRequest(_ request: HTTPRequestRepresentable) -> Self {
        self.request = request
        
        return self
    }
    
    open func setErrorHandler(_ handler: ErrorHandler) -> Self {
        errorHandler = handler
        
        return self
    }
    
    open func build<T, E>(for responseType: T.Type, orError errorType: E.Type) -> FlexNetService<T, E> {
        let service = FlexNetService<T, E>()
        
        service.request = request
        service.requestPreparator = requestPreparator
        service.logger = logger
        service.responseHandler?.headersHandler = headersHandler
        service.responseHandler?.nestedModelGetter = nestedModelGetter
        service.responseHandler?.successResponseChecker = successResponseChecker ?? BaseSuccessResponseChecker()
        service.responseHandler?.errorHandler = errorHandler
        
        return service
    }
}
