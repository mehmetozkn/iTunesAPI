//
//  SearchWorker.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

typealias SearchAPIResult = Result<SearchResponse, Error>
typealias SearchAPICompletion = (SearchAPIResult) -> Void

protocol SearchWorkerProtocol {
    func callAsFunction(term: String, completion: @escaping SearchAPICompletion)
    func cancel()
}

final class SearchWorker {

    private let networkClient: NetworkClientProtocol
    private let resultLimit = 10
    private var task: URLSessionDataTask?

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }
}

// MARK: - SearchWorkerProtocol
extension SearchWorker: SearchWorkerProtocol {

    func callAsFunction(term: String, completion: @escaping SearchAPICompletion) {
        // Yeni arama gelince önceki istek iptal edilir
        task?.cancel()
        task = networkClient.request(SearchEndpoint(term: term, limit: resultLimit), completion: completion)
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
