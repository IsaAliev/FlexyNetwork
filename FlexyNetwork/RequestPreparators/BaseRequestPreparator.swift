//
//  BaseRequestPreparator.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 21.02.2018.
//  Copyright © 2018 IA. All rights reserved.
//

public struct BaseRequestPreparator: RequestPreparator {
    public func prepareRequest(_ request: inout HTTPRequestRepresentable) {}
}
