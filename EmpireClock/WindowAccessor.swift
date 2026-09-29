import SwiftUI

#if os(macOS)
import AppKit

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        DispatchQueue.main.async {
            if let window = NSApplication.shared.windows.first,
               let screen = window.screen {

                let screenFrame = screen.visibleFrame
                let minWidth = screenFrame.width * 0.5
                let minHeight = screenFrame.height * 0.5

                window.setContentSize(NSSize(width: minWidth, height: minHeight))
                window.minSize = NSSize(width: minWidth, height: minHeight)
                window.center()

                window.delegate = context.coordinator
                context.coordinator.minSize = window.minSize
            }
        }
        return NSView()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class Coordinator: NSObject, NSWindowDelegate {
        var minSize = NSSize.zero
        private var cursorTimer: Timer?
        private var isCursorHidden = false

        override init() {
            super.init()
            setupMouseTracking()
        }

        private func setupMouseTracking() {
            // Monitor mouse movement and clicks globally
            NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] event in
                self?.handleMouseEvent(event)
            }

            // Also monitor local events to ensure clicks within the window are captured
            NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] event in
                self?.handleMouseEvent(event)
                return event
            }
        }

        private func handleMouseEvent(_ event: NSEvent) {
            guard let window = NSApplication.shared.windows.first else { return }

            // Convert global mouse location to screen coordinates
            let mouseLocation = NSEvent.mouseLocation
            let windowFrame = window.frame
            let isInWindow = windowFrame.contains(mouseLocation)

            if isInWindow {
                resetCursorTimer()
            } else if isCursorHidden {
                // Unhide cursor if it moves outside the window
                NSCursor.unhide()
                isCursorHidden = false
                cursorTimer?.invalidate()
            }
        }

        private func resetCursorTimer() {
            // Invalidate existing timer
            cursorTimer?.invalidate()

            // Unhide cursor if it was hidden
            if isCursorHidden {
                NSCursor.unhide()
                isCursorHidden = false
            }

            // Start a new timer for 3 seconds
            cursorTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                guard let self = self, let window = NSApplication.shared.windows.first else { return }
                let mouseLocation = NSEvent.mouseLocation
                let isInWindow = window.frame.contains(mouseLocation)

                if isInWindow && !self.isCursorHidden {
                    NSCursor.hide()
                    self.isCursorHidden = true
                }
            }
        }

        func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
            let width = max(frameSize.width, minSize.width)
            let height = max(frameSize.height, minSize.height)
            return NSSize(width: width, height: height)
        }

        func windowDidMove(_ notification: Notification) {
            // Check cursor position when window moves
            handleMouseEvent(NSEvent())
        }
        
        func windowWillClose(_ notification: Notification) {
                NSApplication.shared.terminate(nil)
            }
    }
}

#elseif os(iOS)
import UIKit

struct WindowAccessor: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            if let activeScene = windowScenes.first(where: { $0.activationState == .foregroundActive }),
               let window = activeScene.keyWindow,
               let rootView = window.rootViewController?.view {
                let screenBounds = UIScreen.main.bounds
                rootView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: screenBounds.width,
                    height: screenBounds.height
                )
            }
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
