import SwiftUI
import SwiftData
import PhotosUI

/// ChatView — màn hình chat với bubble giống hệt iOS Messages
struct ChatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var conversation: Conversation

    @State private var messageText = ""
    @State private var isShowingConfig = false
    @State private var isShowingDetail = false
    @State private var isTyping = false
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    @FocusState private var isComposerFocused: Bool

    @Query private var allConversations: [Conversation]
    var totalUnread: Int { allConversations.filter { !$0.isRead }.count }

    var sortedMessages: [Message] {
        conversation.messages.sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        VStack(spacing: 0) {
            chatNavBar
            Divider()
            messagesScroll
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom) { inputBar }
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoItem, matching: .images)
        .sheet(isPresented: $isShowingConfig) {
            ChatConfigView(conversation: conversation)
        }
        .sheet(isPresented: $isShowingDetail) {
            ContactDetailView(conversation: conversation)
        }
        .onChange(of: photoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { sendImage(data) }
                }
            }
        }
        .onAppear { conversation.isRead = true }
    }

    // MARK: - Messages

    var messagesScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedMessages, id: \.date) { group in
                        MessageSeparatorView(date: group.date)

                        ForEach(Array(group.messages.enumerated()), id: \.element.id) { index, message in
                            let isLast = index == group.messages.count - 1
                            let nextIsFromMe = index + 1 < group.messages.count
                                ? group.messages[index + 1].isFromMe
                                : !message.isFromMe
                            let isTail = isLast || nextIsFromMe != message.isFromMe

                            MessageBubbleView(
                                message: message,
                                isTail: isTail,
                                onReact: { reaction in
                                    if message.reaction == reaction {
                                        message.reaction = nil
                                    } else {
                                        message.reaction = reaction
                                    }
                                }
                            )
                            .id(message.id)
                        }
                    }

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
            .scrollDismissesKeyboard(.interactively)
            .onAppear {
                scrollToBottom(proxy: proxy)
                conversation.isRead = true
            }
            .onChange(of: conversation.messages.count) {
                scrollToBottom(proxy: proxy, animated: true)
            }
            .onChange(of: isTyping) {
                if isTyping {
                    withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
                }
            }
            .onChange(of: isComposerFocused) {
                if isComposerFocused {
                    scrollToBottom(proxy: proxy, animated: true)
                }
            }
        }
    }

    // MARK: - Navigation Bar

    var chatNavBar: some View {
        ZStack {
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
                // Menu đính kèm (+)
                Menu {
                    Button {
                        showPhotoPicker = true
                    } label: {
                        Label("Ảnh", systemImage: "photo")
                    }
                    Button { } label: { Label("Camera", systemImage: "camera") }
                    Button { } label: { Label("Nhãn dán", systemImage: "face.smiling") }
                    Button { } label: { Label("Âm thanh", systemImage: "waveform") }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(.darkGray))
                        .frame(width: 34, height: 34)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .padding(.bottom, 1)

                HStack(alignment: .bottom, spacing: 4) {
                    TextField("Tin nhắn văn bản \u{2022} SMS", text: $messageText, axis: .vertical)
                        .font(.system(size: 17))
                        .lineLimit(1...5)
                        .padding(.leading, 6)
                        .focused($isComposerFocused)

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
        }
        .background(.background)
    }

    // MARK: - Actions

    func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        messageText = ""

        // Tìm phản hồi tự động theo từ khóa
        let reply = AutoReplyService.shared.reply(for: text, in: conversation)

        let msg = Message(
            content: text,
            isFromMe: true,
            status: reply == nil ? .failed : .sent
        )
        msg.conversation = conversation
        conversation.messages.append(msg)
        conversation.lastMessage = text
        conversation.lastMessageDate = .now
        conversation.isRead = true

        // Nếu khớp từ khóa → tự động trả lời sau delay
        guard let replyText = reply else { return }
        withAnimation { isTyping = true }
        let delay = max(1.0, conversation.replyDelay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation { isTyping = false }
            let auto = Message(content: replyText, isFromMe: false, isAutoReply: true)
            auto.conversation = self.conversation
            self.conversation.messages.append(auto)
            self.conversation.lastMessage = replyText
            self.conversation.lastMessageDate = .now
        }
    }

    func sendImage(_ data: Data) {
        let msg = Message(content: "", isFromMe: true, status: .failed, imageData: data)
        msg.conversation = conversation
        conversation.messages.append(msg)
        conversation.lastMessage = "[Hình ảnh]"
        conversation.lastMessageDate = .now
        conversation.isRead = true
    }

    func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = false) {
        guard let lastMsg = sortedMessages.last else { return }
        if animated {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMsg.id, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(lastMsg.id, anchor: .bottom)
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
