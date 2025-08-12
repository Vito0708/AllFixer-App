//
//  FAQEntry.swift
//  AllFixerApp
//
//  Created by Vito Brebric on 21/04/2025.
//

import Foundation

struct FAQEntry: Identifiable {
    let id = UUID()
    let question: String
    let answer: String
}
