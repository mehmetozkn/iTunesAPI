//
//  SearchEndpoint.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

// iTunes Search API, sadece uygulama (software) araması
struct SearchEndpoint: Endpoint {

    let term: String
    let limit: Int

    var baseURL: String { "https://itunes.apple.com" }
    var path: String { "/search" }

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
    }
}
