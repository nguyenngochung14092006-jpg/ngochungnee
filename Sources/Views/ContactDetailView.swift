import SwiftUI
import SwiftData

/// ContactDetailView — màn hình chi tiết liên hệ giống iOS Messages
/// (mở khi bấm vào tên/avatar trên thanh điều hướng của ChatView)
struct ContactDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var conversation: Conversation

    @State private var hideAlerts = false

    var body: some View {
        NavigationStack {
            List {
                // ── Header: avatar + tên + nút hành động ─────────────
                Section {
                    VStack(spacing: 10) {
                        AvatarView(
                            initials: conversation.avatarInitials,
                            color: conversation.avatarColor,
                            size: 80
                        )
                        Text(conversation.contactName)
                            .font(.system(size: 26, weight: .semibold))

                        HStack(spacing: 24) {
                            actionButton(icon: "phone.fill")
                            actionButton(icon: "video.fill")
                            actionButton(icon: "envelope.fill", disabled: true)
                        }
                        .padding(.top, 6)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                }

                // ── Số điện thoại ─────────────────────────────────────
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text("điện thoại")
                                    .font(.system(size: 15))
                                Text("GẦN ĐÂY")
                                    .font(.system(size: 10, weight: .semibold))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .foregroundStyle(.secondary)
                            }
                            Text(conversation.contactPhone.isEmpty
                                 ? conversation.contactName
                                 : conversation.contactPhone)
                                .font(.system(size: 17))
                                .foregroundStyle(.primary)
                        }
                        Spacer()
                        Image(systemName: "phone")
                            .foregroundStyle(.secondary)
                    }
                }

                // ── Tạo liên hệ ───────────────────────────────────────
                Section {
                    Button("Tạo liên hệ mới") {}
                        .foregroundStyle(.blue)
                    Button("Thêm vào liên hệ có sẵn") {}
                        .foregroundStyle(.blue)
                }

                // ── Đường dây hội thoại ───────────────────────────────
                Section {
                    HStack {
                        Text("Đường dây hội thoại")
                            .font(.system(size: 17))
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "c.square.fill")
                                .foregroundStyle(.secondary)
                            Text("Chính")
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .font(.system(size: 16))
                    }
                }

                // ── Ẩn cảnh báo ───────────────────────────────────────
                Section {
                    Toggle("Ẩn cảnh báo", isOn: $hideAlerts)
                }

                // ── Chặn liên hệ ──────────────────────────────────────
                Section {
                    Button("Chặn liên hệ") {}
                        .foregroundStyle(.red)
                } footer: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cuộc hội thoại này không được mã hóa.")
                        Text("Tìm hiểu thêm...")
                            .foregroundStyle(.blue)
                    }
                    .font(.system(size: 13))
                }
            }
            .listSectionSpacing(16)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: 34, height: 34)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    func actionButton(icon: String, disabled: Bool = false) -> some View {
        Button {} label: {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(disabled ? Color(.systemGray3) : .primary)
                .frame(width: 56, height: 40)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .disabled(disabled)
    }
}
