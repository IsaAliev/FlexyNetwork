//
//  Data+String.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 04.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

extension Data {
    mutating func append(_ value: BodyParameterValue) {
        withUnsafePointer(to: value) { (ptr: UnsafePointer<BodyParameterValue>) in
            append(UnsafeBufferPointer(start: ptr, count: 1))
        }
    }
}
