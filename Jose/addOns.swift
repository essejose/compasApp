//
//  addOns.swift
//  jose
//
//  Created by jose on 15/10/17.
//  Copyright © 2017 jose. All rights reserved.
//

import UIKit

enum CurrencyType: String {
    case dolar = "en_US"
    case real = "pt_BR"
}

extension Double {
    
    var currency: String {
        return currencyFormatter(value: self, identifier: nil)
    }
    
    
    var addIof: Double {
        let iof = UserDefaults.standard.double(forKey: "iof")
        
        let total = self + (self*iof/100)
        return total
    }
    
    func addImposto(imposto: Double) -> Double {
        let total = self + (self*imposto/100)
        return total
    }
    
    
    var formatDolar: String {
        return currencyFormatter(value: self, identifier: .dolar)
    }
    
    
    
    var formatReal: String {
        return currencyFormatter(value: self, identifier: .real)
        
    }
    
    private func currencyFormatter(value: Double, identifier: CurrencyType?) -> String {
        let formatter = NumberFormatter()
        if identifier != nil {
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: identifier!.rawValue)
        }else {
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: NSNumber(floatLiteral: value))!
    }
}
