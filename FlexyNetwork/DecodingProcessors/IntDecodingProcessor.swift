//
//  IntDecodingProcessor.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 23.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

extension Int: Initializable {
    public static func get() -> Initializable {
        return 0
    }
}

class IntDecodingProcessor: ModelDecodingProcessor<Int> {
    override func decodeFrom(_ data: Data) throws -> Int {
        return data.withUnsafeBytes({ $0.pointee })
    }
}
