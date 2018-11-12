//
//  RateData.swift
//  Currencies
//
//  Created by Stas Shetko on 2/11/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import Foundation

struct RateData {
    
    let baseCurrency = "UAH"
    
    let currency: String
    let saleRatePB: Double
    let purchaseRatePB: Double
    
    init(currency: String, saleRatePB: Double, purchaseRatePB: Double) {
        self.currency = currency
        self.saleRatePB = saleRatePB
        self.purchaseRatePB = purchaseRatePB
    }
    
}
