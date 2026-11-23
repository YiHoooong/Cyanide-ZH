//
//  PowerControls.swift
//  CyanideControls
//
//  Control Center buttons for Respring and Reboot (iOS 18+). A respring or
//  reboot has no on/off state to show, so these are buttons rather than
//  toggles. Tapping one opens Cyanide, which runs the request at once.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct RespringControl: ControlWidget {
    static let kind = "com.zeroxjf.ios-cyanide1.controls.respring"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: RespringIntent()) {
                Label("Respring", systemImage: "arrow.clockwise.circle.fill")
            }
        }
        .displayName("Respring")
        .description("通过 Cyanide 重启 SpringBoard。")
    }
}

@available(iOS 18.0, *)
struct RebootControl: ControlWidget {
    static let kind = "com.zeroxjf.ios-cyanide1.controls.reboot"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: RebootIntent()) {
                Label("Reboot", systemImage: "power.circle.fill")
            }
        }
        .displayName("Reboot")
        .description("通过 Cyanide 重启设备。需要之前运行留下的内核访问。")
    }
}

@available(iOS 18.0, *)
struct CarPlayControl: ControlWidget {
    static let kind = "com.zeroxjf.ios-cyanide1.controls.carplay"

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind) {
            ControlWidgetButton(action: UnlockCarPlayIntent()) {
                Label("CarPlay", systemImage: "car.fill")
            }
        }
        .displayName("无 Siri 使用 CarPlay")
        .description("让 CarPlay 在 Siri 关闭时启动（仅当前连接）。")
    }
}
