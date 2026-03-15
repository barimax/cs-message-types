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

public protocol Message: Content {
    static var urlPath: String { get }
    func send(app: Application, messageCenterHost: String?) async
}

public extension Message {
    func send(app: Application, messageCenterHost: String?) async {
        if messageCenterHost != nil {
            do {
                let url: URI = "http://\(messageCenterHost!)/\(Self.urlPath)"
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
    public static let urlPath: String = "notification"
    let userId: UUID
    let title: String
    let content: String
    let severity: WebsocketSeverity
    let progress: Double?
    
    public init(userId: UUID, title: String, content: String, severity: WebsocketSeverity, progress: Double?) {
        self.userId = userId
        self.title = title
        self.content = content
        self.severity = severity
        self.progress = progress
    }
}

public struct WebsocketTextMessage: Message {
    public static let urlPath: String = "message/text"
    let userId: UUID
    let title: String
    let content: String
    let severity: WebsocketSeverity
}

public struct WebsocketProgress: Message {
    public static let urlPath: String = "message/text"
    let userId: UUID
    let progress: Double
    let sessionId: String
}
