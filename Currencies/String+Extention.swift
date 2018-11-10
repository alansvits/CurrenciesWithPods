//
//  String+Extention.swift
//  Weather App
//
//  Created by Stas Shetko on 1/10/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import Foundation

extension String {
    
    func getDayFrom() -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: self) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let day = myCalendar.component(.day, from: date)
        return day
    }
    
    func getDate() -> Date? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = formatter.date(from: self) else { return nil }
        return date
        
    }
    
    func getDateFromShort() -> Date? {
        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd"
        formatter.dateFormat = "dd.MM.yyyy"

        guard let date = formatter.date(from: self) else { return nil }
        return date
    }
    
    func getShortStringDate() -> String {
        
        let formatter = DateFormatter()
        let tempDate = self.getDate()!
        formatter.dateStyle = .short
        formatter.timeStyle = .none        
        return formatter.string(from: tempDate)
        
    }
    
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    
}
