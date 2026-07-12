import Foundation
import SwiftData

/// AutoReplyService — khớp từ khóa và trả về phản hồi tự động.
///
/// Quy tắc khớp: tin nhắn gửi đi được so khớp CHÍNH XÁC (không phân biệt hoa/thường,
/// bỏ khoảng trắng đầu/cuối) với `trigger` của các `ReplyRule` đang bật.
/// - Khớp  → trả về `reply` (tin sẽ được "gửi" thành công + tự động trả lời).
/// - Không khớp → trả về `nil` (tin hiển thị "Chưa gửi được" giống app gốc).
final class AutoReplyService {

    static let shared = AutoReplyService()
    private init() {}

    /// Trả về nội dung phản hồi nếu khớp, ngược lại `nil`.
    func reply(for text: String, in conversation: Conversation) -> String? {
        guard conversation.autoReplyEnabled else { return nil }

        let normalized = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // 1. Khớp chính xác quy tắc từ khóa
        for rule in conversation.replyRules where rule.isEnabled {
            if normalized == rule.trigger.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
                return rule.reply
            }
        }

        // 2. Phản hồi mặc định (nếu có cấu hình)
        if !conversation.fallbackReply.isEmpty {
            return conversation.fallbackReply
        }

        return nil
    }
}
