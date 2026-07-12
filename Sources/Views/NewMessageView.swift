import SwiftUI
import SwiftData

/// NewMessageView — màn hình soạn tin nhắn mới giống video:
/// "Tin nhắn mới" + nút X + ô "Đến:" + gợi ý liên hệ (tên xanh lá, nút ⓘ)
/// Chọn người nhận → hiện "Từ: Ⓒ Chính" + hội thoại + ô nhập tin.
struct NewMessageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.contactName) private var conversations: [Conversation]
    @Binding var showNewMessage: Bool

    @State private var toText = ""
    @State private var messageText = ""
    @State private var selectedConversation: Conversation?
    @FocusState private var toFocused: Bool
    @FocusState private var composerFocused: Bool

    var suggestions: [Conversation] {
        guard !toText.isEmpty else { return [] }
        return conversations.filter {
            $0.contactName.localizedCaseInsensitiveContains(toText) ||
            $0.contactPhone.localizedCaseInsensitiveContains(toText)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ── Ô "Đến:" ──────────────────────────────────────────
                HStack(spacing: 8) {
                    Text("Đến:")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)

                    if let conv = selectedConversation {
                        Text(conv.contactName)
                            .font(.system(size: 17))
                            .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
                        Button {
                            selectedConversation = nil
                            toText = ""
                            toFocused = true
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        TextField("", text: $toText)
                            .font(.system(size: 17))
                            .keyboardType(.numbersAndPunctuation)
                            .focused($toFocused)
                            .autocorrectionDisabled()
                            .onSubmit { selectOrCreate() }
                    }

                    Spacer()

                    Button {
                        selectOrCreate()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.primary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6).opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // ── "Từ: Ⓒ Chính" ─────────────────────────────────────
                if selectedConversation != nil {
                    HStack(spacing: 6) {
                        Text("Từ:")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                        Image(systemName: "c.square.fill")
                            .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
                        Text("Chính")
                            .font(.system(size: 17))
                            .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6).opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 12)
                    .padding(.top, 6)
                }

                // ── Gợi ý liên hệ ─────────────────────────────────────
                if selectedConversation == nil && !suggestions.isEmpty {
                    List(suggestions) { conv in
                        Button {
                            select(conv)
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(initials: conv.avatarInitials, color: conv.avatarColor, size: 42)
                                Text(conv.contactName)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
                                Spacer()
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .listRowSeparatorTint(Color(.separator).opacity(0.5))
                    }
                    .listStyle(.plain)
                } else if let conv = selectedConversation {
                    // ── Hội thoại ────────────────────────────────────
                    ChatMessagesInlineView(conversation: conv)
                } else {
                    Spacer()
                }
            }
            .safeAreaInset(edge: .bottom) {
                if selectedConversation != nil {
                    composerBar
                }
            }
            .navigationTitle("Tin nhắn mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showNewMessage = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.primary)
                    }
                }
            }
            .onAppear { toFocused = true }
        }
    }

    // MARK: - Composer

    var composerBar: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Button { } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color(.darkGray))
                    .frame(width: 34, height: 34)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }

            HStack(alignment: .bottom, spacing: 4) {
                TextField("Tin nhắn văn bản \u{2022} SMS", text: $messageText, axis: .vertical)
                    .font(.system(size: 17))
                    .lineLimit(1...5)
                    .padding(.leading, 6)
                    .focused($composerFocused)

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
        .background(.background)
    }

    // MARK: - Actions

    func select(_ conv: Conversation) {
        selectedConversation = conv
        toFocused = false
        composerFocused = true
    }

    func selectOrCreate() {
        let text = toText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        if let existing = conversations.first(where: {
            $0.contactName.caseInsensitiveCompare(text) == .orderedSame ||
            $0.contactPhone == text
        }) {
            select(existing)
        } else {
            let conv = Conversation(contactName: text, contactPhone: text)
            modelContext.insert(conv)
            select(conv)
        }
    }

    func sendMessage() {
        guard let conversation = selectedConversation else { return }
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""

        let reply = AutoReplyService.shared.reply(for: text, in: conversation)

        let msg = Message(
            content: text,
            isFromMe: true,
            status: reply == nil ? .failed : .sent
        )
        msg.conversation = conversation
        conversation.messages.append(msg)
        conversation.lastMessage = reply == nil ? "Lỗi gửi tin nhắn" : text
        conversation.lastMessageDate = .now
        conversation.isRead = true

        guard let replyText = reply else { return }
        let delay = max(1.0, conversation.replyDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let auto = Message(content: replyText, isFromMe: false, isAutoReply: true)
            auto.conversation = conversation
            conversation.messages.append(auto)
            conversation.lastMessage = replyText
            conversation.lastMessageDate = .now
        }
    }
}

// MARK: - Inline messages (dùng trong sheet Tin nhắn mới)

struct ChatMessagesInlineView: View {
    @Bindable var conversation: Conversation

    var sortedMessages: [Message] {
        conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(sortedMessages.enumerated()), id: \.element.id) { index, message in
                        let isLast = index == sortedMessages.count - 1
                        let nextIsFromMe = index + 1 < sortedMessages.count
                            ? sortedMessages[index + 1].isFromMe
                            : !message.isFromMe
                        let isTail = isLast || nextIsFromMe != message.isFromMe

                        MessageBubbleView(message: message, isTail: isTail)
                            .id(message.id)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                if let last = sortedMessages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
            .onChange(of: conversation.messages.count) {
                if let last = sortedMessages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}
