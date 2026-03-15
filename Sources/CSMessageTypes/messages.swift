//
//  messages.swift
//  csMessageTypes
//
//  Created by Georgie Ivanov on 15.03.26.
//

//
//  Messages.swift
//  shame
//
//  Created by Georgie Ivanov on 28.02.26.
//
import Foundation
import Vapor

protocol Message: Content {
    static var urlPath: [String] { get }
    func send(app: Application, messageCenterHost: String?) async
}

extension Message {
    func send(app: Application, messageCenterHost: String?) async {
        if messageCenterHost != nil {
            do {
                let urlPath = Self.urlPath.joined(separator: "/")
                let url: URI = "http://\(messageCenterHost!)/\(urlPath)"
                let response =  try await app.client.post(url, content: self)
                if response.status.code == 509 {
                    app.logger.error(.init(stringLiteral: (try? response.content.decode(String.self, as: .plainText)) ?? "Unknown error"))
                }else if response.status == .ok {
                    app.logger.info("Message sent")
                }
            }catch{
                
            }
        }
    }

}

public enum WebsocketSeverity: String, Codable, Sendable {
    static let name: String = "WebsocketMessageSeverity"
    case info
    case warning
    case error
    case success
}

public struct WebsocketNotification: Message {
    public static let urlPath: [String] = ["notification"]
    public let userId: UUID
    public let title: String
    public let content: String
    public let severity: WebsocketSeverity
    public let sessionId: String
    
    public init(userId: UUID, title: String, content: String, severity: WebsocketSeverity, sessionId: String) {
        self.userId = userId
        self.title = title
        self.content = content
        self.severity = severity
        self.sessionId = sessionId
    }
}

public struct WebsocketTextMessage: Message {
    public static let urlPath: [String] = ["message", "text"]
    public let userId: UUID
    public let title: String
    public let content: String
    public let severity: WebsocketSeverity
    public let sessionId: String
    
    public init(userId: UUID, title: String, content: String, severity: WebsocketSeverity, sessionId: String) {
        self.userId = userId
        self.title = title
        self.content = content
        self.severity = severity
        self.sessionId = sessionId
    }
}

public struct WebsocketProgress: Message {
    public static let urlPath: [String] = ["progress"]
    public let userId: UUID
    public let progress: Double
    public let sessionId: String
    
    public init(userId: UUID, progress: Double, sessionId: String) {
        self.userId = userId
        self.progress = progress
        self.sessionId = sessionId
    }
}
