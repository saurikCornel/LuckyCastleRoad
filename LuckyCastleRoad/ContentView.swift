//
//  ContentView.swift
//  LuckyCastleRoad
//
//  Created by alex on 3/21/25.
//

import SwiftUI

struct ContentView: View {
    let url: URL = .init(string: "https://luckycastleroad.top/play/")!
    var body: some View {
        GameLoaderPanel(ctrl: .init(url: url))
            .background(Color(hex: "#27143a").ignoresSafeArea())
    }
}



extension Color {
    init?(hex: String) {
        // Trim any leading or trailing whitespace and newlines
        let trimmedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove the "#" prefix if present
        let cleanedHex = trimmedHex.hasPrefix("#") ? String(trimmedHex.dropFirst()) : trimmedHex
        
        // Ensure the hex string is either 3 or 6 characters long
        guard cleanedHex.count == 3 || cleanedHex.count == 6 else {
            return nil
        }
        
        let finalHex: String
        if cleanedHex.count == 3 {
            // Expand 3-character hex (e.g., "FFF" to "FFFFFF")
            finalHex = cleanedHex.map { String($0) + String($0) }.joined()
        } else {
            // Use the 6-character hex as is
            finalHex = cleanedHex
        }
        
        // Scan the hex string into a UInt32 value
        let scanner = Scanner(string: finalHex)
        var value: UInt32 = 0
        guard scanner.scanHexInt32(&value) else {
            return nil
        }
        
        // Extract red, green, and blue components and normalize to [0, 1]
        let red = Double((value >> 16) & 0xFF) / 255.0
        let green = Double((value >> 8) & 0xFF) / 255.0
        let blue = Double(value & 0xFF) / 255.0
        
        // Initialize the Color with RGB values
        self.init(red: red, green: green, blue: blue)
    }
}

#Preview {
    ContentView()
}
