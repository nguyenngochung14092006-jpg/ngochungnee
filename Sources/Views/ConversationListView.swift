import SwiftUI
import SwiftData

/// ConversationListView — màn hình danh sách tin nhắn (giống iOS Messages)
struct ConversationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.lastMessageDate, order: .reverse) private var conversations: [Conversation]
    @Binding var selectedConversation: Conversation?
    @Binding var showNewMessage: Bool

    @State private var isEditing = false
    @State private var selectedTab: FilterTab = .all
    @State private var searchText = ""

    enum FilterTab { case all, unread }

    var filteredConversations: [Conversation] {
        var list = conversations
        if selectedTab == .unread { list = list.filter { !$0.isRead } }
        if !searchText.isEmpty {
            list = list.filter {
                $0.contactName.localizedCaseInsensitiveContains(searchText) ||
                $0.lastMessage.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    var unreadCount: Int { conversations.filter { !$0.isRead }.count }

    var body: some View {
        VStack(spacing: 0) {
            // ── Navigation Header ──────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Button(isEditing ? "Xong" : "Sửa") {
                        withAnimation { isEditing.toggle() }
                    }
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(.blue)

                    Spacer()

                    Button {
                        showNewMessage = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 20, weight: .regular))
                            .foregroundStyle(.blue)
                    }
                }
                .frame(height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tin nhắn")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                    Text("Đã tạm dừng đồng bộ hóa với iCloud")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 8)
            }
            .padding(.horizontal, 16)
            .background(.background)

            Divider()

            // ── Filter Tabs ────────────────────────────────────────────
            HStack(spacing: 8) {
                FilterTabButton(title: "Tất cả", isSelected: selectedTab == .all) {
                    selectedTab = .all
                }
                FilterTabButton(title: "Chưa đọc", isSelected: selectedTab == .unread) {
                    selectedTab = .unread
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.background)

            // ── Conversation List ──────────────────────────────────────
            List {
                ForEach(filteredConversations) { conv in
                    NavigationLink(destination: ChatView(conversation: conv)) {
                        ConversationRowView(conversation: conv, isEditing: isEditing)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 16))
                    .listRowSeparatorTint(Color(.separator).opacity(0.5))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            modelContext.delete(conv)
                        } label: {
                            Label("Xóa", systemImage: "trash")
                        }

                        Button {
                            conv.isRead.toggle()
                        } label: {
                            Label(conv.isRead ? "Chưa đọc" : "Đã đọc",
                                  systemImage: conv.isRead ? "message.badge" : "message")
                        }
                        .tint(.blue)
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Tìm kiếm")

            // ── Bottom Search / Tab Bar ────────────────────────────────
            Divider()
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 15))
                    Text("Tìm kiếm")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: "mic")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 15))
                }
                .padding(8)
                .background(Color(.systemFill))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .padding(.bottom, 8)
            .background(.background)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showNewMessage) {
            NewMessageView(showNewMessage: $showNewMessage)
        }
        .onAppear {
            // Đánh dấu đã đọc khi mở lại
        }
    }
}

// MARK: - Filter Tab Button

struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(isSelected ? .white : .blue)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(isSelected ? Color.blue : Color(.systemFill))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Conversation Row

struct ConversationRowView: View {
    @Bindable var conversation: Conversation
    let isEditing: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Unread dot
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
                .padding(.top, 22)
                .padding(.trailing, 4)
                .opacity(conversation.isRead ? 0 : 1)

            // Avatar
            AvatarView(
                initials: conversation.avatarInitials,
                color: conversation.avatarColor,
                size: 52
            )
            .padding(.trailing, 12)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.contactName)
                        .font(.system(size: 17, weight: conversation.isRead ? .regular : .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.lastMessageDate.relativeLabel)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Icon chỉ báo: tin nhắn đến có icon ảnh/âm thanh?
                        Text(previewText)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(.systemFill))
                        .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture {
            conversation.isRead = true
        }
    }

    var previewText: String {
        let msg = conversation.lastMessage
        // Thêm icon nếu cần
        return msg
    }
}

// MARK: - Date Helper

extension Date {
    var relativeLabel: String {
        let cal = Calendar.current
        if cal.isDateInToday(self) {
            return formatted(date: .omitted, time: .shortened)
        } else if cal.isDateInYesterday(self) {
            return "Hôm qua"
        }
        let components = cal.dateComponents([.day, .weekOfYear], from: self, to: .now)
        if let days = components.day, days < 7 {
            return formatted(.dateTime.weekday(.wide))
        }
        return formatted(date: .numeric, time: .omitted)
    }
}
