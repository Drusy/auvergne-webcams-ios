//
//  DateFormatterCache.swift
//  UPA
//
//  Created by Drusy on 12/05/2016.
//  Copyright © 2016 Openium. All rights reserved.
//

import Foundation

class DateFormatterCache {
    static var shared = DateFormatterCache()
    
    var defaultLocale = Locale(identifier: "fr_FR")
    var formatDateFormatters = [String: DateFormatter]()
    var styleDateFormatters = [NSNumber: DateFormatter]()
    
    func dateFormatter(withFormat format: String, locale: Locale? = nil) -> DateFormatter {
        if let formatter = formatDateFormatters[format] {
            return formatter
        }
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        formatter.locale = locale ?? defaultLocale
        
        formatDateFormatters[format] = formatter
        
        return formatter
    }
    
    func dateFormatter(withStyle style: DateFormatter.Style, locale: Locale? = nil) -> DateFormatter {
        if let formatter = styleDateFormatters[NSNumber(value: style.rawValue)] {
            return formatter
        }
        
        let formatter = DateFormatter()
        
        formatter.dateStyle = style
        formatter.locale = locale ?? defaultLocale
        
        styleDateFormatters[NSNumber(value: style.rawValue)] = formatter
        
        return formatter
        
    }
}
