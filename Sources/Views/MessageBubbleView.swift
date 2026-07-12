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

                bubbleContent
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.25)) {
                            showTime.toggle()
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
            .padding(.horizontal, 13)
            .padding(.vertical, 8)
            .background(
                BubbleWithTail(isFromMe: message.isFromMe, showTail: isTail)
                    .fill(message.isFromMe
                          ? Color(red: 0.20, green: 0.84, blue: 0.29)
                          : Color(.systemGray5))
            )
            .padding(message.isFromMe ? .trailing : .leading, isTail ? 4 : 0)
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

// MARK: - Bubble Shape (với đuôi cong kiểu iMessage)

struct BubbleWithTail: Shape {
    let isFromMe: Bool
    let showTail: Bool

    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = min(18, rect.height / 2)
        var path = Path(roundedRect: rect, cornerRadius: radius)

        guard showTail else { return path }

        var tail = Path()
        if isFromMe {
            let x = rect.maxX
            let y = rect.maxY
            tail.move(to: CGPoint(x: x - radius, y: y))
            tail.addQuadCurve(to: CGPoint(x: x + 5, y: y),
                              control: CGPoint(x: x - 2, y: y))
            tail.addQuadCurve(to: CGPoint(x: x - 1, y: y - 10),
                              control: CGPoint(x: x + 1, y: y - 3))
            tail.addLine(to: CGPoint(x: x - radius, y: y - 10))
            tail.closeSubpath()
        } else {
            let x = rect.minX
            let y = rect.maxY
            tail.move(to: CGPoint(x: x + radius, y: y))
            tail.addQuadCurve(to: CGPoint(x: x - 5, y: y),
                              control: CGPoint(x: x + 2, y: y))
            tail.addQuadCurve(to: CGPoint(x: x + 1, y: y - 10),
                              control: CGPoint(x: x - 1, y: y - 3))
            tail.addLine(to: CGPoint(x: x + radius, y: y - 10))
            tail.closeSubpath()
        }
        path.addPath(tail)
        return path
    }
}
