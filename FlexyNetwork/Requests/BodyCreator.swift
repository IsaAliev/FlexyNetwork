//
//  BodyCreator.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 04.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol BodyParameterValue { }

extension Int: BodyParameterValue { }
extension String: BodyParameterValue { }

public struct BodyCreator {
    public struct FileData {
        var name: String
        var fileName: String
        var mimeType: String
        var data: Data

        public init(name: String, fileName: String, mimeType: String, data: Data) {
            self.name = name
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
        }
    }
    
    var boundary: String
    private var boundaryPrefix: String {
        return "--\(boundary)\r\n"
    }
    private var finalBoundary: String {
        return "--\(boundary)--"
    }
    
    private var crlf = "\r\n\r\n"
    
    public init(_ boundary: String) {
        self.boundary = boundary
    }
    
    public func createBody(parameters: [String: BodyParameterValue], with files: [FileData]? = nil) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append(boundaryPrefix)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\(crlf)")
            body.append("\(value)")
            body.append("\r\n")
        }
        
        if let files = files {
            files.forEach({ appendFile($0, to: &body) })
        }
        
        body.append(finalBoundary)
        
        return body as Data
    }
    
    private func appendFile(_ file: FileData, to body: inout Data) {
        body.append(boundaryPrefix)
        body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n")
        body.append("Content-Type: \(file.mimeType)\(crlf)")
        body.append(file.data)
        body.append("\r\n")
    }
}
