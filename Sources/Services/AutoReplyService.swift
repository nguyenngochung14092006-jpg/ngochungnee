import Foundation
import SwiftData

/// AutoReplyService — khớp từ khóa và gửi phản hồi tự động sau delay
final class AutoReplyService {

    static let shared = AutoReplyService()
    private init() {}

    // MARK: - Public API

    /// Xử lý tin nhắn đến. Nếu khớp rule hoặc fallback → trả về nội dung reply sau `replyDelay` giây.
    /// - Parameters:
    ///   - incomingText: Nội dung tin nhắn nhận được (từ "người dùng" — tin nhắn màu xanh lá)
    ///   - conversation: Cuộc hội thoại hiện tại
    ///   - onReply: Callback trả về nội dung phản hồi (chạy trên Main thread)
    func process(
        incomingText: String,
        conversation: Conversation,
        onReply: @escaping (String) -> Void
    ) {
        guard conversation.autoReplyEnabled else { return }

        let replyText = findReply(for: incomingText, in: conversation)
        guard let replyText else { return }

        let delay = conversation.replyDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            onReply(replyText)
        }
    }

    // MARK: - Private

    /// Ưu tiên: keyword rules → template rules → fallback
    private func findReply(for text: String, in conversation: Conversation) -> String? {
        let normalized = text.lowercased().trimmingCharacters(in: .whitespaces)

        // 1. Keyword rules (từ SwiftData)
        let enabledRules = conversation.replyRules.filter { $0.isEnabled }
        for rule in enabledRules {
            if normalized.contains(rule.trigger.lowercased()) {
                return rule.reply
            }
        }

        // 2. Template rules theo loại
        if let templateReply = templateReply(for: normalized, type: conversation.templateType) {
            return templateReply
        }

        // 3. Fallback reply
        if !conversation.fallbackReply.isEmpty {
            return conversation.fallbackReply
        }

        return nil
    }

    /// Các phản hồi cứng theo template type (giống SampleData trong IPA gốc)
    private func templateReply(for text: String, type: TemplateType) -> String? {
        switch type {
        case .viettel:
            return viettelReply(for: text)
        case .mobifone:
            return mobifoneReply(for: text)
        case .shopeepay:
            return shopeepayReply(for: text)
        case .none, .custom:
            return nil
        }
    }

    // MARK: Templates — Viettel TTTB
    private func viettelReply(for text: String) -> String? {
        // "TTTB" → thông tin thuê bao
        if text.contains("tttb") || text.contains("thong tin") || text.contains("tra cuu") {
            return """
Quy khach vui long truy cap ung dung VNeID de kiem tra va xac nhan su dung so dien thoai. \
Huong dan chi tiet vui long xem tai https://www.mobifone.vn/tin-tuc/chi-tiet/huong-dan-xac-nhan-tich-hop-so-dien-thoai-tren-vneid-25501. \
Tran trong cam on Quy khach.
"""
        }
        if text.contains("huy") || text.contains("cancel") {
            return "Da huy dang ky dich vu. Tran trong cam on Quy khach da su dung dich vu Viettel."
        }
        if text.contains("dk") || text.contains("dang ky") {
            return "Quy khach da dang ky thanh cong dich vu. Cam on Quy khach!"
        }
        return nil
    }

    // MARK: Templates — MobiFone
    private func mobifoneReply(for text: String) -> String? {
        if text.contains("gia han") || text.contains("goi cuoc") || text.contains("nap tien") {
            return "MobiFone xin kinh bao: Goi cuoc PT90 cua Quy khach se het han vao ngay 11/07/2026. De gia han vui long soan GH gui 9084."
        }
        if text.contains("khuyen mai") || text.contains("uu dai") {
            return "[TB] World Cup 2026 bung no! MobiFone tang ban code WC26R32 giam 50% goi data. Han dung 30/07/2026."
        }
        if text.contains("y") && text.len == 1 {
            return "Tai khoan cua QK sap het! Dung lo, soan Y gui 1899 de nhan ngay 50.000d su dung nhu tien mat tai tat ca cac diem giao dich MobiFone."
        }
        if text.contains("otp") || text.contains("ma xac nhan") {
            let otp = String(Int.random(in: 100000...999999))
            return "Ma OTP MobiFone cua Quy khach la: \(otp). Ma co hieu luc trong 5 phut. Khong cung cap cho bat ky ai."
        }
        return nil
    }

    // MARK: Templates — ShopeePay
    private func shopeepayReply(for text: String) -> String? {
        if text.contains("otp") || text.contains("xac nhan") {
            let otp = String(Int.random(in: 100000...999999))
            return "ShopeePay OTP: \(otp). Ma co hieu luc trong 5 phut. Vui long khong chia se ma nay voi bat ky ai."
        }
        if text.contains("thanh toan") || text.contains("lich su") {
            return "Thanh toan hoa don SPayLater voi so tien 195,899 VND truoc ngay 15/07/2026 de tranh phat cham tra. Chi tiet xem tai ung dung Shopee."
        }
        return nil
    }
}

// MARK: - Helper
private extension String {
    var len: Int { self.count }
}
