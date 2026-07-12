import SwiftUI

/// AvatarView — vòng tròn avatar giống iOS Messages
/// - Nếu có initials: hiển thị chữ viết tắt có màu
/// - Nếu không: icon người mặc định màu xám
struct AvatarView: View {
    let initials: String
    let color: String
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [avatarColor.opacity(0.75), avatarColor],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            if initials.isEmpty {
                // Default person icon (bóng người trắng giống Danh bạ iOS)
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding(size * 0.2)
                    .offset(y: size * 0.08)
            } else {
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    var avatarColor: Color {
        switch color {
        case "green":  return Color(red: 0.20, green: 0.78, blue: 0.35)
        case "blue":   return Color(red: 0.35, green: 0.55, blue: 0.90)
        case "orange": return Color(red: 1.00, green: 0.58, blue: 0.00)
        case "purple": return Color(red: 0.69, green: 0.32, blue: 0.87)
        case "red":    return Color(red: 1.00, green: 0.23, blue: 0.19)
        case "teal":   return Color(red: 0.20, green: 0.68, blue: 0.90)
        default:       return Color(red: 0.66, green: 0.71, blue: 0.78)  // xám xanh giống iOS
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        AvatarView(initials: "", color: "gray", size: 52)
        AvatarView(initials: "VA", color: "blue", size: 52)
        AvatarView(initials: "G", color: "red", size: 52)
        AvatarView(initials: "SP", color: "orange", size: 52)
    }
    .padding()
}
