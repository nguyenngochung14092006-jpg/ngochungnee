import SwiftUI
import SwiftData

/// ChatView — màn hình chat với bubble giống hệt iOS Messages
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var conversation: Conversation

    @State private var messageText = ""
    @State private var isShowingConfig = false
    @State private var isShowingDetail = false
    @State private var isTyping = false
    @State private var scrollProxy: ScrollViewProxy? = nil

    // Unread count in back button (total unread across all conversations)
    @Query private var allConversations: [Conversation]
    var totalUnread: Int { allConversations.filter { !$0.isRead }.count }

    var sortedMessages: [Message] {
        conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Navigation Bar ────────────────────────────────────────
            chatNavBar

            Divider()

            // ── Messages Scroll ───────────────────────────────────────
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(groupedMessages, id: \.date) { group in
                            // Date separator
                            MessageSeparatorView(date: group.date)

                            ForEach(Array(group.messages.enumerated()), id: \.element.id) { index, message in
                                let isLast = index == group.messages.count - 1
                                let nextIsFromMe = index + 1 < group.messages.count
                                    ? group.messages[index + 1].isFromMe
                                    : !message.isFromMe
                                let isTail = isLast || nextIsFromMe != message.isFromMe

                                MessageBubbleView(
                                    message: message,
                                    isTail: isTail
                                )
                                .id(message.id)
                            }
                        }

                        // Typing indicator
                        if isTyping {
                            HStack(alignment: .bottom) {
                                TypingIndicatorView()
                                    .padding(.leading, 16)
                                    .padding(.bottom, 4)
                                Spacer()
                            }
                            .id("typing")
                        }
                    }
                    .padding(.bottom, 8)
                }
                .onAppear {
                    scrollProxy = proxy
                    scrollToBottom(proxy: proxy)
                    conversation.isRead = true
                }
                .onChange(of: conversation.messages.count) {
                    scrollToBottom(proxy: proxy, animated: true)
                }
                .onChange(of: isTyping) {
                    if isTyping {
                        withAnimation {
                            proxy.scrollTo("typing", anchor: .bottom)
                        }
                    }
                }
            }

            // ── Input Bar ─────────────────────────────────────────────
            inputBar
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingConfig) {
            ChatConfigView(conversation: conversation)
        }
        .sheet(isPresented: $isShowingDetail) {
            ContactDetailView(conversation: conversation)
        }
        .onAppear {
            conversation.isRead = true
        }
    }

    // MARK: - Navigation Bar

    var chatNavBar: some View {
        ZStack {
            // Center: avatar + name (giống iOS Messages)
            Button {
                isShowingDetail = true
            } label: {
                VStack(spacing: 3) {
                    AvatarView(
                        initials: conversation.avatarInitials,
                        color: conversation.avatarColor,
                        size: 50
                    )
                    HStack(spacing: 2) {
                        Text(conversation.contactName)
                            .font(.system(size: 12))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(Color(.systemGray2))
                    }
                }
            }
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.6).onEnded { _ in
                    isShowingConfig = true
                }
            )

            HStack {
                // Back button: chevron + số chưa đọc trong pill xám
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        if totalUnread > 0 {
                            Text("\(totalUnread)")
                                .font(.system(size: 15, weight: .medium))
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }
                .padding(.leading, 8)

                Spacer()
            }
            .padding(.bottom, 34)
        }
        .frame(height: 84)
        .background(.background)
    }

    // MARK: - Input Bar

    var inputBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .bottom, spacing: 6) {
                // Plus button (vòng tròn xám nhạt giống iOS)
                Button {
                    // Attachment menu
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(.darkGray))
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .padding(.bottom, 1)

                // Text input
                HStack(alignment: .bottom, spacing: 4) {
                    TextField("Tin nhắn văn bản \u{2022} SMS", text: $messageText, axis: .vertical)
                        .font(.system(size: 17))
                        .lineLimit(5)
                        .padding(.leading, 6)

                    if messageText.trimmingCharacters(in: .whitespaces).isEmpty {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 17))
                            .foregroundStyle(Color(.systemGray2))
                            .padding(.trailing, 2)
                    } else {
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 26))
                                .foregroundStyle(Color(red: 0.20, green: 0.84, blue: 0.29))
                        }
                        .offset(x: 3)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color(.separator).opacity(0.6), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .padding(.bottom, 4)
        }
        .background(.background)
    }

    // MARK: - Actions

    func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""

        let msg = Message(content: text, isFromMe: true)
        msg.conversation = conversation
        conversation.messages.append(msg)
        conversation.lastMessage = text
        conversation.lastMessageDate = .now
        conversation.isRead = true

        // Trigger auto-reply
        AutoReplyService.shared.process(
            incomingText: text,
            conversation: conversation
        ) { [self] replyText in
            // Show typing indicator first
            withAnimation { isTyping = true }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { isTyping = false }

                let reply = Message(
                    content: replyText,
                    isFromMe: false,
                    timestamp: .now,
                    isAutoReply: true
                )
                reply.conversation = self.conversation
                self.conversation.messages.append(reply)
                self.conversation.lastMessage = replyText
                self.conversation.lastMessageDate = .now
            }
        }
    }

    func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = false) {
        if let lastMsg = sortedMessages.last {
            if animated {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo(lastMsg.id, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(lastMsg.id, anchor: .bottom)
            }
        }
    }

    // MARK: - Grouped Messages by Date

    struct MessageGroup {
        let date: Date
        let messages: [Message]
    }

    var groupedMessages: [MessageGroup] {
        var groups: [MessageGroup] = []
        var currentGroup: [Message] = []
        var currentDate: Date?

        for msg in sortedMessages {
            let msgDay = Calendar.current.startOfDay(for: msg.timestamp)
            if let day = currentDate, Calendar.current.isDate(day, inSameDayAs: msgDay) {
                currentGroup.append(msg)
            } else {
                if !currentGroup.isEmpty, let day = currentDate {
                    groups.append(MessageGroup(date: day, messages: currentGroup))
                }
                currentGroup = [msg]
                currentDate = msgDay
            }
        }
        if !currentGroup.isEmpty, let day = currentDate {
            groups.append(MessageGroup(date: day, messages: currentGroup))
        }
        return groups
    }
}

// MARK: - Typing Indicator

struct TypingIndicatorView: View {
    @State private var animate = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color(.systemGray2))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animate ? 1.0 : 0.6)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(Double(i) * 0.15),
                        value: animate
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.systemGray5))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onAppear { animate = true }
    }
}
