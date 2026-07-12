import SwiftUI

/// Dải phân cách ngày/giờ giữa các nhóm tin nhắn
/// Ví dụ: "16:12, Hôm nay" hoặc "Thứ Sáu, 10/07"
struct MessageSeparatorView: View {
    let date: Date

    var body: some View {
        Text(formattedDate)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 16)
    }

    var formattedDate: String {
        let cal = Calendar.current
        let time = date.formatted(date: .omitted, time: .shortened)

        if cal.isDateInToday(date) {
            return "\(time), Hôm nay"
        } else if cal.isDateInYesterday(date) {
            return "\(time), Hôm qua"
        }

        let dayOfWeek = date.formatted(.dateTime.weekday(.wide).locale(Locale(identifier: "vi_VN")))
        let dateStr = date.formatted(.dateTime.day().month().locale(Locale(identifier: "vi_VN")))
        return "\(time), \(dayOfWeek) \(dateStr)"
    }
}
