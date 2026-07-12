import Foundation
import SwiftData

enum MessageStatus: String, Codable {
    case sending, sent, delivered, read, failed
}

enum MessageReaction: String, Codable, CaseIterable {
    case heart, thumbsUp, thumbsDown, haha, exclamation, question

    var symbol: String {
        switch self {
        case .heart: return "heart.fill"
        case .thumbsUp: return "hand.thumbsup.fill"
        case .thumbsDown: return "hand.thumbsdown.fill"
        case .haha: return "face.smiling.fill"
        case .exclamation: return "exclamationmark.2"
        case .question: return "questionmark"
        }
    }
}

/// Một tin nhắn trong cuộc hội thoại
@Model
final class Message {
    var id: UUID
    var content: String
    var isFromMe: Bool      // true = gửi đi (xanh lá), false = nhận về (xám)
    var timestamp: Date
    var isAutoReply: Bool   // true = tự động phản hồi bởi AutoReplyService
    var statusRaw: String = MessageStatus.delivered.rawValue
    var reactionRaw: String?
    var imageData: Data?
    var conversation: Conversation?

    var status: MessageStatus {
        get { MessageStatus(rawValue: statusRaw) ?? .delivered }
        set { statusRaw = newValue.rawValue }
    }

    var reaction: MessageReaction? {
        get { reactionRaw.flatMap { MessageReaction(rawValue: $0) } }
        set { reactionRaw = newValue?.rawValue }
    }

    init(
        content: String,
        isFromMe: Bool,
        timestamp: Date = .now,
        isAutoReply: Bool = false,
        status: MessageStatus = .delivered,
        imageData: Data? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.isFromMe = isFromMe
        self.timestamp = timestamp
        self.isAutoReply = isAutoReply
        self.statusRaw = status.rawValue
        self.imageData = imageData
    }
}
