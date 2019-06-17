//
//  BaseService.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public struct FlexNetServiceConfiguration {
    public static var urlSessionConfiguration: URLSessionConfiguration?
    public static var publicKeysForSSLPinningProvider: ((String) -> ([SSLPinningService.PublicKey]?))?
}

public final class FlexNetService<T: FlexDecodable, E: DecodableError>: NSObject, Service, URLSessionTaskDelegate {
    public typealias ResultType = T
    public typealias ServerSideErrorType = E
    
    public var responseHandler: HTTPResponseHandler<T, E>? = HTTPResponseHandler<T, E>()
    public var request: HTTPRequestRepresentable?
    public var logger: Logger = BaseLogger()
    public var preRequestCallback: (() -> ())?
    public var requestPreparator: RequestPreparator? = BaseRequestPreparator()
    
    private var successHandler: SuccessHandlerBlock?
    private var failureHandler: FailureHandlerBlock?
    private var errorHandler: ClientSideErrorHandlerBlock?
    
    private var progressHandler: ((Double) -> ())?
    private var endHandler: (() -> ())?
    private var lastPageHandler: (() -> ())?
    private var handlingQueue: DispatchQueue?
    private var currentResponse: ResponseRepresentable?
    private var lastModel: ResultType?
    private var processOnlyLastPage = false
    private var mustNotInvalidateOnEnd = false
    
    private lazy var session: URLSession = {
        let session = URLSession(configuration: FlexNetServiceConfiguration.urlSessionConfiguration ?? .default,
                                 delegate: self,
                                 delegateQueue: nil)
        
        return session
    }()
    
    @discardableResult
    public func sendRequest() -> FlexNetService<T, E>? {
        guard var request = request else {
            return nil
        }
        
        if processLastPageIfNeeded() {
            return self
        }
        
        requestPreparator?.prepareRequest(&request)
        
        guard let urlRequest = request.urlRequest() else {
            return nil
        }
        
        logger.logRequest(request)
        preRequestCallback?()
        session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            
            strongSelf.currentResponse = BaseResponse(data: data, response: response, error: error)
            strongSelf.logger.logResponse(strongSelf.currentResponse!)
            strongSelf.responseHandler?.handleResponse(strongSelf.currentResponse!, completion: { [weak self] (result, clientError) in
                defer {
                    self?.processEnd()
                }
                
                guard let `self` = self else {
                    return
                }
                
                guard let result = result else {
                    self.processError(clientError ?? .unknown)
                    
                    return
                }
                
                switch result {
                case let .success(model):
                    self.lastModel = model
                    let isLast = self.processPagedRequestIfNeededWith(model)
                    if isLast {
                        if !(self.processOnlyLastPage) {
                            self.processSuccess(model)
                        }
                    } else {
                        self.processSuccess(model)
                    }
                case let .failure(error):
                    self.processFailure(error)
                }
            })
            
            }.resume()
        
        return self
    }
    
    @discardableResult
    public func doNotInvalidateSessionOnRequestEnd() -> FlexNetService<T, E> {
        mustNotInvalidateOnEnd = true
        
        return self
    }
    
    @discardableResult
    public func onlyLastPage() -> FlexNetService<T, E> {
        processOnlyLastPage = true
        
        return self
    }
    
    public func resetRequest() {
        guard let pagedRequest = request as? PagedRequest else {
            return
        }
        
        pagedRequest.resetToStart()
        lastModel = nil
    }
    
    @discardableResult
    public func onSuccess(_ success: @escaping SuccessHandlerBlock) -> FlexNetService<T, E> {
        successHandler = success
        
        return self
    }
    
    @discardableResult
    public func onFailure(_ failure: @escaping FailureHandlerBlock) -> FlexNetService<T, E> {
        failureHandler = failure
        
        return self
    }
    
    @discardableResult
    public func onError(_ error: @escaping ClientSideErrorHandlerBlock) -> FlexNetService<T, E> {
        errorHandler = error
        
        return self
    }
    
    @discardableResult
    public func onEnd(_ end: @escaping () -> ()) -> FlexNetService<T, E> {
        endHandler = end
        
        return self
    }
    
    @discardableResult
    public func onProgress(_ progress: @escaping (Double) -> ()) -> FlexNetService<T, E> {
        progressHandler = progress
        
        return self
    }
    
    @discardableResult
    public func dispatchOn(_ queue: DispatchQueue) -> FlexNetService<T, E> {
        handlingQueue = queue
        
        return self
    }
    
    @discardableResult
    public func onLastPage(_ lastPage: @escaping () -> ()) -> FlexNetService<T, E> {
        lastPageHandler = lastPage
        
        return self
    }
    
    private func processPagedRequestIfNeededWith(_ model: T) -> Bool {
        guard let pagedRequest = request as? PagedRequest,
            let pageable = model as? Pageable else {
            return false
        }
        
        pagedRequest.prepareForNextWithCursor(pageable.nextCursor)
        
        if pageable.isPagesDidEnd {
            processLastPage()
            return true
        }
        
        return false
    }
    
    private func processLastPageIfNeeded() -> Bool {
        if isPagesEnded() {
            processLastPage()
            
            return true
        }
        
        return false
    }
    
    private func isPagesEnded() -> Bool {
        if let pageableModel = lastModel as? Pageable {
            return pageableModel.isPagesDidEnd
        }
        
        return false
    }
    
    private func isRequestPaged() -> Bool {
        return request is PagedRequest
    }
    
    private func processSuccess(_ model: T) {
        dispatch { [weak self] in
            self?.successHandler?(model)
        }
    }
    
    private func processFailure(_ error: E) {
        dispatch { [weak self] in
            self?.failureHandler?(error)
        }
    }
    
    private func processError(_ error: ClientSideError) {
        dispatch { [weak self] in
            self?.errorHandler?(error, self?.currentResponse)
        }
    }
    
    private func processEnd() {
        if !mustNotInvalidateOnEnd {
            session.invalidateAndCancel()
        }
        
        dispatch { [weak self] in
            self?.endHandler?()
        }
    }
    
    private func processLastPage() {
        dispatch { [weak self] in
            self?.lastPageHandler?()
        }
    }
    
    private func dispatch(_ block: @escaping () -> ()) {
        guard let queue = handlingQueue else {
            block()
            return
        }
        
        queue.async {
            block()
        }
    }
    
    private func preparePagedRequestIfNeeded(with model: T) {
        guard let pagedRequest = request as? PagedRequest,
            let pageableModel = model as? Pageable else {
            return
        }
        
        pagedRequest.prepareForNextWithCursor(pageableModel.nextCursor)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        dispatch { [weak self] in
            if #available(iOS 11.0, *) {
                self?.progressHandler?(task.progress.fractionCompleted)
            } else {
                self?.progressHandler?(Double(task.countOfBytesReceived)/Double(task.countOfBytesExpectedToReceive))
            }
        }
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let protectionSpace = challenge.protectionSpace
        
        guard let trust = protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            processError(.sslPinningDidFail)
            
            return
        }
        
        guard let keys = FlexNetServiceConfiguration.publicKeysForSSLPinningProvider?(protectionSpace.host) else {
            completionHandler(.useCredential, URLCredential(trust: trust))
            
            return
        }
        
        guard SSLPinningService(keys).validateServerTrust(trust) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            processError(.sslPinningDidFail)
            
            return
        }
        
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}

