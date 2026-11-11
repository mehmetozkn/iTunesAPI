//
//  NetworkFakes.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation
@testable import iTunesAPI

// Ağa çıkmadan verilen sonucu döner, gelen endpoint'i kaydeder
final class FakeNetworkClient: NetworkClientProtocol {
    var response: Any?
    var error: Error?
    private(set) var requestedEndpoints: [Endpoint] = []

    func request<T: Decodable>(_ endpoint: Endpoint,
                               completion: @escaping NetworkCompletion<T>) -> URLSessionDataTask? {
        requestedEndpoints.append(endpoint)
        if let error {
            completion(.failure(error))
        } else if let response = response as? T {
            completion(.success(response))
        }
        return nil
    }
}

// URLSession isteklerini yakalayıp sahte cevap döner (gerçek ağa çıkılmaz)
final class StubURLProtocol: URLProtocol {

    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
