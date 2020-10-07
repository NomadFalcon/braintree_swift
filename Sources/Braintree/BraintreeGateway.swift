//
//  BraintreeGateway.swift
//  Braintree
//
//  Created by Mihael Isaev on 27/09/2018.
//

import Foundation
import Vapor

public class BraintreeGateway {
    var configuration: Configuration
    //private var graphQLClient: GraphQLClient
    var http: Http
    
    /// Instantiates a BraintreeGateway. Use the values provided by Braintree
    init( configuration: Configuration) {
        self.configuration = configuration
        self.http = Http(configuration: configuration)
    }
    
   
    
    public var dispute: DisputeGateway {
        return DisputeGateway(http: http, configuration: configuration)
    }
    
    public var paymentMethod: PaymentMethodGateway {
        return PaymentMethodGateway(http: http, configuration: configuration)
    }
    
    public var paymentMethodNonce: PaymentMethodNonceGateway {
        return PaymentMethodNonceGateway(http: http, configuration: configuration)
    }
    
    public var webhookNotification: WebhookNotificationGateway {
        return WebhookNotificationGateway(http: http, configuration: configuration)
    }
    
    public var webhookTesting: WebhookTestingGateway {
        return WebhookTestingGateway(http: http, configuration: configuration)
    }
    
   
}
