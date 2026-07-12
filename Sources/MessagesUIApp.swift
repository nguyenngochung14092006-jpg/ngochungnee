import SwiftUI
import SwiftData

@main
struct MessagesUIApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Conversation.self, Message.self, ReplyRule.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Store cũ không tương thích schema mới → xóa và tạo lại
            if let url = config.url as URL? {
                try? FileManager.default.removeItem(at: url)
                try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-shm"))
                try? FileManager.default.removeItem(at: url.deletingPathExtension().appendingPathExtension("store-wal"))
            }
            container = try! ModelContainer(for: schema, configurations: [config])
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
