//
//  String+Utils.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 08/06/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation

extension String {
    func extractingPublicKeyWithoutWhitespaceCharacters() -> String {
        var result = self
        
        if let beginHeaderRange = range(of: "-----BEGIN PUBLIC KEY-----"),
            let endHeaderRange = range(of: "-----END PUBLIC KEY-----") {
            result = String(self[beginHeaderRange.upperBound..<endHeaderRange.lowerBound])
        }
        
        
        result = result.replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\t", with: "")
            .replacingOccurrences(of: " ", with: "")
        
        return result;
    }
}
