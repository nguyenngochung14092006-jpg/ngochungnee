import Foundation

/// Sinh nội dung tin nhắn tự động từ cấu hình của cuộc hội thoại.
/// - Mẫu 1 (MobiFone): TB tra truoc ca nhan...
/// - Mẫu 2 (Viettel): Thuê bao ... đã xác thực ...
/// - Tự viết (custom): dùng `customReply` nguyên văn.
enum MessageTemplate {

    static func render(for c: Conversation) -> String {
        switch c.templateType {
        case .mobifone:
            return mobifone(c)
        case .viettel:
            return viettel(c)
        case .shopeepay:
            return shopeepay(c)
        case .custom, .none:
            return c.customReply
        }
    }

    // MARK: - Mẫu 1: MobiFone

    private static func mobifone(_ c: Conversation) -> String {
        let name = c.mName.isEmpty ? "NGUYEN VAN A" : c.mName
        let dob = c.mDob.isEmpty ? "01/01/1990" : c.mDob
        let phone = c.mPhone.isEmpty ? "0900000000" : c.mPhone
        return "TB tra truoc ca nhan. Ho ten: \(name), Ngay sinh: \(dob). "
            + "Danh sach so thue bao dang ky: \(phone). "
            + "Chi tiet truy cap app My MobiFone hoac lien he 18001090 hoac tai Cua hang MobiFone. Cam on Quy khach."
    }

    // MARK: - Mẫu 2: Viettel

    private static func viettel(_ c: Conversation) -> String {
        let name = c.mName.isEmpty ? "NGUYEN VAN A" : c.mName
        let dob = c.mDob.isEmpty ? "01/01/1990" : c.mDob
        let phone = c.mPhone.isEmpty ? "0900000000" : c.mPhone
        let cccd = c.mCccd.isEmpty ? "049000000000" : c.mCccd
        let ngayCap = c.mNgayCap.isEmpty ? "01/01/2021" : c.mNgayCap
        let ngayKichHoat = c.mNgayKichHoat.isEmpty ? "01/01/2022" : c.mNgayKichHoat
        let otp = String(format: "%06d", Int.random(in: 0...999999))
        let link = "https://viettel.vn/TTTB?idNo=\(cccd)&isdn=\(phone)&otp=\(otp)"
        return "Thuê bao: \(phone), đã xác thực theo quy định tại Thông tư 08/2026/TT-BKHCN.\n"
            + "Thông tin giấy tờ thuê bao:\n"
            + "Họ tên: \(name), ngày sinh: \(dob).\n"
            + "Thẻ căn cước: \(cccd), nơi cấp: Cục trưởng CCS QLHC về trật tự xã hội, ngày cấp: \(ngayCap).\n"
            + "Loại thuê bao: trả trước, ngày kích hoạt: \(ngayKichHoat).\n"
            + "Để tra cứu thuê bao cùng số giấy tờ sở hữu, truy cập: \(link)\n"
            + "Liên hệ 198 (0đ).\n"
            + "Trân trọng!"
    }

    // MARK: - ShopeePay OTP

    private static func shopeepay(_ c: Conversation) -> String {
        let otp = String(format: "%06d", Int.random(in: 0...999999))
        return "\(otp) (ma OTP ShopeePay se het han sau 5 phut). "
            + "Luu y: tuyet doi khong cung cap OTP cho bat cu ai vi bat cu ly do nao."
    }

    // MARK: - Random helpers (dùng cho nút "Tạo ngẫu nhiên thông tin")

    static let firstNames = ["Nguyễn", "Trần", "Lê", "Phạm", "Hoàng", "Huỳnh", "Phan", "Vũ", "Đặng", "Bùi"]
    static let midNames = ["Văn", "Công", "Minh", "Thị", "Quang", "Hữu", "Đức", "Ngọc", "Thanh", "Xuân"]
    static let lastNames = ["An", "Bình", "Cường", "Dũng", "Hưng", "Long", "Nam", "Phong", "Thanh", "Tuấn"]

    static func randomName() -> String {
        "\(firstNames.randomElement()!) \(midNames.randomElement()!) \(lastNames.randomElement()!)"
    }

    static func randomPhone() -> String {
        let prefixes = ["03", "05", "07", "08", "09"]
        var s = prefixes.randomElement()!
        for _ in 0..<8 { s += String(Int.random(in: 0...9)) }
        return s
    }

    static func randomCCCD() -> String {
        var s = "0\(Int.random(in: 40...49))"
        for _ in 0..<9 { s += String(Int.random(in: 0...9)) }
        return s
    }

    static func randomDate(fromYear: Int, toYear: Int) -> String {
        let day = Int.random(in: 1...28)
        let month = Int.random(in: 1...12)
        let year = Int.random(in: fromYear...toYear)
        return String(format: "%02d/%02d/%04d", day, month, year)
    }
}
