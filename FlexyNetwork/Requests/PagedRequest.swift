//
//  PagedRequest.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 26.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

public protocol PagedRequest: HTTPGETRequest {
    mutating func prepareForNextWithCursor(_ cursor: Any)
    mutating func resetToStart()
}

public protocol Pageable {
    var nextCursor: Any { get }
    var isPagesDidEnd: Bool { get }
}
