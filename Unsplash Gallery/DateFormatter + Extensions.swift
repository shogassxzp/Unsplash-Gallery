//
//  DateFormatter + Extensions.swift
//  Unsplash Gallery
//
//  Created by Игнат Рогачевич on 26.02.26.
//

import Foundation

extension String {
    func toReadableDate() -> String? {
        struct Formatter {
            static let isoFormatter = ISO8601DateFormatter()
            static let uiDateFormatter: DateFormatter = {
                let formatter = DateFormatter()
                formatter.dateStyle = .long
                formatter.timeStyle = .none
                formatter.locale = Locale(identifier: "en_US")
                formatter.timeZone = TimeZone(abbreviation: "UTC")
                return formatter
            }()
        }
        guard let date = Formatter.isoFormatter.date(from: self) else { return nil }
        return Formatter.uiDateFormatter.string(from: date)
    }
}
