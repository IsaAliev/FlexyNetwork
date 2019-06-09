//
//  NestedModelGetter.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 22.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public enum NestedModelGettingError: Error {
    case failedToSerializeData
}

public protocol NestedModelGetter {
    var keyPath: String { get }
    var escapedModelKey: String { get }
}

extension NestedModelGetter {
    var escapedModelKey: String {
        return "escaped"
    }
    
    func getFrom(_ json: JSON) throws -> JSON {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        return try getFrom(data)
    }
    
    func getFrom(_ data: Data) throws -> JSON {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? JSON else {
            throw NestedModelGettingError.failedToSerializeData
        }
        
        if let result = json[keyPath: keyPath] {
            return [escapedModelKey: result]
        }

        throw NestedModelGettingError.failedToSerializeData
    }
}




