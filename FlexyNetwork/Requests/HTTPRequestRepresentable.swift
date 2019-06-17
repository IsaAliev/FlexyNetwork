//
//  HTTPRequestRepresentable.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

public protocol HTTPRequestRepresentable {
    var contentType: ContentTypeRepresentable { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: JSON? { get set }
    var headerFields: [String: String]? { get set }
    var body: Data? { get set }
    var allowPreparation: Bool { get }
}

enum HeaderKey: String {
    case contentType = "Content-Type"
    case contentLength = "Content-Length"
}

public extension HTTPRequestRepresentable {
    var contentType: ContentTypeRepresentable {
        return ContentType.NonStandart.urlEncoded
    }
    
    var allowPreparation: Bool {
        return true
    }
    
    func urlRequest() -> URLRequest? {
        var urlComponents: URLComponents!
        
        if let comps = URLComponents(string: self.path) {
            urlComponents = comps
        } else {
            urlComponents = URLComponents()
        }
        
        if let parametersJSON = self.parameters {
            var queryItems = [URLQueryItem]()
            
            for (key, value) in parametersJSON {
                var valueString = value as? String
                if valueString == nil {
                    if let number = value as? NSNumber {
                        valueString = String(describing: number)
                    } else if let dictionary = value as? [String: String] {
                        var dictString = "{"
                        for (key, value) in dictionary {
                            dictString += "\"\(key)\":\"\(value)\","
                        }
                        valueString = (String(dictString.dropLast()) + "}").removingPercentEncoding ?? ""
                    }
                }
                queryItems.append(URLQueryItem(name: key, value: valueString))
            }
            
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = self.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = headerFields
        
        if urlRequest.allHTTPHeaderFields?[HeaderKey.contentType.rawValue] == nil {
            urlRequest.allHTTPHeaderFields?[HeaderKey.contentType.rawValue] = contentType.fullName()
        }
        
        if urlRequest.allHTTPHeaderFields?[HeaderKey.contentLength.rawValue] == nil {
            urlRequest.addContentLength()
        }
        
        if let body = body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
}

extension URLRequest {
    mutating func addContentLength() {
        if let body = httpBody {
            let length = NSData(data: body).length
            if length > 0 {
                allHTTPHeaderFields?[HeaderKey.contentLength.rawValue] = "\(length)"
            }
        }
    }
}
