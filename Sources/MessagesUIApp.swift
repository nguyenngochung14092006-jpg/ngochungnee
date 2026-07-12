import SwiftUI
import SwiftData

@main
struct MessagesUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Conversation.self, Message.self, ReplyRule.self])
    }
}
