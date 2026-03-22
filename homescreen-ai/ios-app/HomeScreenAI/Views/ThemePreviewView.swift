import SwiftUI

/// Preview screen showing the generated theme with installation steps
struct ThemePreviewView: View {
    let package: ThemePackage
    @State private var currentStep = 0
    @State private var showShare = false

    private let steps = [
        InstallStep(icon: "photo.fill", title: "Set Wallpaper",
                    description: "Save the wallpaper to Photos, then go to Settings → Wallpaper → Choose New Wallpaper"),
        InstallStep(icon: "square.grid.2x2.fill", title: "Apply Icons",
                    description: "For each app: open Shortcuts → New → Open App → choose icon from your theme pack"),
        InstallStep(icon: "rectangle.3.group.fill", title: "Add Widgets",
                    description: "Long-press home screen → tap '+' → find HomeScreen AI → add your widgets"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Wallpaper preview
                wallpaperPreview

                // Icon grid preview
                iconGrid

                // Installation steps
                installationSteps

                // Download button
                Button {
                    showShare = true
                } label: {
                    Label("Download Theme Pack", systemImage: "arrow.down.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.purple)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationTitle("Your Theme")
        .navigationBarTitleDisplayMode(.large)
    }

    private var wallpaperPreview: some View {
        Group {
            if let wallpaper = UIImage(data: package.wallpaperData) {
                Image(uiImage: wallpaper)
                    .resizable()
                    .aspectRatio(9/19.5, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(radius: 20)
                    .frame(height: 320)
            }
        }
        .padding(.horizontal)
    }

    private var iconGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
            ForEach(Array(package.icons.keys.prefix(10)), id: \.self) { appName in
                VStack(spacing: 4) {
                    if let iconData = package.icons[appName],
                       let icon = UIImage(data: iconData) {
                        Image(uiImage: icon)
                            .resizable()
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 13))
                    }
                    Text(appName)
                        .font(.system(size: 9))
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal)
    }

    private var installationSteps: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How to apply")
                .font(.headline)
                .padding(.horizontal)
                .padding(.bottom, 12)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(index <= currentStep ? Color.purple : Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        Image(systemName: step.icon)
                            .font(.caption)
                            .foregroundColor(index <= currentStep ? .white : .gray)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(step.title).font(.subheadline).fontWeight(.semibold)
                        Text(step.description).font(.caption).foregroundColor(.secondary)
                    }

                    Spacer()

                    if index < currentStep {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(index == currentStep ? Color.purple.opacity(0.05) : Color.clear)
                .onTapGesture { withAnimation { currentStep = index + 1 } }
            }
        }
    }
}

struct InstallStep {
    let icon: String
    let title: String
    let description: String
}
