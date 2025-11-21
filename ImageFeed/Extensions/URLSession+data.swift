//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 03.11.25.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    @discardableResult
    func getData(for request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            let (data, response) = try await self.data(for: request, delegate: nil)
            guard let http = response as? HTTPURLResponse else {
                print("[URLSession.data]: NetworkError — non-HTTP response for \(request.url?.absoluteString ?? "<nil>")")
                throw NetworkError.urlSessionError
            }
            guard (200...299).contains(http.statusCode) else {
                print("[URLSession.data]: NetworkError — bad status \(http.statusCode) for \(request.url?.absoluteString ?? "<nil>")")
                throw NetworkError.httpStatusCode(http.statusCode)
            }
            return (data, response)
        } catch {
            print("[URLSession.data]: NetworkError — transport \(error.localizedDescription) for \(request.url?.absoluteString ?? "<nil>")")
            throw NetworkError.urlRequestError(error)
        }
    }
}

extension URLSession {
    func getDataOnly(for request: URLRequest) async throws -> Data {
        let (data, _) = try await getData(for: request)
        return data
    }
}

// MARK: - Generic decoding helpers
extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        decoder: JSONDecoder = .snakeCase()
    ) async throws -> T {
        let (data, _) = try await self.getData(for: request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            let payload = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            print("[URLSession.objectTask<\(T.self)>]: DecodingError — \(error.localizedDescription), Данные: \(payload)")
            throw NetworkError.decodingError(error)
        }
    }
}

