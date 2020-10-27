//
//  BraintreeEnvironment.swift
//  Braintree
//
//  Created by Mihael Isaev on 27/09/2018.
//

import Foundation

public enum BraintreeEnvironment: String, Codable {
    
    /// For production.
    case production
    
    /// For merchants to use during their development and testing.
    case sandbox
    
    public var baseURL: String {
        switch self {
        case .production: return "https://payments.sandbox.braintree-api.com/graphql"
        case .sandbox: return "https://payments.braintree-api.com/graphql"
        }
    }
    
    public func developmentBaseURL() -> String {
        return ProcessInfo.processInfo.environment["GATEWAY_BASE_URL"] ?? "http://localhost"
    }
    
    public func developmentPort() -> String {
        return ProcessInfo.processInfo.environment["GATEWAY_PORT"] ?? "3000"
    }
    
    public func developmentGraphQLURL() -> String {
        return ProcessInfo.processInfo.environment["GRAPHQL_URL"] ?? "https://atmosphere.bt.local:8080/graphql"
    }
    
    public static func parseEnvironment(environment: String) throws -> BraintreeEnvironment {
        guard let env = BraintreeEnvironment(rawValue: environment) else {
            throw BraintreeError(.configuration, reason: "Unknown environment: \(environment)")
        }
        return env
    }
}
