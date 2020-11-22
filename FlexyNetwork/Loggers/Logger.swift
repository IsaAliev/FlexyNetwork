//
//  Loger.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 08.03.18.
//  Copyright © 2018 IA. All rights reserved.
//

public protocol Logger {
    func logRequest(_ request: HTTPRequestRepresentable)
    func logResponse(_ response: ResponseRepresentable)
}
