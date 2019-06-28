//
//  PagedRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 26.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol PagedRequest: HTTPGETRequest {
    mutating func prepareForNextWithCursor(_ cursor: String)
    mutating func resetToStart()
}

public protocol Pageable {
    var nextCursor: String { get }
    var isPagesDidEnd: Bool { get }
}
