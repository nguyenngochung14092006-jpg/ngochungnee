import Foundation
import SwiftData

/// Dữ liệu mẫu khởi tạo giống app IPA gốc (seedPersonal + seedServiceSMS)
enum SampleData {

    static func seed(context: ModelContext) {
        seedServiceSMS(context: context)
        seedPersonal(context: context)
    }

    // MARK: - Service SMS (giống IPA gốc)

    static func seedServiceSMS(context: ModelContext) {

        // ── 1. VinaPhone ──────────────────────────────────────────────────
        let vinaPhone = Conversation(
            contactName: "VinaPhone",
            contactPhone: "VinaPhone",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "(TB) Sinh nhật Vina - Ai cũng có quà! Khi thực hiện Đăng ký/Gia hạn/Nâng cấp g...",
            lastMessageDate: daysAgo(1),
            isRead: true,
            autoReplyEnabled: false,
            replyDelay: 2.0,
            fallbackReply: "",
            templateType: .none
        )
        let vinaMsg1 = Message(
            content: "(TB) Sinh nhật Vina - Ai cũng có quà! Khi thực hiện Đăng ký/Gia hạn/Nâng cấp gói cước từ 12/07-13/07/2026, KH nhận ngay 1GB data bonus, không giới hạn đăng ký. Chi tiết: 18001091.",
            isFromMe: false,
            timestamp: daysAgo(1)
        )
        insert(conversation: vinaPhone, messages: [vinaMsg1], context: context)

        // ── 2. VNSKY ─────────────────────────────────────────────────────
        let vnsky = Conversation(
            contactName: "VNSKY",
            contactPhone: "VNSKY",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "(QC) SKY10 GIẢM 50%. Da re nay con re hon! Dang ky SKY10 (100...",
            lastMessageDate: daysAgo(1),
            isRead: false,  // unread
            autoReplyEnabled: false,
            templateType: .none
        )
        let vnskyMsg = Message(
            content: "(QC) SKY10 GIẢM 50%. Da re nay con re hon! Dang ky SKY10 (100GB/thang, gia 10.000d/30 ngay) ngay bay gio! Soan SKY10 gui 1558 hoac goi 1800 1558.",
            isFromMe: false,
            timestamp: daysAgo(1)
        )
        insert(conversation: vnsky, messages: [vnskyMsg], context: context)

        // ── 3. 888 ───────────────────────────────────────────────────────
        let c888 = Conversation(
            contactName: "888",
            contactPhone: "888",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "(TB) NHANH TAY so huu 01 License su dung khong gioi han noi dung Premium tre...",
            lastMessageDate: daysAgo(3),
            isRead: false,  // unread
            autoReplyEnabled: false,
            templateType: .none
        )
        let c888Msg = Message(
            content: "(TB) NHANH TAY so huu 01 License su dung khong gioi han noi dung Premium tren ung dung ZingMP3 chi voi 59.000d/ 365 ngay! Dang ky tai: bit.ly/3YgM3mI",
            isFromMe: false,
            timestamp: daysAgo(3)
        )
        insert(conversation: c888, messages: [c888Msg], context: context)

        // ── 4. 1414 — Viettel TTTB (cuộc hội thoại chính) ──────────────
        let c1414 = Conversation(
            contactName: "1414",
            contactPhone: "1414",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "TB tra truoc ca nhan. Ho ten: NGUYEN NGOC HUNG. Danh sach so thue bao dan...",
            lastMessageDate: daysAgo(3),
            isRead: true,
            autoReplyEnabled: true,
            replyDelay: 2.5,
            fallbackReply: "",
            templateType: .viettel
        )
        // Thêm rule mặc định Viettel TTTB
        let tttbRule = ReplyRule(
            trigger: "TTTB",
            reply: """
Quy khach vui long truy cap ung dung VNeID de kiem tra va xac nhan su dung so dien thoai. \
Huong dan chi tiet vui long xem tai https://www.mobifone.vn/tin-tuc/chi-tiet/huong-dan-xac-nhan-tich-hop-so-dien-thoai-tren-vneid-25501. \
Tran trong cam on Quy khach.
"""
        )
        tttbRule.conversation = c1414
        c1414.replyRules.append(tttbRule)

        let msg1414_1 = Message(
            content: "TB tra truoc ca nhan. Ho ten: NGUYEN NGOC HUNG. Danh sach so thue bao dang ky: 0776816907. Neu thong tin quy khach khong dung, Quy khach vui long truy cap ung dung VNSKY hoac lien he tong dai 19005222 (Cuoc phi 1000d/phut) de dang ky lai thong tin theo quy dinh. Cam on Quy khach.",
            isFromMe: false,
            timestamp: hoursAgo(5)
        )
        let msg1414_2 = Message(
            content: "TTTB",
            isFromMe: true,
            timestamp: hoursAgo(4),
            isAutoReply: false
        )
        let msg1414_3 = Message(
            content: "Quy khach vui long truy cap ung dung VNeID de kiem tra va xac nhan su dung so dien thoai. Huong dan chi tiet vui long xem tai https://www.mobifone.vn/tin-tuc/chi-tiet/huong-dan-xac-nhan-tich-hop-so-dien-thoai-tren-vneid-25501. Tran trong cam on Quy khach.",
            isFromMe: false,
            timestamp: hoursAgo(4)
        )
        let msg1414_4 = Message(
            content: "TTTB 030206013094",
            isFromMe: true,
            timestamp: hoursAgo(3),
            isAutoReply: false,
            status: .failed
        )
        insert(conversation: c1414, messages: [msg1414_1, msg1414_2, msg1414_3, msg1414_4], context: context)

        // ── 5. Google ─────────────────────────────────────────────────────
        let google = Conversation(
            contactName: "Google",
            contactPhone: "Google",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "Google đã chặn một người có mật khẩu cho nnhung.24108100084@sv.... đăng nh...",
            lastMessageDate: daysAgo(3),
            isRead: true,
            autoReplyEnabled: false,
            templateType: .none
        )
        let googleMsg = Message(
            content: "Google đã chặn một người có mật khẩu cho nnhung.24108100084@sv.ctuet.edu.vn đăng nhập vào thiết bị iPhone. Bạn có thể xem lại hoạt động này tại myaccount.google.com/notifications.",
            isFromMe: false,
            timestamp: daysAgo(3)
        )
        insert(conversation: google, messages: [googleMsg], context: context)

        // ── 6. 9345 ───────────────────────────────────────────────────────
        let c9345 = Conversation(
            contactName: "9345",
            contactPhone: "9345",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "(TB) Da dang ky goi cuoc POT10/cuoc phi 10.000d...",
            lastMessageDate: daysAgo(3),
            isRead: false,
            autoReplyEnabled: false,
            templateType: .none
        )
        let c9345Msg = Message(
            content: "(TB) Da dang ky goi cuoc POT10/cuoc phi 10.000d. Goi cuoc cung cap 10GB data toc do cao va uu dai Voice, SMS tot hon. Het han 30 ngay.",
            isFromMe: false,
            timestamp: daysAgo(3)
        )
        insert(conversation: c9345, messages: [c9345Msg], context: context)

        // ── 7. ShopeePay ─────────────────────────────────────────────────
        let shopee = Conversation(
            contactName: "ShopeePay",
            contactPhone: "ShopeePay",
            avatarColor: "orange",
            avatarInitials: "",
            lastMessage: "ShopeePay OTP: 886267. Ma co hieu luc trong 5 phut...",
            lastMessageDate: daysAgo(4),
            isRead: true,
            autoReplyEnabled: true,
            replyDelay: 1.5,
            fallbackReply: "",
            templateType: .shopeepay
        )
        let shopeeMsg1 = Message(
            content: "ShopeePay OTP: 886267. Ma co hieu luc trong 5 phut. Vui long khong chia se ma nay voi bat ky ai.",
            isFromMe: false,
            timestamp: daysAgo(4)
        )
        let shopeeMsg2 = Message(
            content: "560440 (ma OTP ShopeePay se het han sau 5 phut). Khong cung cap ma nay cho bat ky ai ke ca nhan vien Shopee.",
            isFromMe: false,
            timestamp: daysAgo(4)
        )
        let shopeeMsg3 = Message(
            content: "Thanh toan hoa don SPayLater voi so tien 195,899 VND truoc ngay 15/07/2026 de tranh phat cham tra. Chi tiet: ung dung Shopee > SPayLater.",
            isFromMe: false,
            timestamp: daysAgo(3)
        )
        insert(conversation: shopee, messages: [shopeeMsg1, shopeeMsg2, shopeeMsg3], context: context)

        // ── 8. MobiFone (template MobiFone) ──────────────────────────────
        let mobi = Conversation(
            contactName: "MobiFone",
            contactPhone: "MobiFone",
            avatarColor: "blue",
            avatarInitials: "",
            lastMessage: "[QC] Mua dien thoai, sam laptop de dang voi the tin dung MobiFone VPBank...",
            lastMessageDate: daysAgo(5),
            isRead: true,
            autoReplyEnabled: true,
            replyDelay: 3.0,
            fallbackReply: "Cam on Quy khach da lien he MobiFone. Hotline: 18001090.",
            templateType: .mobifone
        )
        let mobiMsg1 = Message(
            content: "MobiFone xin kinh bao: Goi cuoc PT90 cua Quy khach se het han vao ngay 11/07/2026. De gia han vui long soan GH gui 9084. Chi tiet: 18001091.",
            isFromMe: false,
            timestamp: daysAgo(5)
        )
        let mobiMsg2 = Message(
            content: "[QC] Mua dien thoai, sam laptop de dang voi the tin dung MobiFone VPBank. Uu dai len den 10%. Truy cap: the.mobifone.vn",
            isFromMe: false,
            timestamp: daysAgo(5)
        )
        let mobiMsg3 = Message(
            content: "[TB] World Cup 2026 bung no! MobiFone tang ban code WC26R32 giam 50% goi data. Han dung 30/07/2026.",
            isFromMe: false,
            timestamp: daysAgo(4)
        )
        insert(conversation: mobi, messages: [mobiMsg1, mobiMsg2, mobiMsg3], context: context)

        // ── 9. An ninh mạng ───────────────────────────────────────────────
        let anninh = Conversation(
            contactName: "Cục ANMPCTP",
            contactPhone: "AnNinhMang",
            avatarColor: "red",
            avatarInitials: "",
            lastMessage: "CUC AN NINH MANG VA PCTP: Khuyen cao nguoi dan khong truy cap duong link la...",
            lastMessageDate: daysAgo(6),
            isRead: true,
            autoReplyEnabled: false,
            templateType: .none
        )
        let anninhMsg = Message(
            content: "CUC AN NINH MANG VA PCTP: Khuyen cao nguoi dan khong truy cap duong link la, khong cung cap OTP, thong tin ca nhan cho bat ky ai. Neu bi lua dao, bao ngay: 113 hoac 0692.348.560.",
            isFromMe: false,
            timestamp: daysAgo(6)
        )
        insert(conversation: anninh, messages: [anninhMsg], context: context)
    }

    // MARK: - Personal (giống seedPersonal IPA gốc)

    static func seedPersonal(context: ModelContext) {

        // Việt Anh
        let vietAnh = Conversation(
            contactName: "Việt Anh",
            contactPhone: "0372050027",
            avatarColor: "blue",
            avatarInitials: "VA",
            lastMessage: "F",
            lastMessageDate: daysAgo(3),
            isRead: true,
            autoReplyEnabled: false,
            templateType: .none
        )
        let vaMsg1 = Message(content: "bro qua day choi hong", isFromMe: false, timestamp: daysAgo(4))
        let vaMsg2 = Message(content: "F", isFromMe: true, timestamp: daysAgo(3))
        insert(conversation: vietAnh, messages: [vaMsg1, vaMsg2], context: context)

        // 900
        let c900 = Conversation(
            contactName: "900",
            contactPhone: "900",
            avatarColor: "gray",
            avatarInitials: "",
            lastMessage: "Tai khoan VNeID cua ban da duoc dang ky...",
            lastMessageDate: daysAgo(3),
            isRead: true,
            autoReplyEnabled: false,
            templateType: .none
        )
        let c900Msg = Message(
            content: "Tai khoan VNeID cua ban da duoc dang ky thanh cong. Vui long dang nhap ung dung VNeID de hoan tat xac thuc.",
            isFromMe: false,
            timestamp: daysAgo(3)
        )
        insert(conversation: c900, messages: [c900Msg], context: context)
    }

    // MARK: - Helpers

    private static func insert(conversation: Conversation, messages: [Message], context: ModelContext) {
        for msg in messages {
            msg.conversation = conversation
            conversation.messages.append(msg)
        }
        if let last = messages.last {
            conversation.lastMessage = last.content
            conversation.lastMessageDate = last.timestamp
        }
        context.insert(conversation)
    }

    private static func daysAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -n, to: .now) ?? .now
    }

    private static func hoursAgo(_ n: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: -n, to: .now) ?? .now
    }
}
