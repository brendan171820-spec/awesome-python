import SwiftUI

struct OnboardingChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic gradient background based on theme
                LinearGradient(
                    colors: viewModel.themeColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5), value: viewModel.themeColors)

                VStack(spacing: 0) {
                    // Header
                    header

                    // Chat messages
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message)
                                        .id(message.id)
                                }
                                if viewModel.isLoading {
                                    TypingIndicator()
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            withAnimation {
                                proxy.scrollTo(viewModel.messages.last?.id)
                            }
                        }
                    }

                    // Input bar
                    inputBar
                }
            }
            .navigationBarHidden(true)
        }
        .task { await viewModel.startConversation() }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("HomeScreen AI")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Designing your perfect screen...")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            if viewModel.isReadyToGenerate {
                Button("Generate") {
                    Task { await viewModel.generateTheme() }
                }
                .buttonStyle(.borderedProminent)
                .tint(.white.opacity(0.3))
                .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Reply...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .cornerRadius(22)
                .focused($isInputFocused)

            Button {
                guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                let text = inputText
                inputText = ""
                Task { await viewModel.send(text) }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }
            .disabled(viewModel.isLoading || inputText.isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.role == .assistant {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .frame(width: 28, height: 28)
                    .background(.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer(minLength: message.role == .user ? 60 : 0)

            Text(message.content)
                .font(.body)
                .foregroundColor(message.role == .user ? .white : .white.opacity(0.95))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    message.role == .user
                        ? AnyView(Color.white.opacity(0.25))
                        : AnyView(Color.black.opacity(0.2))
                )
                .cornerRadius(18)

            Spacer(minLength: message.role == .assistant ? 60 : 0)
        }
        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
    }
}

struct TypingIndicator: View {
    @State private var phase = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3) { i in
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.white.opacity(i == phase ? 1 : 0.4))
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onReceive(timer) { _ in phase = (phase + 1) % 3 }
    }
}
