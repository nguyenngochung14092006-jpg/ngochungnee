# MessagesUI — iOS App Clone

Dự án SwiftUI/SwiftData clone ứng dụng Tin nhắn iOS, giao diện giống hệt video `IMG_0605.MP4`.

## Chức năng (giống IPA gốc)

| Tính năng | Mô tả |
|---|---|
| **ConversationListView** | Danh sách cuộc hội thoại, large title, unread dot, filter tab |
| **ChatView** | Bong bóng xanh lá (gửi) / xám (nhận), typing indicator, auto-scroll |
| **NewMessageView** | Soạn tin nhắn mới với gợi ý liên hệ |
| **ChatConfigView** | Cấu hình tự động trả lời từng cuộc hội thoại |
| **AutoReplyService** | Khớp từ khóa + template (MobiFone/Viettel/ShopeePay) + delay |
| **SampleData** | Seed data: VinaPhone, VNSKY, 888, 1414, Việt Anh, Google, ShopeePay... |

## Cấu trúc thư mục

```
MessagesUI_Swift/
├── project.yml                    # XcodeGen config
└── Sources/
    ├── MessagesUIApp.swift
    ├── ContentView.swift
    ├── Models/
    │   ├── Conversation.swift     # SwiftData model
    │   ├── Message.swift
    │   └── ReplyRule.swift
    ├── Services/
    │   ├── AutoReplyService.swift # Engine tự động trả lời
    │   └── SampleData.swift      # Dữ liệu mẫu (MobiFone/Viettel/v.v.)
    ├── Views/
    │   ├── ConversationListView.swift
    │   ├── ChatView.swift
    │   ├── NewMessageView.swift
    │   ├── ChatConfigView.swift
    │   ├── MessageBubbleView.swift
    │   ├── MessageSeparatorView.swift
    │   └── Components/
    │       └── AvatarView.swift
    └── Assets.xcassets/
```

## Cách build IPA trên Mac

### Bước 1: Chuyển thư mục sang Mac
Copy toàn bộ thư mục `MessagesUI_Swift` sang Mac (AirDrop, USB, hoặc iCloud Drive).

### Bước 2: Cài XcodeGen
```bash
brew install xcodegen
```

### Bước 3: Generate Xcode project
```bash
cd MessagesUI_Swift
xcodegen generate
```

Lệnh này tạo ra file `MessagesUI.xcodeproj`.

### Bước 4: Mở và cấu hình trong Xcode
```bash
open MessagesUI.xcodeproj
```

Trong Xcode:
1. Chọn target `MessagesUI` → **Signing & Capabilities**
2. Chọn **Team** của bạn (cần Apple ID — free hay paid đều được)
3. Đổi **Bundle Identifier** nếu muốn: `com.yourname.MessagesUI`

### Bước 5: Build IPA

#### Option A — Chạy thẳng trên iPhone (kết nối USB):
- Chọn device iPhone của bạn trong Xcode
- Nhấn **Run** (⌘R)

#### Option B — Export IPA file:
1. **Product → Archive** (cần chọn device, không phải simulator)
2. Sau khi archive xong → **Distribute App**
3. Chọn **Ad Hoc** hoặc **Development**
4. Export → thu được file `.ipa`

#### Option C — Build không cần Mac (AltStore / Sideloadly):
1. Chạy **Product → Archive** trên Mac
2. Distribute App → **Development**
3. Dùng [Sideloadly](https://sideloadly.io/) hoặc [AltStore](https://altstore.io/) để cài IPA lên iPhone

## Yêu cầu

- macOS 14+ (Sonoma)
- Xcode 15+
- iOS 17+ trên thiết bị
- Apple ID (miễn phí hoặc Developer Program)

## Auto-Reply Flow

Khi người dùng gửi tin nhắn:
1. `AutoReplyService.process()` được gọi
2. Khớp theo thứ tự: **Keyword Rules** → **Template** → **Fallback**
3. Hiện **typing indicator** (3 chấm nhảy)
4. Sau `replyDelay` giây → gửi tin nhắn phản hồi tự động

Ví dụ (giống video):
- Contact **1414**, gửi `TTTB` → sau 2.5s nhận được thông tin VNeID
- Template **Viettel**: tự động phản hồi tra cứu thông tin thuê bao
