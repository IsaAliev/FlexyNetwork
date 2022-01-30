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
    
    private let acceptableResults: [SecTrustResultType]
    private let allowedPublicKeys: [PublicKey]
    
    init(config: PinningConfig) {
        self.allowedPublicKeys = config.keys
        self.acceptableResults = config.acceptableCertifacteTrustEvaluationResults
    }
    
    init(_ publicKeys: [PublicKey]) {
        allowedPublicKeys = publicKeys
        acceptableResults = [.unspecified, .proceed]
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
        
        var query = [String: Any]()
        
        var correctedKeyData = data
        
        if type == kSecAttrKeyTypeEC {
            correctedKeyData = data[data.count-65..<data.count]
        }
        
        query[kSecClass as String] = kSecClassKey
        query[kSecAttrKeyType as String] = type
        query[kSecAttrApplicationTag as String] = tag
        
        SecItemDelete(query as CFDictionary);
        
        query[kSecValueData as String] = correctedKeyData
        query[kSecAttrKeyClass as String] = kSecAttrKeyClassPublic
        query[kSecReturnPersistentRef as String] = kCFBooleanTrue

        var persistKey: CFTypeRef?
        
        var status = SecItemAdd(query as CFDictionary, &persistKey)
        
        if status != errSecSuccess && status != errSecDuplicateItem {
            return nil
        }
        
        query[kSecValueData as String] = nil
        query[kSecReturnPersistentRef as String] = nil
        query[kSecReturnRef as String] = kCFBooleanTrue
        query[kSecAttrKeyType as String] = type

        var keyRef: CFTypeRef?
        
        status = SecItemCopyMatching(query as CFDictionary, &keyRef)
        
        if status != errSecSuccess || keyRef == nil {
            return nil
        }
        
        return (keyRef as! SecKey)
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
            
            guard acceptableResults.contains(result) else {
                continue
            }
            
            if let key = SecTrustCopyPublicKey(trust!) {
                trustChain += [key]
            }
        }
        
        return trustChain
    }
}
