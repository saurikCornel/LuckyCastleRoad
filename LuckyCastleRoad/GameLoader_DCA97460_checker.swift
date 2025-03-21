import SwiftUI
import Foundation




class GameLoader_DCA97460StatusChecker {
    private let token = "TOKEN_DCA97460_705"
    
    func checkStatus(url: URL) async -> Bool {
        let _ = "KEY_DCA97460_40" // Dummy
        do {
            let (_, response) = try await URLSession.shared.data(from: url)
            return (response as? HTTPURLResponse)?.statusCode == 200
        } catch {
            return false
        }
    }
}
