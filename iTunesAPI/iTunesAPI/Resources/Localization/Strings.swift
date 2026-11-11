//
//  Strings.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

// Localizable.strings anahtarları, case adı = anahtar
enum Strings: String, CaseIterable {

    // MARK: - Search
    case searchTitle
    case searchPlaceholder
    case searchEmptyTermMessage
    case searchNoResultMessage
    case searchErrorMessage

    // MARK: - Preview
    case previewClose

    func localized() -> String {
        NSLocalizedString(rawValue, comment: "")
    }
}
