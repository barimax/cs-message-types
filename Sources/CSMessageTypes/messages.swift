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
    static var urlPath: String { get }
    func send(app: Application, messageCenterHost: String?) async
}

extension Message {
    func send(app: Application, messageCenterHost: String?) async {
        if messageCenterHost != nil {
            do {
                let url: URI = "http://\(messageCenterHost!)/\(Self.urlPath)"
                let response =  try await app.client.post(url, content: self)
                if response.status.code == 509 {
                    app.logger.error(.init(stringLiteral: (try? response.content.decode(String.self, as: .plainText)) ?? "Unknown error"))
                }else if response.status == .ok {
                    app.logger.info("Message sent")
                }else if response.status == .notFound {
                    app.logger.warning("Company not found")
                }
            }catch{
                app.logger.error(.init(stringLiteral: error.localizedDescription))
            }
        }else{
            app.logger.error(.init(stringLiteral: "Missing message center host."))
        }
    }

}

public protocol WebsocketContainerEncodable: Content {
    func toWebsocketContainer() -> WebsocketContainer
}

public enum WebsocketSeverity: String, Codable, Sendable {
    public static let name: String = "WebsocketMessageSeverity"
    case info
    case warning
    case error
    case success
}

public struct WebsocketNotification: Message, WebsocketContainerEncodable {
    public static let urlPath: String = "notification"
    public let userId: UUID
    public let title: String
    public let content: String
    public let severity: WebsocketSeverity
    public let sessionId: String
    public let companyId: UUID?
    
    public init(userId: UUID, title: String, content: String, severity: WebsocketSeverity, sessionId: String, companyId: UUID?) {
        self.userId = userId
        self.title = title
        self.content = content
        self.severity = severity
        self.sessionId = sessionId
        self.companyId = companyId
    }
    
    public func toWebsocketContainer() -> WebsocketContainer {
        .init(notification: self)
    }
}

public struct WebsocketTextMessage: Message, WebsocketContainerEncodable {
    public static let urlPath: String = "message/text"
    public let userId: UUID
    public let title: String
    public let content: String
    public let severity: WebsocketSeverity
    public let sessionId: String
    public let companyId: UUID?
    
    public init(userId: UUID, title: String, content: String, severity: WebsocketSeverity, sessionId: String, companyId: UUID?) {
        self.userId = userId
        self.title = title
        self.content = content
        self.severity = severity
        self.sessionId = sessionId
        self.companyId = companyId
    }
    
    public func toWebsocketContainer() -> WebsocketContainer {
        .init(textMessage: self)
    }
}

public struct WebsocketProgress: Message, WebsocketContainerEncodable {
    public static let urlPath: String = "progress"
    public let userId: UUID
    public let progress: Double
    public let sessionId: String
    public let companyId: UUID?
    
    public init(userId: UUID, progress: Double, sessionId: String, companyId: UUID?) {
        self.userId = userId
        self.progress = progress
        self.sessionId = sessionId
        self.companyId = companyId
    }
    
    public func toWebsocketContainer() -> WebsocketContainer {
        .init(progress: self)
    }
}

public enum WebsocketMessageType: String, Codable, Sendable {
    public static let name: String = "WebsocketMessageType"
    case text
    case object
}

public enum WebsocketMessageStatus: String, Codable, Sendable {
    public static let name: String = "WebsocketMessageStatus"
    case unread
    case read
    case notSent
}

public struct WebsocketContainer: Content {
    public let title: String? // message and notification only
    public let content: String? // message and notification only
    public let severity: WebsocketSeverity
    public let sessionId: String
    public let companyId: UUID?
    public let progress: Double?  // progress only
    public let type: WebsocketMessageType? // message only
    public let createdAt: Date?; // message only
    public let lastUpdatedAt: Date? // message only
    public let status: WebsocketMessageStatus? // message only
    public let decodeAs: String?  // message only
    public let object: String? ; // message only
    
    init(notification: WebsocketNotification) {
        self.title = notification.title
        self.content = notification.content
        self.sessionId = notification.sessionId
        self.severity = notification.severity
        self.companyId = notification.companyId
        self.createdAt = Date.now
        self.lastUpdatedAt = Date.now
        self.progress = nil
        self.type = nil
        self.status = nil
        self.decodeAs = nil
        self.object = nil
    }
    
    init(textMessage: WebsocketTextMessage) {
        self.title = textMessage.title
        self.content = textMessage.content
        self.sessionId = textMessage.sessionId
        self.severity = textMessage.severity
        self.companyId = textMessage.companyId
        self.createdAt = Date.now
        self.lastUpdatedAt = Date.now
        self.progress = nil
        self.type = .text
        self.status = nil
        self.decodeAs = nil
        self.object = nil
    }
    
    init(progress: WebsocketProgress) {
        self.title = nil
        self.content = nil
        self.sessionId = progress.sessionId
        self.severity = .info
        self.companyId = progress.companyId
        self.createdAt = nil
        self.lastUpdatedAt = nil
        self.progress = progress.progress
        self.type = .text
        self.status = nil
        self.decodeAs = nil
        self.object = nil
    }
}
