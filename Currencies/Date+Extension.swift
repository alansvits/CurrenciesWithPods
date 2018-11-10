//
//  Date+Extension.swift
//  Weather App
//
//  Created by Stas Shetko on 2/10/18.
//  Copyright © 2018 Stas Shetko. All rights reserved.
//

import Foundation

extension Date {
    
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    
    func day() -> Int? {
        return Calendar.current.dateComponents([.day], from: self).day
    }
    
    func isThisDateToday(_ date: Date) -> Bool {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let stringTodayDate = formatter.string(from: self)
        let comperingDate = formatter.string(from: date)
        if stringTodayDate == comperingDate {
            return true
        } else {
            return false
        }
        
    }
    
}
