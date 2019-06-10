//
//  ModelDecodingProcessor.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 20.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

open class ModelDecodingProcessor<T: Decodable>: DecodingProcessor {
    public typealias DecodingResult = T
    
    public func decodeFrom(_ data: Data) throws -> T {
        let decoder = JSONDecoder()
        
        let model = try decoder.decode(T.self, from: data)
        
        return model
    }
}
