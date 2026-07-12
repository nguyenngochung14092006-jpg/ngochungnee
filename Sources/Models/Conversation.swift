import Foundation
import SwiftData

/// Một cuộc hội thoại (một contact/số điện thoại)
@Model
final class Conversation {
    var id: UUID
    var contactName: String
    var contactPhone: String
    /// Màu avatar: "gray","green","blue","orange","purple","red","teal"
    var avatarColor: String
    /// Chữ viết tắt hiển thị trong avatar (ví dụ "VA" cho Việt Anh)
    var avatarInitials: String
    var lastMessage: String
    var lastMessageDate: Date
    var isRead: Bool
    var autoReplyEnabled: Bool
    var replyDelay: Double          // giây — độ trễ trước khi tự động phản hồi
    var fallbackReply: String       // Phản hồi mặc định nếu không khớp trigger
    var templateType: TemplateType  // Mẫu SMS (MobiFone / Viettel / None)

    // Thông tin thuê bao dùng cho mẫu TTTB
    var mName: String = ""
    var mDob: String = ""
    var mPhone: String = ""
    var mCccd: String = ""
    var mNgayCap: String = ""
    var mNgayKichHoat: String = ""

    @Relationship(deleteRule: .cascade) var messages: [Message]
    @Relationship(deleteRule: .cascade) var replyRules: [ReplyRule]

    init(
        contactName: String,
        contactPhone: String,
        avatarColor: String = "gray",
        avatarInitials: String = "",
        lastMessage: String = "",
        lastMessageDate: Date = .now,
        isRead: Bool = true,
        autoReplyEnabled: Bool = false,
        replyDelay: Double = 2.0,
        fallbackReply: String = "",
        templateType: TemplateType = .none
    ) {
        self.id = UUID()
        self.contactName = contactName
        self.contactPhone = contactPhone
        self.avatarColor = avatarColor
        self.avatarInitials = avatarInitials
        self.lastMessage = lastMessage
        self.lastMessageDate = lastMessageDate
        self.isRead = isRead
        self.autoReplyEnabled = autoReplyEnabled
        self.replyDelay = replyDelay
        self.fallbackReply = fallbackReply
        self.templateType = templateType
        self.messages = []
        self.replyRules = []
    }
}

enum TemplateType: String, Codable, CaseIterable {
    case none = "Không dùng mẫu"
    case mobifone = "MobiFone"
    case viettel = "Viettel TTTB"
    case shopeepay = "ShopeePay OTP"
    case custom = "Tùy chỉnh"
}
