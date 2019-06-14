//
//  StringDecodingProcessor.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public enum StringDecodingError: Error {
    case failedToDecodeString
}

extension String: Initializable {
    public static func get() -> Initializable {
        return ""
    }
}

public class StringDecodingProcessor: ModelDecodingProcessor<String> {
    open var encoding: String.Encoding = .utf8
    
    override public func decodeFrom(_ data: Data) throws -> String {
        if let string = String(bytes: data, encoding: encoding) {
            return string
        }
        
        throw StringDecodingError.failedToDecodeString
    }
}
