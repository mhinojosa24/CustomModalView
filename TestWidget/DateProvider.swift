//
//  DateProvider.swift
//  Custom Modal View
//
//  Created by Maximo Hinojosa on 11/1/20.
//

import Foundation

struct MyDateProvider {
    
    static func getRandomString() -> String {
        let strings: [String] = [
            "One",
            "Two",
            "Three",
            "Four",
            "Five",
            "Six",
            "Seven",
            "Eight",
            "Nine",
            "Ten"
        ]
        return strings.randomElement() ?? "Zero"
    }
}
