//
//  SKProductProvider.swift
//  ContactJournal
//
//  Created by Stefan Trauth on 25.10.20.
//

import Foundation
import Combine
import StoreKit

class SKProductProvider: NSObject, ObservableObject, SKProductsRequestDelegate {
    @Published var products = [SKProduct]()
    
    private var request: SKProductsRequest!
    
    override init() {
        super.init()
        let productIdentifiers = Set(["de.stefantrauth.ContactJournal.donation1"])
        request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
}
