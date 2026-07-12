import SwiftUI
import SwiftData

/// ChatConfigView — màn hình cấu hình tự động trả lời cho từng cuộc hội thoại
/// Giống ChatConfigView.swift trong IPA gốc
struct ChatConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var conversation: Conversation

    @State private var newTrigger = ""
    @State private var newReply = ""
    @State private var showAddRule = false

    var body: some View {
        NavigationStack {
            List {
                // ── Contact Info ─────────────────────────────────────
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            AvatarView(
                                initials: conversation.avatarInitials,
                                color: conversation.avatarColor,
                                size: 72
                            )
                            Text(conversation.contactName)
                                .font(.system(size: 22, weight: .semibold))
                            Text(conversation.contactPhone)
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
                }

                // ── Auto Reply Toggle ─────────────────────────────────
                Section("Tự động trả lời") {
                    Toggle("Bật tự động trả lời", isOn: $conversation.autoReplyEnabled)

                    if conversation.autoReplyEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Độ trễ phản hồi: \(String(format: "%.1f", conversation.replyDelay))s")
                                .font(.system(size: 15))
                            Slider(value: $conversation.replyDelay, in: 0.5...10.0, step: 0.5)
                                .tint(.primary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                // ── Template Selector ─────────────────────────────────
                if conversation.autoReplyEnabled {
                    Section("Mẫu tin nhắn") {
                        ForEach(TemplateType.allCases, id: \.self) { type in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(type.rawValue)
                                        .font(.system(size: 16))
                                    Text(templateDescription(type))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if conversation.templateType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.primary)
                                        .fontWeight(.semibold)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                conversation.templateType = type
                            }
                        }
                    }

                    // ── Fallback Reply ────────────────────────────────
                    Section("Phản hồi mặc định (nếu không khớp)") {
                        TextField("Nhập nội dung phản hồi...", text: $conversation.fallbackReply, axis: .vertical)
                            .font(.system(size: 15))
                            .lineLimit(3...6)
                    }

                    // ── Keyword Rules ─────────────────────────────────
                    Section {
                        ForEach(conversation.replyRules) { rule in
                            RuleRowView(rule: rule) {
                                modelContext.delete(rule)
                            }
                        }

                        // Add new rule
                        if showAddRule {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Từ khóa:")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 70, alignment: .leading)
                                    TextField("ví dụ: TTTB, OTP...", text: $newTrigger)
                                        .font(.system(size: 15))
                                }
                                HStack(alignment: .top) {
                                    Text("Trả lời:")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                        .frame(width: 70, alignment: .leading)
                                    TextField("Nội dung tự động trả lời...", text: $newReply, axis: .vertical)
                                        .font(.system(size: 15))
                                        .lineLimit(2...4)
                                }
                                HStack {
                                    Button("Huỷ") {
                                        showAddRule = false
                                        newTrigger = ""
                                        newReply = ""
                                    }
                                    .foregroundStyle(.red)
                                    Spacer()
                                    Button("Lưu") {
                                        guard !newTrigger.isEmpty, !newReply.isEmpty else { return }
                                        let rule = ReplyRule(trigger: newTrigger, reply: newReply)
                                        rule.conversation = conversation
                                        conversation.replyRules.append(rule)
                                        modelContext.insert(rule)
                                        newTrigger = ""
                                        newReply = ""
                                        showAddRule = false
                                    }
                                    .fontWeight(.semibold)
                                    .disabled(newTrigger.isEmpty || newReply.isEmpty)
                                }
                                .font(.system(size: 15))
                            }
                            .padding(.vertical, 4)
                        }
                    } header: {
                        HStack {
                            Text("Quy tắc từ khóa (\(conversation.replyRules.count))")
                            Spacer()
                            Button("+ Thêm") {
                                showAddRule = true
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.primary)
                        }
                    }
                }

                // ── Danger Zone ───────────────────────────────────────
                Section {
                    Button(role: .destructive) {
                        conversation.messages.removeAll()
                        dismiss()
                    } label: {
                        Label("Xóa tất cả tin nhắn", systemImage: "trash")
                    }
                }
            }
            .navigationTitle("Cấu hình cuộc hội thoại")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Xong") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    func templateDescription(_ type: TemplateType) -> String {
        switch type {
        case .none: return "Chỉ dùng quy tắc từ khóa"
        case .mobifone: return "Gia hạn, nạp tiền, khuyến mãi MobiFone"
        case .viettel: return "Chuẩn hóa TTTB, tra cứu thuê bao"
        case .shopeepay: return "OTP, thanh toán SPayLater"
        case .custom: return "Tùy chỉnh hoàn toàn"
        }
    }
}

// MARK: - Rule Row

struct RuleRowView: View {
    @Bindable var rule: ReplyRule
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("", isOn: $rule.isEnabled)
                .labelsHidden()
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text("Từ khóa:")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text(rule.trigger)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(rule.isEnabled ? .primary : .secondary)
                }
                Text(rule.reply)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }
}
