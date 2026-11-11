//
//  NetworkError.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidStatusCode(Int)
    case emptyData
    case decoding(Error)
}
