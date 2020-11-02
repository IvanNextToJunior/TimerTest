//
//  RecordDurationFormatter.swift
//  TimerTest
//
//  Created by Ivan on 02.11.2020.
//  Copyright © 2020 test. All rights reserved.
//

import Foundation

class RecordDurationFormatter : DateComponentsFormatter {
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        unitsStyle = .positional
        zeroFormattingBehavior = .pad
    }
    
    /// Метод, преобразующий время в нужный формат
    func format(_ seconds: TimeInterval) -> String? {
        
        // Длительность будет отображаться как 1:00:00
        if seconds > 59.59 {
            allowedUnits = [.hour, .minute, .second]
        } else {
            allowedUnits = [.minute, .second]
        }
        
        return string(from: seconds)
    }
}
