//
//  Configuration.swift
//  Braintree
//
//  Created by Mihael Isaev on 27/09/2018.
//

import Foundation

public class Configuration {
    private let environment: BraintreeEnvironment
    private let timeout: TimeInterval = 60
    private let connectTimeout: TimeInterval = 60
    //private let proxy: Proxy
    var accessToken: String?
    
    var clientId: String?
    var clientSecret: String?
    
    var merchantId: String?
    var publicKey: String?
    var privateKey: String?
    var gaphToken: String?
    
    public let logger: Logger
    
    public static var version = "1.0"
    public static var grapthQLApiVersion = "2020-10-27"
    public static var apiVersion = "4"
    
    
    
    public init (environment: BraintreeEnvironment, merchantId: String?, publicKey: String?, privateKey: String?){
        self.environment = environment
        self.merchantId = merchantId
        self.privateKey = privateKey
        self.publicKey = publicKey
        if let priK = privateKey, let pubK = publicKey {
            let joinedStrings = "\(pubK):\(priK)"
            let utf8str = joinedStrings.data(using: .utf8)

            self.gaphToken = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        }
        
        self.logger = Logger()
        
    }
    
    public var baseURL: String {
        return environment.baseURL
    }
    
    public func merchantPath() throws -> String {
        guard let merchantId  = merchantId else { throw BraintreeError(.configuration, reason: "merchantId is nil") }
        return "/merchants/" + merchantId
    }
    
    var graphQLURL: String {
        return environment.baseURL
    }
}
