import SwiftUI

struct ChatView: View {
    @EnvironmentObject var viewModel: ChatViewModel

    var body: some View {
        List(viewModel.messages) { message in
            ChatMessageView(message: message)
        }
    }
}
