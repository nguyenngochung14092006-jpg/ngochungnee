import Foundation
import SwiftData

/// Một tin nhắn trong cuộc hội thoại
@Model
final class Message {
    var id: UUID
    var content: String
    var isFromMe: Bool      // true = gửi đi (xanh lá), false = nhận về (xám)
    var timestamp: Date
    var isAutoReply: Bool   // true = tự động phản hồi bởi AutoReplyService
    var conversation: Conversation?

    init(
        content: String,
        isFromMe: Bool,
        timestamp: Date = .now,
        isAutoReply: Bool = false
    ) {
        self.id = UUID()
        self.content = content
        self.isFromMe = isFromMe
        self.timestamp = timestamp
        self.isAutoReply = isAutoReply
    }
}
