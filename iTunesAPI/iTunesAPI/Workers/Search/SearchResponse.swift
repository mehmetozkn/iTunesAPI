//
//  SearchResponse.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

// iTunes Search API cevabı (sadece kullanılan alanlar)
struct SearchResponse: Decodable {
    let results: [AppResultResponse]
}

struct AppResultResponse: Decodable {
    let trackName: String?
    let screenshotUrls: [String]?
}

// MARK: - Mapping
extension SearchResponse {
    // Tüm uygulamaların screenshot'larını tek listeye düzleştirir
    func asScreenshotURLs() -> [URL] {
        results
            .flatMap { $0.screenshotUrls ?? [] }
            .compactMap { URL(string: $0) }
    }
}
