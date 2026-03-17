//
//  SendingState.swift
//  cs-message-types
//
//  Created by Georgie Ivanov on 17.03.26.
//
import Vapor
import Foundation

public enum SendingState: AsyncResponseEncodable {
    public func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response {
        switch self {
        case .notFound:
            return .init(status: .notFound)
        case .success(let id):
            return .init(status: .ok, body: .init(stringLiteral: id.uuidString))
        case .error(let error):
            return .init(status: .custom(code: 509, reasonPhrase: "Sending error"), body: .init(stringLiteral: error))
        }
    }
    
    case success(UUID)
    case notFound
    case error(String)
}
