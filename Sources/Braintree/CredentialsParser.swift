//
//  CredentialsParser.swift
//  Braintree
//
//  Created by Mihael Isaev on 28/09/2018.
//

import Foundation

class CredentialsParser {
    public var environment: BraintreeEnvironment
    public var merchantId: String?
    public var publicKey: String?
    public var privateKey: String?
    public var gaphToken: String?
   
    
    public init (environment: BraintreeEnvironment, merchantId: String?, publicKey: String?, privateKey: String?){
        self.environment = environment
        self.merchantId = merchantId
        self.privateKey = privateKey
        self.publicKey = publicKey
        if let priK = privateKey, let pubK = publicKey {
            self.gaphToken = createGraphAPIToken(publicKey: pubK,privateKey: priK)
        }
        
    }
    private func createGraphAPIToken(publicKey:String, privateKey:String)->String?{
        let joinedStrings = "\(publicKey):\(privateKey)"
        let utf8str = joinedStrings.data(using: .utf8)

        return utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        
    }
}
