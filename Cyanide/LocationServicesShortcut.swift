//
//  LocationServicesShortcut.swift
//  Cyanide
//
//  "定位服务" action for Shortcuts, Siri and the Action button,
//  iOS 17+ (custom Control Center controls need iOS 18; this is the iOS 17
//  way to reach the same switch). Opens Cyanide and runs the same request as
//  the Control Center toggle (CyanideLocationRequest, shared with the
//  CyanideControls extension). Lives only in the app target: the App
//  Shortcut below must be provided by the app, not the extension.
//

import AppIntents

enum LocationServicesAction: String, AppEnum {
    case toggle
    case on
    case off

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "定位服务操作"
    static let caseDisplayRepresentations: [LocationServicesAction: DisplayRepresentation] = [
        .toggle: "Toggle",
        .on: "打开",
        .off: "关闭",
    ]
}

struct LocationServicesShortcutIntent: AppIntent {
    static let title: LocalizedStringResource = "定位服务"
    static let description = IntentDescription("打开 Cyanide 以打开、关闭或切换定位服务。")
    static let openAppWhenRun: Bool = true

    @Parameter(title: "Action", default: .toggle)
    var action: LocationServicesAction

    static var parameterSummary: some ParameterSummary {
        Summary("\(\.$action) Location Services")
    }

    init() {}

    @MainActor
    func perform() async throws -> some IntentResult {
        try await CyanideLocationRequest.run(action.rawValue)
        return .result()
    }
}

// Shows the action in the Shortcuts app without any setup, and makes it
// available to Siri and the Action button.
struct CyanideAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LocationServicesShortcutIntent(),
            phrases: [
                "通过 \(.applicationName) 切换定位服务",
                "\(.applicationName) Location Services",
            ],
            shortTitle: "定位服务",
            systemImageName: "location.fill"
        )
        AppShortcut(
            intent: RespringIntent(),
            phrases: [
                "通过 \(.applicationName) 重加载",
                "\(.applicationName) Respring",
            ],
            shortTitle: "Respring",
            systemImageName: "arrow.clockwise.circle"
        )
        AppShortcut(
            intent: RebootIntent(),
            phrases: [
                "通过 \(.applicationName) 重启",
                "\(.applicationName) Reboot",
            ],
            shortTitle: "Reboot",
            systemImageName: "power"
        )
        AppShortcut(
            intent: UnlockCarPlayIntent(),
            phrases: [
                "通过 \(.applicationName) 解锁 CarPlay",
                "\(.applicationName) CarPlay",
            ],
            shortTitle: "无 Siri 使用 CarPlay",
            systemImageName: "car.fill"
        )
    }
}
