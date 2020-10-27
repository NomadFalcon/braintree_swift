//
//  Braintree.swift
//  Braintree
//
//  Created by Mihael Isaev on 29/09/2018.
//

import Foundation
import Vapor


public class Braintree{
    var configuration: Configuration
    
    public init(environment: BraintreeEnvironment, merchantId: String, publicKey: String, privateKey: String) throws {
        self.configuration =  Configuration(environment: environment,
                                               merchantId: merchantId,
                                               publicKey: publicKey,
                                               privateKey: privateKey)
    }
    
    public func gateway() -> BraintreeGateway {
        return BraintreeGateway(configuration: configuration)
    }
}



extension Application {
    public struct Braintree {
        
        public typealias BraintreeFactory = (Application) -> BraintreeProvider
        
        public struct Provider {
            public static var live: Self {
                .init {
                    $0.braintree.use { app in
                        guard let config = app.braintree.configuration else {
                            fatalError("braintree not configured, use: app.mailgun.configuration = .init()")
                        }
                        guard let env = app.braintree.environment else {
                            fatalError("braintree not configured, use: app.mailgun.environment = .init()")
                        }
                        
                        
                        return BraintreeClient(config: config, eventLoop: app.eventLoopGroup.next(), client: app.client, enviroment: env)
                        
                    }
                }
            }
            
            public let run: ((Application) -> Void)
            
            public init(_ run: @escaping ((Application) -> Void)) {
                self.run = run
            }
        }
        
        let app: Application
        
        private final class Storage {
            var environment: BraintreeEnvironment?
            var configuration: Configuration?
            var makeClient: BraintreeFactory?
            
            init() {}
        }
        
        private struct Key: StorageKey {
            typealias Value = Storage
        }
        
        private var storage: Storage {
            if app.storage[Key.self] == nil {
                self.initialize()
            }
            
            return app.storage[Key.self]!
        }
        
        public func use(_ make: @escaping BraintreeFactory) {
            storage.makeClient = make
        }
        
        public func use(_ provider: Application.Braintree.Provider) {
            provider.run(app)
        }
        
        private func initialize() {
            app.storage[Key.self] = .init()
        }
        
        public var environment: BraintreeEnvironment? {
            get { storage.environment }
            nonmutating set { storage.environment = newValue }
        }
        
        public var configuration: Configuration? {
            get { storage.configuration }
            nonmutating set { storage.configuration = newValue }
        }
        
        public func configurator(_ configuration: Configuration? = nil) -> BraintreeProvider {
                   guard let makeClient = storage.makeClient else {
                       fatalError("Braintree not configured, use: app.braintree.use(.real)")
                   }
                   
                   return makeClient(app)
        }
        
       
    }
    
    public var braintree: Braintree {
        .init(app: self)
    }
    
    public func braintree(_ config: Configuration? = nil) -> BraintreeProvider {
        self.braintree.configurator(config)
    }
}



public protocol BraintreeProvider {
    func makePayment(_ noonce: String, eventLoop: EventLoop) -> EventLoopFuture<ClientResponse>
    
    func delegating(to eventLoop: EventLoop) -> BraintreeProvider
}


public struct BraintreeClient: BraintreeProvider {
    public func makePayment(_ noonce: String, eventLoop: EventLoop) -> EventLoopFuture<ClientResponse> {
        
        return eventLoop.makeSucceededFuture(ClientResponse(status: .accepted, headers: [:], body: nil))
    }
    
    let eventLoop: EventLoop
    let config: Configuration
    let enviroment: BraintreeEnvironment
    let client: Client
    
    // MARK: Initialization
    public init(
        config: Configuration,
        eventLoop: EventLoop,
        client: Client,
        enviroment: BraintreeEnvironment
    ) {
        self.config = config
        self.eventLoop = eventLoop
        self.client = client
        self.enviroment = enviroment
    }
    
    public func delegating(to eventLoop: EventLoop) -> BraintreeProvider {
       return  BraintreeClient(config: config, eventLoop: eventLoop, client: client, enviroment: enviroment)
      }
}
