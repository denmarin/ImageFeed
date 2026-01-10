//
//  ImagesListError.swift
//  ImageFeed
//
//  Created by Yury Semenyushkin on 10.01.26.
//

import Foundation

enum ImagesListError: LocalizedError {
    case invalidURL
    case unauthorized
    case nonHTTPResponse
    case badStatus(code: Int, body: String?)
    case transport(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Некорректный адрес запроса."
        case .unauthorized:
            return "Требуется авторизация."
        case .nonHTTPResponse:
            return "Некорректный ответ сервера."
        case .badStatus(let code, _):
            return "Сервер вернул статус \(code)."
        case .transport(let underlying):
            return "Ошибка сети: \(underlying.localizedDescription)"
        }
    }
}
