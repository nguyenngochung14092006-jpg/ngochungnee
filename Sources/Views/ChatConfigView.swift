import SwiftUI
import SwiftData

/// ChatConfigView — "Cấu hình trò chuyện" (giống hệt IPA gốc).
/// Kiểu câu trả lời: Tự viết / Mẫu 1 (MobiFone) / Mẫu 2 (Viettel).
struct ChatConfigView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var conversation: Conversation

    // Bản nháp — chỉ ghi vào model khi bấm "Lưu"
    @State private var mode: TemplateType = .custom
    @State private var trigger = ""
    @State private var customReply = ""
    @State private var name = ""
    @State private var dob = ""
    @State private var phone = ""
    @State private var cccd = ""
    @State private var ngayCap = ""
    @State private var ngayKichHoat = ""
    @State private var delay = 3.0

    private let blue = Color(red: 0.0, green: 0.48, blue: 1.0)

    var body: some View {
        NavigationStack {
            Form {
                // ── Kiểu câu trả lời ───────────────────────────────
                Section("Kiểu câu trả lời") {
                    Picker("", selection: $mode) {
                        Text("Tự viết").tag(TemplateType.custom)
                        Text("Mẫu 1").tag(TemplateType.mobifone)
                        Text("Mẫu 2").tag(TemplateType.viettel)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                }

                // ── Từ khóa ────────────────────────────────────────
                Section {
                    TextField("Từ khóa (vd: TTTB ...)", text: $trigger)
                        .font(.system(size: 17))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } footer: {
                    Text("Khi bạn gửi một tin có chứa từ khóa, người nhận sẽ tự trả lời bằng nội dung này. Để trống từ khóa nếu muốn trả lời cho mọi tin nhắn.")
                }

                // ── Cấu hình theo mẫu ──────────────────────────────
                switch mode {
                case .custom:
                    Section("Nội dung tự trả lời") {
                        TextField("Nhập nội dung...", text: $customReply, axis: .vertical)
                            .font(.system(size: 17))
                            .lineLimit(4...12)
                    }

                case .mobifone:
                    Section("Cấu hình Mẫu 1 (MobiFone)") {
                        field("Họ tên", text: $name)
                        randomField("Ngày sinh", text: $dob) { dob = MessageTemplate.randomDate(fromYear: 1970, toYear: 2005) }
                        field("Số thuê bao", text: $phone)
                        randomAllButton()
                    }

                case .viettel:
                    Section("Cấu hình Mẫu 2 (Viettel)") {
                        field("Số thuê bao", text: $phone)
                        field("Họ tên", text: $name)
                        randomField("Ngày sinh", text: $dob) { dob = MessageTemplate.randomDate(fromYear: 1970, toYear: 2005) }
                        randomField("Số căn cước", text: $cccd) { cccd = MessageTemplate.randomCCCD() }
                        randomField("Ngày cấp", text: $ngayCap) { ngayCap = MessageTemplate.randomDate(fromYear: 2016, toYear: 2023) }
                        randomField("Ngày kích hoạt", text: $ngayKichHoat) { ngayKichHoat = MessageTemplate.randomDate(fromYear: 2018, toYear: 2024) }
                        randomAllButton()
                    }

                case .shopeepay, .none:
                    EmptyView()
                }

                // ── Xem trước ──────────────────────────────────────
                Section("Xem trước tin nhắn") {
                    Text(previewText)
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                // ── Thời gian trả lời ──────────────────────────────
                Section("Thời gian trả lời") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(String(format: "%.1f", delay)) giây")
                            .font(.system(size: 15))
                        Slider(value: $delay, in: 0.5...10.0, step: 0.5)
                            .tint(.primary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Cấu hình trò chuyện")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Hủy") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Lưu") { save() }.fontWeight(.semibold)
                }
            }
        }
        .onAppear(perform: load)
    }

    // MARK: - Preview

    private var previewText: String {
        let temp = Conversation(
            contactName: "", contactPhone: "", avatarColor: "", avatarInitials: "",
            lastMessage: "", lastMessageDate: .now, isRead: true,
            autoReplyEnabled: true, replyDelay: delay, fallbackReply: "",
            templateType: mode
        )
        temp.customReply = customReply
        temp.mName = name; temp.mDob = dob; temp.mPhone = phone
        temp.mCccd = cccd; temp.mNgayCap = ngayCap; temp.mNgayKichHoat = ngayKichHoat
        let out = MessageTemplate.render(for: temp)
        return out.isEmpty ? "(chưa có nội dung)" : out
    }

    // MARK: - Row builders

    @ViewBuilder
    private func field(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .font(.system(size: 17))
    }

    @ViewBuilder
    private func randomField(_ placeholder: String, text: Binding<String>, action: @escaping () -> Void) -> some View {
        HStack {
            TextField(placeholder, text: text)
                .font(.system(size: 17))
            Spacer()
            Button("Random", action: action)
                .font(.system(size: 16))
                .foregroundStyle(blue)
        }
    }

    @ViewBuilder
    private func randomAllButton() -> some View {
        Button(action: randomizeAll) {
            Label("Tạo ngẫu nhiên thông tin", systemImage: "die.face.5.fill")
                .foregroundStyle(blue)
        }
    }

    // MARK: - Actions

    private func randomizeAll() {
        name = MessageTemplate.randomName()
        dob = MessageTemplate.randomDate(fromYear: 1970, toYear: 2005)
        phone = MessageTemplate.randomPhone()
        cccd = MessageTemplate.randomCCCD()
        ngayCap = MessageTemplate.randomDate(fromYear: 2016, toYear: 2023)
        ngayKichHoat = MessageTemplate.randomDate(fromYear: 2018, toYear: 2024)
    }

    private func load() {
        mode = (conversation.templateType == .none) ? .custom : conversation.templateType
        trigger = conversation.trigger
        customReply = conversation.customReply
        name = conversation.mName
        dob = conversation.mDob
        phone = conversation.mPhone
        cccd = conversation.mCccd
        ngayCap = conversation.mNgayCap
        ngayKichHoat = conversation.mNgayKichHoat
        delay = conversation.replyDelay > 0 ? conversation.replyDelay : 3.0
    }

    private func save() {
        conversation.autoReplyEnabled = true
        conversation.templateType = mode
        conversation.trigger = trigger.trimmingCharacters(in: .whitespacesAndNewlines)
        conversation.customReply = customReply
        conversation.mName = name
        conversation.mDob = dob
        conversation.mPhone = phone
        conversation.mCccd = cccd
        conversation.mNgayCap = ngayCap
        conversation.mNgayKichHoat = ngayKichHoat
        conversation.replyDelay = delay
        dismiss()
    }
}
