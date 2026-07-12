import SwiftUI

/// MessageBubbleView — bong bóng tin nhắn iOS
/// - Xanh lá (isFromMe=true): căn phải
/// - Xám (isFromMe=false): căn trái
struct MessageBubbleView: View {
    let message: Message
    let isTail: Bool    // true = cuối nhóm → radius bình thường

    @State private var showTime = false

    var body: some View {
        VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 1) {
            HStack(alignment: .bottom, spacing: 0) {
                if message.isFromMe { Spacer(minLength: 60) }

                VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 2) {
                    // Bubble
                    bubbleContent
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.25)) {
                                showTime.toggle()
                            }
                        }

                    // Auto-reply badge
                    if message.isAutoReply {
                        Text("Tự động trả lời")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }
                }

                if !message.isFromMe { Spacer(minLength: 60) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 1)

            // Time (on tap)
            if showTime {
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.bottom, isTail ? 6 : 0)
    }

    @ViewBuilder
    var bubbleContent: some View {
        // Detect links in text
        let attributed = makeAttributedText(message.content)

        Text(attributed)
            .font(.system(size: 17))
            .foregroundStyle(message.isFromMe ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(message.isFromMe ? Color.green : Color(.systemGray5))
            .clipShape(
                BubbleShape(isFromMe: message.isFromMe, isTail: isTail)
            )
            .tint(message.isFromMe ? .white : .blue)
    }

    func makeAttributedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
        // Detect URLs
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let range = NSRange(text.startIndex..., in: text)
        detector?.enumerateMatches(in: text, range: range) { match, _, _ in
            guard let match, let url = match.url else { return }
            let swiftRange = Range(match.range, in: text)
                .flatMap { Range<AttributedString.Index>($0, in: attributed) }
            if let r = swiftRange {
                attributed[r].link = url
                attributed[r].underlineStyle = .single
            }
        }
        return attributed
    }
}

// MARK: - Bubble Shape

struct BubbleShape: Shape {
    let isFromMe: Bool
    let isTail: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 18
        let tailRadius: CGFloat = 4
        var path = Path()

        if isFromMe {
            // Right bubble
            path.addRoundedRect(
                in: rect,
                cornerRadii: .init(
                    topLeading: radius,
                    bottomLeading: radius,
                    bottomTrailing: isTail ? tailRadius : radius,
                    topTrailing: radius
                )
            )
        } else {
            // Left bubble
            path.addRoundedRect(
                in: rect,
                cornerRadii: .init(
                    topLeading: radius,
                    bottomLeading: isTail ? tailRadius : radius,
                    bottomTrailing: radius,
                    topTrailing: radius
                )
            )
        }
        return path
    }
}
