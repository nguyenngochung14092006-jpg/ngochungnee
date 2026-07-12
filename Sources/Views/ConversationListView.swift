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
    @FocusState private var isSearchFocused: Bool

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
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // ── Navigation Header ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button {
                            withAnimation { isEditing.toggle() }
                        } label: {
                            Text(isEditing ? "Xong" : "Sửa")
                                .font(.system(size: 17))
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 14)
                                .frame(height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Capsule())
                        }

                        Spacer()

                        Button {
                            selectedTab = selectedTab == .all ? .unread : .all
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.primary)
                                .frame(width: 36, height: 36)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                    }
                    .frame(height: 52)

                    Text("Tin nhắn")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(.primary)
                        .padding(.bottom, 10)
                }
                .padding(.horizontal, 16)
                .background(.background)

                // ── Conversation List ──────────────────────────────────────
                List {
                    ForEach(filteredConversations) { conv in
                        ConversationRowView(conversation: conv, isEditing: isEditing)
                        .background(
                            NavigationLink(destination: ChatView(conversation: conv)) { EmptyView() }
                                .opacity(0)
                        )
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 16))
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
                                Label("Ẩn cảnh báo", systemImage: "bell.slash.fill")
                            }
                            .tint(Color(.systemIndigo))
                        }
                    }
                }
                .listStyle(.plain)
                .contentMargins(.bottom, 70, for: .scrollContent)
            }

            // ── Bottom Floating Search Bar ─────────────────────────────
            HStack(spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    TextField("Tìm kiếm", text: $searchText)
                        .font(.system(size: 17))
                        .focused($isSearchFocused)
                        .autocorrectionDisabled()
                    if isSearchFocused && !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 16))
                        }
                    } else {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)

                Button {
                    showNewMessage = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
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

// MARK: - Conversation Row

struct ConversationRowView: View {
    @Bindable var conversation: Conversation
    let isEditing: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Unread dot (cột cố định để tên luôn thẳng hàng)
            Circle()
                .fill(Color.blue)
                .frame(width: 10, height: 10)
                .padding(.top, 24)
                .opacity(conversation.isRead ? 0 : 1)
                .padding(.trailing, 4)

            // Avatar
            AvatarView(
                initials: conversation.avatarInitials,
                color: conversation.avatarColor,
                size: 48
            )
            .padding(.top, 6)
            .padding(.trailing, 12)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.contactName)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer()

                    HStack(spacing: 4) {
                        Text(conversation.lastMessageDate.relativeLabel)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }

                (Text(Image(systemName: badgeSymbol)).foregroundColor(Color(.systemGray2)) + Text(" ") + Text(conversation.lastMessage))
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    var badgeSymbol: String {
        conversation.lastMessage.contains("(QC)") ? "c.square" : "p.square"
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
