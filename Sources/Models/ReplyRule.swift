import Foundation
import SwiftData

/// Quy tắc tự động phản hồi: khi nhận tin nhắn chứa `trigger` → gửi `reply`
@Model
final class ReplyRule {
    var id: UUID
    var trigger: String     // Từ khóa kích hoạt (không phân biệt hoa/thường)
    var reply: String       // Nội dung tự động gửi lại
    var isEnabled: Bool
    var conversation: Conversation?

    init(trigger: String, reply: String, isEnabled: Bool = true) {
        self.id = UUID()
        self.trigger = trigger
        self.reply = reply
        self.isEnabled = isEnabled
    }
}
