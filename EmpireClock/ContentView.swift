import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

struct ContentView: View {
    @State private var now = Date()
    @StateObject private var ipLocation = IPLocationFetcher()

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: now)
    }

    func copyToPasteboard() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(formattedTime, forType: .string)
        #elseif os(iOS)
        UIPasteboard.general.string = formattedTime
        #endif
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                let fontSize = geometry.size.width * 0.04

                VStack {
                    Text(ipLocation.location)
                        .font(.system(
                            size: fontSize,
                            weight: .light,
                            design: .default
                        ))
                        .foregroundColor(.gray)
                    Text(formattedTime)
                        .lineLimit(1) // single-line
                        .minimumScaleFactor(0.2) // shrink if needed
                        .truncationMode(.tail)
                        .padding(.horizontal, geometry.size.width * 0.05)
                        .font(.system(
                            size: fontSize,
                            weight: .medium,
                            design: .default
                        ))
                        .foregroundColor(.white)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                copyToPasteboard()
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                now = Date()
            }
        }
    }
}
