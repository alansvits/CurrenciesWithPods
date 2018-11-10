//
//  NBRateData.swift
//  Currencies
//
//  Created by Stas Shetko on 2/11/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import Foundation

struct NBRateData {
    
    let baseCurrency = "UAH"
    
    let currency: String
    let currencyName: String
    let saleRate: Double
    
    init(currency: String, currencyName: Double, saleRate: Double) {
        self.currency = currency
        self.currencyName = currencyName
        self.saleRate = saleRate
    }
    
}
