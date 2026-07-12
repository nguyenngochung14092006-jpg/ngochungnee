import SwiftUI

/// MessageBubbleView — bong bóng tin nhắn iOS
/// - Xanh lá (isFromMe=true): căn phải
/// - Xám (isFromMe=false): căn trái
struct MessageBubbleView: View {
    let message: Message
    let isTail: Bool    // true = cuối nhóm → hiện đuôi
    var showsStatus: Bool = false
    var onReact: ((MessageReaction) -> Void)? = nil

    @State private var showTime = false

    var body: some View {
        VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 1) {
            HStack(alignment: .bottom, spacing: 6) {
                if message.isFromMe { Spacer(minLength: 60) }

                bubbleContent
                    .overlay(alignment: message.isFromMe ? .topLeading : .topTrailing) {
                        if let reaction = message.reaction {
                            reactionBadge(reaction)
                                .offset(x: message.isFromMe ? -10 : 10, y: -14)
                        }
                    }
                    .contextMenu {
                        ForEach(MessageReaction.allCases, id: \.self) { r in
                            Button {
                                onReact?(r)
                            } label: {
                                Label(reactionLabel(r), systemImage: r.symbol)
                            }
                        }
                    }
                    .onTapGesture {
                        withAnimation(.spring(duration: 0.25)) { showTime.toggle() }
                    }

                // Dấu (!) đỏ khi gửi lỗi
                if message.isFromMe && message.status == .failed {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(.red)
                }

                if !message.isFromMe { Spacer(minLength: 60) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 1)

            // "Chưa gửi được"
            if message.isFromMe && message.status == .failed {
                Text("Chưa gửi được")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.red)
                    .padding(.trailing, 44)
            } else if message.isFromMe && showsStatus {
                Text(statusLabel)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 20)
            }

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
        if let data = message.imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(width: 200, height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(message.isFromMe ? .trailing : .leading, isTail ? 4 : 0)
        } else {
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
    }

    func reactionBadge(_ reaction: MessageReaction) -> some View {
        Image(systemName: reaction.symbol)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(reaction == .heart ? .red : .primary)
            .padding(6)
            .background(Circle().fill(Color(.systemGray6)))
            .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
    }

    func reactionLabel(_ r: MessageReaction) -> String {
        switch r {
        case .heart: return "Tim"
        case .thumbsUp: return "Thích"
        case .thumbsDown: return "Không thích"
        case .haha: return "Haha"
        case .exclamation: return "!!"
        case .question: return "?"
        }
    }

    var statusLabel: String {
        switch message.status {
        case .sending: return "Đang gửi…"
        case .sent: return "Đã gửi"
        case .delivered: return "Đã chuyển"
        case .read: return "Đã đọc"
        case .failed: return "Chưa gửi được"
        }
    }

    func makeAttributedText(_ text: String) -> AttributedString {
        var attributed = AttributedString(text)
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
