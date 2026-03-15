//
//  center.swift
//  csMessageTypes
//
//  Created by Georgie Ivanov on 15.03.26.
//
import Foundation
import Vapor

struct MessageCenter {
    let userId: UUID
    let messageCenterHost: String?
    let app: Application
    
    func sendNotification(
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
            progress: progress
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
    
    func sendTextMessage(
        title: String,
        content: String,
        severity: WebsocketSeverity = .info,
    ) async {
        await WebsocketTextMessage(
            userId: userId,
            title: title,
            content: content,
            severity: severity
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
    func sendProgress(
        progress: Double,
        sessionId: String,
    ) async {
        await WebsocketProgress(
            userId: userId,
            progress: progress,
            sessionId: sessionId
        ).send(app: app, messageCenterHost: messageCenterHost)
    }
}
