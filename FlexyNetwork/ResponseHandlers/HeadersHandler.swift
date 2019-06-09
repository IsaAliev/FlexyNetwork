//
//  HeadersHandler.swift
//  BestLikes
//
//  Created by Isa Aliev on 06/10/2018.
//  Copyright © 2018 Isa Aliev. All rights reserved.
//

import Foundation

public protocol HeadersHandler {
    func handleHeaders(_ headers: [AnyHashable: Any])
}
