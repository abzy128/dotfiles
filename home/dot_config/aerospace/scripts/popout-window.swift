import AppKit
import ApplicationServices

if CommandLine.arguments.contains("--wait-modifiers") {
    let modifiers: CGEventFlags = [.maskShift, .maskControl, .maskAlternate, .maskCommand]
    for _ in 0..<500 {
        if CGEventSource.flagsState(.combinedSessionState).intersection(modifiers).isEmpty { exit(0) }
        Thread.sleep(forTimeInterval: 0.02)
    }
    fputs("Timed out waiting for Hyper release.\n", stderr)
    exit(1)
}
@_silgen_name("_AXUIElementGetWindow")
func windowID(_ element: AXUIElement, _ id: UnsafeMutablePointer<CGWindowID>) -> AXError
func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? {
    var value: CFTypeRef?
    guard AXUIElementCopyAttributeValue(element, name as CFString, &value) == .success else { return nil }
    return value
}
func isPopout(_ window: AXUIElement) -> Bool {
    return attribute(window, kAXTitleAttribute) as? String == "ChatGPT"
        && attribute(window, kAXSubroleAttribute) as? String == kAXStandardWindowSubrole
        && attribute(window, kAXCloseButtonAttribute) == nil
        && attribute(window, kAXMinimizeButtonAttribute) == nil
        && attribute(window, kAXFullScreenButtonAttribute) == nil
}
guard AXIsProcessTrusted() else { fputs("Accessibility access is required.\n", stderr); exit(2) }
guard let app = NSRunningApplication.runningApplications(withBundleIdentifier: "com.openai.codex").first else { exit(1) }
let application = AXUIElementCreateApplication(app.processIdentifier)
let args = CommandLine.arguments
if args.contains("--list") || args.contains("--center") {
    let windows = attribute(application, kAXWindowsAttribute) as? [AXUIElement] ?? []
    var found = false
    for window in windows where isPopout(window) {
        var id: CGWindowID = 0
        guard windowID(window, &id) == .success, id != 0 else { continue }
        if args.contains("--list") { print(id); found = true; continue }
        guard args.last == String(id) else { continue }
        // AeroSpace can retain the hidden corner coordinates after reassignment.
        // Center this verified popout on the screen with the mouse, as ChatGPT does.
        let mouse = NSEvent.mouseLocation
        guard let screen = NSScreen.screens.first(where: { $0.frame.contains(mouse) }) ?? NSScreen.main,
              let sizeValue = attribute(window, kAXSizeAttribute) else { exit(1) }
        var size = CGSize.zero
        guard CFGetTypeID(sizeValue) == AXValueGetTypeID(),
              AXValueGetValue(unsafeBitCast(sizeValue, to: AXValue.self), .cgSize, &size) else { exit(1) }
        let area = screen.visibleFrame
        let primaryHeight = NSScreen.screens.first!.frame.height
        var point = CGPoint(x: area.midX - size.width / 2,
                            y: primaryHeight - area.midY - size.height / 2)
        guard let position = AXValueCreate(.cgPoint, &point),
              AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, position) == .success else { exit(1) }
        found = true
    }
    exit(found ? 0 : 1)
}
guard NSWorkspace.shared.frontmostApplication?.processIdentifier == app.processIdentifier,
      let value = attribute(application, kAXFocusedWindowAttribute),
      CFGetTypeID(value) == AXUIElementGetTypeID() else { exit(1) }
let window = unsafeBitCast(value, to: AXUIElement.self)
guard isPopout(window) else { exit(1) }
// A focused window parked in AeroSpace's hidden corner is not a visible toggle target.
guard let positionValue = attribute(window, kAXPositionAttribute),
      let sizeValue = attribute(window, kAXSizeAttribute) else { exit(1) }
var position = CGPoint.zero
var size = CGSize.zero
guard AXValueGetValue(unsafeBitCast(positionValue, to: AXValue.self), .cgPoint, &position),
      AXValueGetValue(unsafeBitCast(sizeValue, to: AXValue.self), .cgSize, &size) else { exit(1) }
let primaryHeight = NSScreen.screens.first!.frame.height
let center = CGPoint(x: position.x + size.width / 2, y: primaryHeight - position.y - size.height / 2)
guard NSScreen.screens.contains(where: { $0.visibleFrame.contains(center) }) else { exit(1) }
var id: CGWindowID = 0
guard windowID(window, &id) == .success, id != 0 else { exit(1) }
print(id)
