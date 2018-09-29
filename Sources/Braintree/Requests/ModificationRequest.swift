//
//  ModificationRequest.swift
//  Braintree
//
//  Created by Mihael Isaev on 28/09/2018.
//

import Foundation
import Vapor

public final class ModificationRequest: Content {
    private var amount: Double
    private var numberOfBillingCycles: Int64
    private var parent: ModificationsRequest
    private var quantity: Int64
    private var neverExpires: Bool
    
    //    private enum CodingKeys : String, CodingKey {
    //        case
    //    }
}
