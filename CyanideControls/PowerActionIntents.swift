//
//  PowerActionIntents.swift
//  CyanideControls + Cyanide
//
//  Respring and Reboot actions for Shortcuts, Siri, the Action button and
//  the Control Center buttons (PowerControls.swift). Compiled into both the
//  extension and the app: with openAppWhenRun, iOS opens Cyanide and runs
//  perform() there, which hands the request to the same handler as the
//  cyanide://respring and cyanide://reboot links. Unlike those links, these
//  need no setting: iOS only runs them for the user's own shortcuts and
//  controls.
//

import AppIntents

struct RespringIntent: AppIntent {
    static let title: LocalizedStringResource = "Respring"
    static let description = IntentDescription("打开 Cyanide 以重启 SpringBoard。实时插件会先停止。")
    static let openAppWhenRun: Bool = true

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        try await CyanideLocationRequest.runURL("cyanide://respring",
                                                timeoutMessage: "重加载耗时比预期长。")
        return .result()
    }
}

struct RebootIntent: AppIntent {
    static let title: LocalizedStringResource = "Reboot"
    static let description = IntentDescription("打开 Cyanide 以重启设备。需要之前 Cyanide 运行留下的内核访问。")
    static let openAppWhenRun: Bool = true

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        try await CyanideLocationRequest.runURL("cyanide://reboot",
                                                timeoutMessage: "重启耗时比预期长。")
        return .result()
    }
}

// CarPlay without Siri: lifts iOS 18's "To use CarPlay, enable Siri" lock-out
// for the current connection. Meant for a "When CarPlay connects" automation
// in Shortcuts, or the Control Center button. The tweak must be on in
// Cyanide, and kernel access from an earlier run must be live or parked.
struct UnlockCarPlayIntent: AppIntent {
    static let title: LocalizedStringResource = "无 Siri 使用 CarPlay"
    static let description = IntentDescription("打开 Cyanide，让 CarPlay 在 Siri 关闭的情况下启动（仅当前连接）。")
    static let openAppWhenRun: Bool = true

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        try await CyanideLocationRequest.runURL("cyanide://carplay",
                                                timeoutMessage: "CarPlay 耗时比预期长。")
        return .result()
    }
}
