//
//  SKProduct+Additions.swift
//  Reddit
//
//  Created by made2k on 5/1/19.
//  Copyright © 2019 made2k. All rights reserved.
//

import StoreKit

extension SKProduct {

  var localizedPriceDescription: String {
    
    let formatter = NumberFormatter()
    
    formatter.locale = priceLocale
    formatter.numberStyle = .currency
    
    let priceString = formatter.string(from: price)

    return priceString ?? price.floatValue.description
  }
  
}
