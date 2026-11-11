//
//  NetworkClientTests.swift
//  iTunesAPITests
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation
import Testing
@testable import iTunesAPI

@Suite("NetworkClient", .serialized)
struct NetworkClientTests {

    private let sut = NetworkClient(session: StubURLProtocol.makeSession())
    private let endpoint = SearchEndpoint(term: "instagram", limit: 10)

    private func stub(statusCode: Int, body: String) {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: statusCode,
                                           httpVersion: nil, headerFields: nil)!
            return (response, Data(body.utf8))
        }
    }

    private func performRequest() async -> Result<SearchResponse, Error> {
        await withCheckedContinuation { continuation in
            sut.request(endpoint) { (result: Result<SearchResponse, Error>) in
                continuation.resume(returning: result)
            }
        }
    }

    @Test("200 ve geçerli JSON gelince model decode edilir")
    func successDecodesModel() async throws {
        // Given
        stub(statusCode: 200, body: #"{ "results": [ { "trackName": "App", "screenshotUrls": [] } ] }"#)

        // When
        let response = try await performRequest().get()

        // Then
        #expect(response.results.first?.trackName == "App")
    }

    @Test("200 dışı status code hata döner")
    func invalidStatusCodeFails() async {
        // Given
        stub(statusCode: 403, body: "")

        // When
        let result = await performRequest()

        // Then
        guard case .failure(NetworkError.invalidStatusCode(let code)) = result else {
            Issue.record("invalidStatusCode bekleniyordu: \(result)")
            return
        }
        #expect(code == 403)
    }

    @Test("Bozuk JSON decoding hatası döner")
    func invalidJSONFails() async {
        // Given
        stub(statusCode: 200, body: "bozuk json")

        // When
        let result = await performRequest()

        // Then
        guard case .failure(NetworkError.decoding) = result else {
            Issue.record("decoding hatası bekleniyordu: \(result)")
            return
        }
    }

    @Test("Bağlantı hatası olduğu gibi iletilir")
    func connectionErrorFails() async {
        // Given
        StubURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }

        // When
        let result = await performRequest()

        // Then
        guard case .failure(let error as URLError) = result else {
            Issue.record("URLError bekleniyordu: \(result)")
            return
        }
        #expect(error.code == .notConnectedToInternet)
    }
}
