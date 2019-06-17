//
//  FlexDecodable.swift
//  FlexyNetwork
//
//  Created by Isa Aliev on 15/06/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation

enum FlexDecodableError: Error {
    case decodingDidFail
}

public protocol FlexDecodable {
    static var jsonDecoder: JSONDecoder? { get }
    static func decodeFrom(_ data: Data) throws -> Self
}

public extension FlexDecodable {
    static var jsonDecoder: JSONDecoder? {
        return nil
    }
}

public extension FlexDecodable where Self : Decodable {
    static var jsonDecoder: JSONDecoder? {
        return JSONDecoder()
    }
    
    static func decodeFrom(_ data: Data) throws -> Self {
        return try jsonDecoder!.decode(Self.self, from: data)
    }
}

public extension FlexDecodable where Self : UIImage {
    static func decodeFrom(_ data: Data) throws -> Self {
        guard let image = UIImage(data: data) else {
            throw FlexDecodableError.decodingDidFail
        }
        
        return image as! Self
    }
}

extension UIImage: FlexDecodable {}

extension String: FlexDecodable {
    public static func decodeFrom(_ data: Data) throws -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
}

extension Dictionary: FlexDecodable where Key: Decodable, Value: Decodable {
    public static func decodeFrom(_ data: Data) throws -> Dictionary {
        return try JSONDecoder().decode(Dictionary.self, from: data)
    }
}

extension Array: FlexDecodable where Element: Decodable {
    public static func decodeFrom(_ data: Data) throws -> Array {
        return try JSONDecoder().decode(Array.self, from: data)
    }
}
