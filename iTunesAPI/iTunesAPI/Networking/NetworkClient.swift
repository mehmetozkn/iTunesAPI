//
//  NetworkClient.swift
//  iTunesAPI
//
//  Created by Mehmet Özkan on 9.11.2026.
//

import Foundation

typealias NetworkCompletion<T> = (Result<T, Error>) -> Void

protocol NetworkClientProtocol {
    // İptal edilebilmesi için task döner
    @discardableResult
    func request<T: Decodable>(_ endpoint: Endpoint,
                               completion: @escaping NetworkCompletion<T>) -> URLSessionDataTask?
}

// Tüm JSON istekleri için ortak katman: istek, status kontrolü, decode, main thread'e dönüş
final class NetworkClient {

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    private func makeResult<T: Decodable>(data: Data?,
                                          response: URLResponse?,
                                          error: Error?) -> Result<T, Error> {
        if let error {
            return .failure(error)
        }
        if let httpResponse = response as? HTTPURLResponse,
           !(200...299).contains(httpResponse.statusCode) {
            return .failure(NetworkError.invalidStatusCode(httpResponse.statusCode))
        }
        guard let data else {
            return .failure(NetworkError.emptyData)
        }
        do {
            return .success(try decoder.decode(T.self, from: data))
        } catch {
            return .failure(NetworkError.decoding(error))
        }
    }
}

// MARK: - NetworkClientProtocol
extension NetworkClient: NetworkClientProtocol {

    @discardableResult
    func request<T: Decodable>(_ endpoint: Endpoint,
                               completion: @escaping NetworkCompletion<T>) -> URLSessionDataTask? {
        guard let url = endpoint.url else {
            completion(.failure(NetworkError.invalidURL))
            return nil
        }

        let task = session.dataTask(with: url) { [weak self] data, response, error in
            // İptal edilen istek için kullanıcıya hata gösterilmez
            if let urlError = error as? URLError, urlError.code == .cancelled { return }
            guard let self else { return }

            let result: Result<T, Error> = makeResult(data: data, response: response, error: error)

            // Sonuç UI'a gideceği için main thread'e dönülür
            DispatchQueue.main.async { completion(result) }
        }
        task.resume()
        return task
    }
}
