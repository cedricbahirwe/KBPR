//
//  KBDecoder.swift
//  KahuziBiega
//
//  Created by Cédric Bahirwe on 16/05/2024.
//

import Foundation

class KBDecoder: JSONDecoder {
    //    override var dataDecodingStrategy: JSONDecoder.DataDecodingStrategy
    
    override init() {
        super.init()
        // TODO: Fix Date formatting forever
        self.dateDecodingStrategy = .formatted(LocalDecoder.dateFormatter)
        //        self.dataDecodingStrategy = .
        //        self.dateDecodingStrategy = .iso8601
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensures consistent date parsing regardless of device's locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC timezone
        return dateFormatter
    }()
}
