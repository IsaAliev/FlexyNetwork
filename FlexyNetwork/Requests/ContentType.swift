//
//  ContentType.swift
//  FlexyNetwork
//
//  Created by Isa Aliev on 14/06/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation

public protocol ContentTypeRepresentable {
    func fullName() -> String
}

public extension ContentTypeRepresentable where Self : RawRepresentable, Self.RawValue == String {
    func fullName() -> String {
        return rawValue
    }
}

public struct ContentType {
    public enum Application: String, ContentTypeRepresentable {
        case json
        case octetStream = "octet-stream"
        
        public func fullName() -> String {
            return "application/" + rawValue
        }
    }
    
    public enum Multipart: String, ContentTypeRepresentable {
        case mixed
        case formData = "form-data"
        
        public func fullName() -> String {
            return "multipart/" + rawValue + "; boundary=\(boundary())"
        }
        
        public func boundary() -> String {
            return "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        }
    }
    
    public enum Video: String, ContentTypeRepresentable {
        case mpeg
        case mp4
        case ogg
        case quicktime
        case webm
        case xMsWmv = "x-ms-wmv"
        case xFlv = "x-flv"
        case a3gpp = "3gpp"
        case a3gpp2 = "3gpp2"
        
        public func fullName() -> String {
            return "video/" + rawValue
        }
    }
    
    public enum Image: String, ContentTypeRepresentable {
        case gif
        case jpeg
        case pjpeg
        case png
        case svgXml = "svg+xml"
        case tiff
        case vndMicrosoftIcon = "vnd.microsoft.icon"
        case vndWapWbmp = "vnd.wap.wbmp"
        case webp
        
        public func fullName() -> String {
            return "image/" + rawValue
        }
    }
    
    public enum NonStandart: String, ContentTypeRepresentable {
        case urlEncoded = "application/x-www-form-urlencoded"
    }
}
