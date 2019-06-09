//
//  BaseResponse.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 19.02.18.
//  Copyright © 2018 IA. All rights reserved.
//

import Foundation

public struct BaseResponse: ResponseRepresentable {
    public var data: Data?
    public var response: URLResponse?
    public var error: Error?
}
