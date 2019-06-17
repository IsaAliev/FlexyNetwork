//
//  SSLPinningService.swift
//  FlexibleNetworkLayer
//
//  Created by Isa Aliev on 08/06/2019.
//  Copyright © 2019 IA. All rights reserved.
//

import Foundation

public class SSLPinningService {
    public struct PublicKey {
        public enum KeyType {
            case RSA
            case EC
            @available(iOS 10.0, *)
            case ECSECPrimeRandom
            
            func cfSecString() -> CFString {
                switch self {
                case .EC:
                    return kSecAttrKeyTypeEC
                case .RSA:
                    return kSecAttrKeyTypeRSA
                case .ECSECPrimeRandom:
                    if #available(iOS 10.0, *) {
                        return kSecAttrKeyTypeECSECPrimeRandom
                    } else {
                        return kSecAttrKeyTypeEC
                    }
                }
            }
        }
        
        let base64EncodedKey: String
        var type: KeyType = .RSA
        
        public init(_ key: String) {
            self.base64EncodedKey = key
        }
        
        public init(_ key: String, ofType type: KeyType) {
            self.type = type
            self.base64EncodedKey = key
        }
    }
    
    private let allowedPublicKeys: [PublicKey]
    
    init(_ publicKeys: [PublicKey]) {
        allowedPublicKeys = publicKeys
    }
    
    func validateServerTrust(_ serverTrust: SecTrust) -> Bool {
        let publicKeys = publicKeyTrustChainForServerTrust(serverTrust)
        
        var trustedPublicKeyCount = 0
        
        for key in allowedPublicKeys {
            let rawKey = key.base64EncodedKey.extractingPublicKeyWithoutWhitespaceCharacters()
            guard let keyData = Data(base64Encoded: rawKey),
                let publicKeyRef = createSecKeyFrom(keyData, ofKeyOfType: key.type.cfSecString()) else {
                    continue
            }
            
            for key in publicKeys {
                if publicKeyRef == key {
                    trustedPublicKeyCount += 1
                }
            }
        }
        
        return trustedPublicKeyCount > 0
    }
    
    func createSecKeyFrom(_ data: Data, ofKeyOfType type: CFString) -> SecKey? {
        let tagString = "com.example.key"
        let tag = tagString.data(using: .utf8)
        
        var dict = [String: Any]()
        
        dict[kSecClass as String] = kSecClassKey
        dict[kSecAttrKeyType as String] = kSecAttrKeyTypeRSA
        dict[kSecAttrApplicationTag as String] = tag
        
        SecItemDelete(dict as CFDictionary);
        
        dict[kSecValueData as String] = data
        dict[kSecAttrKeyClass as String] = kSecAttrKeyClassPublic
        dict[kSecAttrIsPermanent as String] = false
        dict[kSecReturnRef as String] = true
        
        var ref: CFTypeRef?
        
        let status = SecItemAdd(dict as CFDictionary, &ref)
        
        if status != errSecSuccess || ref == nil {
            return nil
        }
        
        return (ref as! SecKey)
    }
    
    func publicKeyTrustChainForServerTrust(_ serverTrust: SecTrust) -> [SecKey] {
        let policy = SecPolicyCreateBasicX509()
        let certificateCount = SecTrustGetCertificateCount(serverTrust)
        var trustChain = [SecKey]()
        
        for i in 0..<certificateCount {
            let certificate = SecTrustGetCertificateAtIndex(serverTrust, i)
            let certificates = [certificate] as CFArray
            var trust: SecTrust?
            
            SecTrustCreateWithCertificates(certificates, policy, &trust)
            
            if trust == nil {
                continue
            }
            
            var result: SecTrustResultType = .unspecified
            
            SecTrustEvaluate(trust!, &result)
            
            guard result == .unspecified ||
                result == .proceed else {
                    continue
            }
            
            if let key = SecTrustCopyPublicKey(trust!) {
                trustChain += [key]
            }
        }
        
        return trustChain
    }
}
