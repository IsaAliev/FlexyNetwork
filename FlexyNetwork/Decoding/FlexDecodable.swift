//
//  FlexDecodable.swift
//  FlexyNetwork
//
//  Created by Isa Aliev on 15/06/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation
import UIKit

enum FlexDecodableError: Error {
    case decodingDidFail
}

public protocol FlexDecodable {
    static var jsonDecoder: JSONDecoder? { get }
    static func decodeFrom(_ data: Data) throws -> Self
    static func decodeFrom(_ data: Data, with decoder: JSONDecoder) throws -> Self
}

public protocol StatusCodeContaining {
    var statusCode: Int { get set }
}

public extension FlexDecodable {
    static var jsonDecoder: JSONDecoder? {
        return nil
    }
}

public extension FlexDecodable where Self: Decodable {
    static var jsonDecoder: JSONDecoder? {
        return JSONDecoder()
    }
    
    static func decodeFrom(_ data: Data) throws -> Self {
        return try jsonDecoder!.decode(Self.self, from: data)
    }
    
    static func decodeFrom(_ data: Data, with decoder: JSONDecoder) throws -> Self {
        return try decoder.decode(Self.self, from: data)
    }
}

public extension FlexDecodable where Self: UIImage {
    static func decodeFrom(_ data: Data) throws -> Self {
        guard let image = UIImage(data: data) else {
            throw FlexDecodableError.decodingDidFail
        }
        
        return image as! Self
    }
    
    static func decodeFrom(_ data: Data, with decoder: JSONDecoder) throws -> Self {
        return try decodeFrom(data)
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

public protocol SnakeCaseDecodable: FlexDecodable {}

public extension SnakeCaseDecodable {
    static var jsonDecoder: JSONDecoder? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return decoder
    }
}

public struct SnakeCasedArray<E: Decodable>: Decodable, SnakeCaseDecodable {
    public var array: Array<E>
    
    public static func decodeFrom(_ data: Data) throws -> SnakeCasedArray {
        let decodedArray = try jsonDecoder!.decode(Array<E>.self, from: data)
        
        return SnakeCasedArray(array: decodedArray)
    }
}

public struct SnakeCasedDictionary<K: Decodable & Hashable, V: Decodable>: Decodable, SnakeCaseDecodable {
    public var dictionary: Dictionary<K, V>
    
    public static func decodeFrom(_ data: Data) throws -> SnakeCasedDictionary {
        let decodedDictionary = try jsonDecoder!.decode(Dictionary<K, V>.self, from: data)
        
        return SnakeCasedDictionary(dictionary: decodedDictionary)
    }
}
