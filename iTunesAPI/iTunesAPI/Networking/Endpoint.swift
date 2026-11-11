//
//  Endpoint.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {

    var url: URL? {
        guard var components = URLComponents(string: baseURL + path) else { return nil }
        components.queryItems = queryItems
        let encodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        components.percentEncodedQuery = encodedQuery
        return components.url
    }
}
