//
//  BaseService.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

#if canImport(Combine)
import Combine
#endif

public struct PinningConfig {
    let keys: [SSLPinningService.PublicKey]
    let acceptableCertifacteTrustEvaluationResults: [SecTrustResultType]
    
    public init(keys: [SSLPinningService.PublicKey], acceptableCertifacteTrustEvaluationResults: [SecTrustResultType]) {
        self.keys = keys
        self.acceptableCertifacteTrustEvaluationResults = acceptableCertifacteTrustEvaluationResults
    }
}

public typealias SSLPinningKeysProvider = (String) -> (PinningConfig?)

public final class FlexNetService<T: FlexDecodable, E: DecodableError>: NSObject, Service, URLSessionTaskDelegate {
    public typealias ResultType = T
    public typealias ServerSideErrorType = E
    
    public var responseHandler: HTTPResponseHandler<T, E>? = HTTPResponseHandler<T, E>()
    public var request: HTTPRequestRepresentable?
    public var logger: Logger?
    public var preRequestCallback: (() -> ())?
    public var requestPreparators: [RequestPreparator]? = []
    public var urlSessionConfiguration: URLSessionConfiguration = .default
    public var publicKeysForSSLPinningProvider: SSLPinningKeysProvider?
    
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
        let session = URLSession(configuration: urlSessionConfiguration,
                                 delegate: self,
                                 delegateQueue: nil)
        
        return session
    }()
    
#if canImport(Combine)
    @available(iOS 13.0, *)
    lazy var lastPagePublisher = PassthroughSubject<Void, Never>()
#endif
    @discardableResult
    public func sendRequest() -> FlexNetService<T, E>? {
        guard var request = request else {
            return nil
        }
        
        if processLastPageIfNeeded() {
            return self
        }

        requestPreparators?.forEach {
            var requestPreparator = $0
            requestPreparator.prepareRequest(&request)
        }

        guard let urlRequest = request.urlRequest() else {
            return nil
        }
        
        logger?.logRequest(request)
        preRequestCallback?()
		
        session.dataTask(with: urlRequest) { [weak self] (data, response, error) in
			defer { self?.processEnd() }
			
			guard let self = self, let responseHandler = self.responseHandler else { return }
			
			self.currentResponse = BaseResponse(data: data, response: response, error: error)
			self.logger?.logResponse(self.currentResponse!)
			let (result, clientError) = responseHandler.handleResponse(self.currentResponse!)
			
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
        guard var pagedRequest = request as? PagedRequest else {
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
        guard var pagedRequest = request as? PagedRequest,
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
        dispatch { [weak self] in self?.successHandler?(model) }
    }
    
    private func processFailure(_ error: E) {
        dispatch { [weak self] in self?.failureHandler?(error) }
    }
    
    private func processError(_ error: ClientSideError) {
        dispatch { [weak self] in self?.errorHandler?(error, self?.currentResponse) }
    }
    
    private func processEnd() {
        dispatch { [weak self] in self?.endHandler?() }
        
        if !mustNotInvalidateOnEnd {
            session.invalidateAndCancel()
        }
    }
    
    private func processLastPage() {
		if #available(iOS 13.0, *) {
			lastPagePublisher.send()
		}
		
        dispatch { [weak self] in self?.lastPageHandler?() }
    }
    
    private func dispatch(_ block: @escaping () -> ()) {
        guard let queue = handlingQueue else {
            block()
            return
        }
        
        queue.async { block() }
    }
    
    private func preparePagedRequestIfNeeded(with model: T) {
        guard var pagedRequest = request as? PagedRequest,
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
    
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        willPerformHTTPRedirection response: HTTPURLResponse,
        newRequest request: URLRequest,
        completionHandler: @escaping (URLRequest?) -> Void
    ) {
        guard let requestPreparators = requestPreparators else {
            completionHandler(request)
            return
        }
        
        var newRequest = request
        
        for var prep in requestPreparators {
            switch prep.handleRedirectRequest(request) {
            case .cancel:
                completionHandler(nil)
                return
            case let .proceed(request):
                newRequest = request
            }
        }
        
        completionHandler(newRequest)
    }
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {        
        let protectionSpace = challenge.protectionSpace
        
        guard let trust = protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            processError(.sslPinningDidFail)
            
            return
        }
        
        guard let config = publicKeysForSSLPinningProvider?(protectionSpace.host) else {
            completionHandler(.useCredential, URLCredential(trust: trust))
            
            return
        }
        
        guard SSLPinningService(config: config).validateServerTrust(trust) else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            processError(.sslPinningDidFail)
            
            return
        }
        
        completionHandler(.useCredential, URLCredential(trust: trust))
    }
}
#if canImport(Combine)
public extension FlexNetService {
	@available(iOS 13.0, *)
	func sendRequestPublisher() -> AnyPublisher<Result<T,E>, Error>? {
		guard var request = request else {
			return nil
		}
		
		if processLastPageIfNeeded() {
			return nil
		}
		
        requestPreparators?.forEach {
            var requestPreparator = $0
            requestPreparator.prepareRequest(&request)
        }
        
		guard let urlRequest = request.urlRequest() else {
			return nil
		}
		
		logger?.logRequest(request)
		preRequestCallback?()
		
		return session.dataTaskPublisher(for: urlRequest).map({ [weak self] res in
			let bRes = BaseResponse(data: res.0, response: res.1, error: nil)
			self?.currentResponse = bRes
			self?.logger?.logResponse(bRes)
			
			return bRes
		}).map({ [weak self] res in
			return self?.responseHandler?.handleResponse(res)
		}).tryMap({ res -> Result<T, E> in
			guard let res = res?.0 else {
				throw res?.1 ?? ClientSideError.unknown
			}
			
			return res
		}).filter({ [weak self] result in
			guard let self = self else { return true }
			switch result {
			case let .success(model):
				self.lastModel = model
				let isLast = self.processPagedRequestIfNeededWith(model)
				return !(isLast && self.processOnlyLastPage)
			default: return true
			}
		}).eraseToAnyPublisher()
	}
}
#endif
