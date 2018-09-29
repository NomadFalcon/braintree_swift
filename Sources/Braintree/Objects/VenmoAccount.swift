//
//  VenmoAccount.swift
//  Braintree
//
//  Created by Mihael Isaev on 28/09/2018.
//

import Foundation

public class VenmoAccount: PaymentMethod {
    public var token: String
    public var username: String
    public var venmoUserId: String
    public var sourceDescription: String
    public var imageUrl: String
    public var createdAt: Date?
    public var updatedAt: Date?
    public var subscriptions: [Subscription]
    public var customerId: String
    public var isDefault: Bool?
    
//    private enum CodingKeys : String, CodingKey {
//        case
//    }
}
