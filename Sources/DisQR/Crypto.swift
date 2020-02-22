//
//  Crypto.swift
//  
//
//  Created by Leah Lundqvist on 2020-02-21.
//

import Foundation
import RSAPublicKeyExporter
import CommonCrypto

public class Crypto {
    var privateKey: SecKey
    var publicKey: SecKey
    public var publicBase64: String
    
    public init () throws {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeySizeInBits as String: 2048,
            kSecPrivateKeyAttrs as String: []
        ]
        
        var error: Unmanaged<CFError>?
        guard let pK = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else { throw error as! Error }
        self.privateKey = pK
        
        self.publicKey = SecKeyCopyPublicKey(self.privateKey)!
        guard let pkData = SecKeyCopyExternalRepresentation(publicKey, &error) else { throw error as! Error }
        self.publicBase64 = DisQR.Crypto.base64Encode(RSAPublicKeyExporter().toSubjectPublicKeyInfo(pkData as Data))
    }
    
    public func decrypt(data: String) -> Data? {
        let payload = DisQR.Crypto.base64Decode(data)
        var error: Unmanaged<CFError>?
        guard let decrypted = SecKeyCreateDecryptedData(privateKey, SecKeyAlgorithm.rsaEncryptionOAEPSHA256, payload as CFData, &error) else { return nil }
        return decrypted as Data
    }
    
    public static func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
    
    public static func base64Encode(_ data: Data) -> String {
        return data.base64EncodedString(options: [])
    }
    
    public static func base64Decode(_ strBase64: String) -> Data {
        let data = Data(base64Encoded: strBase64, options: [])
        return data!
    }
}

