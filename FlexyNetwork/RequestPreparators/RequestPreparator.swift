//
//  RequestPreparator.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 21.02.2018.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public protocol RequestPreparator {
    func prepareRequest(_ request: inout HTTPRequestRepresentable)
}
