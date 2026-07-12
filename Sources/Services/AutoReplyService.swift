import Foundation
import SwiftData

/// AutoReplyService — quyết định phản hồi tự động khi người dùng gửi tin.
///
/// Quy tắc (giống app gốc): "Khi bạn gửi một tin CÓ CHỨA từ khóa, người nhận
/// sẽ tự trả lời bằng nội dung này. Để trống từ khóa nếu muốn trả lời cho mọi tin."
/// - Khớp  → trả về nội dung sinh từ mẫu (MessageTemplate).
/// - Không khớp / tắt tự động → `nil` (tin hiển thị "Chưa gửi được").
final class AutoReplyService {

    static let shared = AutoReplyService()
    private init() {}

    func reply(for text: String, in conversation: Conversation) -> String? {
        guard conversation.autoReplyEnabled else { return nil }

        let msg = text.lowercased()
        let key = conversation.trigger.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Từ khóa rỗng = khớp mọi tin; ngược lại tin phải CHỨA từ khóa
        let matched = key.isEmpty || msg.contains(key)
        guard matched else {
            // Vẫn hỗ trợ các quy tắc cũ (replyRules) nếu có
            for rule in conversation.replyRules where rule.isEnabled {
                let t = rule.trigger.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if !t.isEmpty && msg.contains(t) { return rule.reply }
            }
            return nil
        }

        let rendered = MessageTemplate.render(for: conversation)
        return rendered.isEmpty ? nil : rendered
    }
}
