import SwiftUI
import SwiftData

/// NewMessageView — màn hình soạn tin nhắn mới
/// Giống iOS: "Tin nhắn mới" + nút X + ô "Đến:" + keyboard
struct NewMessageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.contactName) private var conversations: [Conversation]
    @Binding var showNewMessage: Bool

    @State private var toText = ""
    @State private var messageBody = ""
    @State private var selectedConversation: Conversation?
    @FocusState private var toFocused: Bool

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
                // To bar
                HStack(spacing: 8) {
                    Text("Đến:")
                        .font(.system(size: 17))
                        .foregroundStyle(.primary)

                    if let conv = selectedConversation {
                        HStack(spacing: 4) {
                            AvatarView(initials: conv.avatarInitials, color: conv.avatarColor, size: 22)
                            Text(conv.contactName)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
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
                            .foregroundStyle(.primary)
                            .focused($toFocused)
                            .autocorrectionDisabled()
                    }

                    Spacer()

                    Button {
                        // Add from contacts
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                            .foregroundStyle(.primary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.background)

                Divider()

                // Suggestions
                if !suggestions.isEmpty && selectedConversation == nil {
                    List(suggestions) { conv in
                        Button {
                            selectedConversation = conv
                            toText = conv.contactName
                            toFocused = false
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(initials: conv.avatarInitials, color: conv.avatarColor, size: 42)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(conv.contactName)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(.primary)
                                    Text(conv.contactPhone)
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }

                Spacer()
            }
            .navigationTitle("Tin nhắn mới")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        showNewMessage = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(.systemFill), Color(.systemGray2))
                    }
                }
            }
            .onAppear { toFocused = true }
        }
    }
}
