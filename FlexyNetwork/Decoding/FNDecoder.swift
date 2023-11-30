//
//  FNDecoder.swift
//
//
//  Created by Isa Aliev on 30.11.2023.
//

import Foundation

public protocol FNDecoder {
    
    func decode<T: FlexDecodable>(_ data: Data) throws -> T
}
