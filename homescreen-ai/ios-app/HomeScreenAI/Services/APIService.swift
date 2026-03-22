import Foundation

class APIService {
    private let baseURL = "https://api.homescreenai.app/api/v1"  // Replace with your server

    func streamChat(
        messages: [[String: String]],
        onChunk: @escaping (String) -> Void
    ) async throws {
        let url = URL(string: "\(baseURL)/chat/stream")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["messages": messages, "session_id": UUID().uuidString] as [String: Any]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (asyncBytes, response) = try await URLSession.shared.bytes(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.serverError
        }

        for try await line in asyncBytes.lines {
            guard line.hasPrefix("data: "),
                  let data = line.dropFirst(6).data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let text = json["text"] as? String else { continue }
            onChunk(text)
        }
    }

    func generateTheme(messages: [[String: String]]) async throws -> ThemePackage {
        let url = URL(string: "\(baseURL)/theme/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120  // Image generation can take time

        let commonApps = [
            "Instagram", "TikTok", "Spotify", "Messages", "Camera",
            "Settings", "Safari", "Photos", "Maps", "Notes"
        ]
        let body: [String: Any] = ["messages": messages, "app_names": commonApps]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw APIError.serverError
        }

        // The response is a ZIP file
        return try parseThemeZip(data)
    }

    private func parseThemeZip(_ data: Data) throws -> ThemePackage {
        // In production: use ZIPFoundation or similar to unzip
        // For now return a placeholder
        throw APIError.notImplemented
    }
}

enum APIError: Error {
    case serverError
    case notImplemented
    case invalidResponse
}
