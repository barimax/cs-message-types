//
//  center.swift
//  csMessageTypes
//
//  Created by Georgie Ivanov on 15.03.26.
//
import Foundation
import Vapor

public struct MessageCenter: Sendable {
    let userId: UUID
    let messageCenterHost: String?
    let app: Application
    let sessionId: String
    
    public init(userId: UUID, messageCenterHost: String?, app: Application, sessionId: String) {
        self.userId = userId
        self.messageCenterHost = messageCenterHost
        self.app = app
        self.sessionId = sessionId
    }
    
    public func sendNotification(
        title: String,
        content: String,
        severity: WebsocketSeverity = .info,
        progress: Double? = nil
    ) async {
        await WebsocketNotification(
            userId: userId,
            title: title,
            content: content,
            severity: severity,
            sessionId: sessionId,
            progress: progress
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
    
    public func sendTextMessage(
        title: String,
        content: String,
        severity: WebsocketSeverity = .info,
    ) async {
        await WebsocketTextMessage(
            userId: userId,
            title: title,
            content: content,
            severity: severity,
            sessionId: sessionId
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
    public func sendProgress(
        progress: Double
    ) async {
        await WebsocketProgress(
            userId: userId,
            progress: progress,
            sessionId: sessionId
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
}
