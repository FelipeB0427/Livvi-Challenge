//
//  CryptoManager.swift
//  LivviApp
//
//  Created by Felipe on 06/04/26.
//

import Foundation
import CryptoKit

enum CryptoError: Error {
    case invalidBase64
    case invalidServerKey
    case decryptionFailed
}

protocol CryptoManagerProtocol {
    var publicKeyBase64: String { get }
    func decryptMessage(encryptedPayloadBase64: String, serverPublicKeyBase64: String) throws -> Data
}

class CryptoManager: CryptoManagerProtocol {
    private let privateKey = P256.KeyAgreement.PrivateKey()
    
    var publicKeyBase64: String {
        return privateKey.publicKey.rawRepresentation.base64EncodedString()
    }
    
    func decryptMessage(encryptedPayloadBase64: String, serverPublicKeyBase64: String) throws -> Data {
        guard let serverPublicKeyData = Data(base64Encoded: serverPublicKeyBase64),
              let encryptedPayloadData = Data(base64Encoded: encryptedPayloadBase64) else {
            throw CryptoError.invalidBase64
        }
        
        guard let serverPublicKey = try? P256.KeyAgreement.PublicKey(rawRepresentation: serverPublicKeyData) else {
            throw CryptoError.invalidServerKey
        }
        
        let sharedSecret = try privateKey.sharedSecretFromKeyAgreement(with: serverPublicKey)
        
        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: Data(),
            sharedInfo: Data(),
            outputByteCount: 32
        )
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedPayloadData)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            return decryptedData
        } catch {
            print("🚨 Fail on AES-GCM: \(error)")
            throw CryptoError.decryptionFailed
        }
    }
}
