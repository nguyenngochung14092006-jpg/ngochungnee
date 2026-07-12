import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Conversation.lastMessageDate, order: .reverse) private var conversations: [Conversation]
    @State private var selectedConversation: Conversation?
    @State private var showNewMessage = false
    @State private var hasSeeded = false

    var body: some View {
        NavigationStack {
            ConversationListView(
                selectedConversation: $selectedConversation,
                showNewMessage: $showNewMessage
            )
        }
        .onAppear {
            if !hasSeeded && conversations.isEmpty {
                SampleData.seed(context: modelContext)
                hasSeeded = true
            }
        }
    }
}
