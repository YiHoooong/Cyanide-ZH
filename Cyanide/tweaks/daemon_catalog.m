//
//  daemon_catalog.m
//

#import "daemon_catalog.h"

@interface CYDaemonGroup ()
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *symbol;
@property (nonatomic, copy) NSArray<NSString *> *labels;
@property (nonatomic, copy) NSString *caution;
@property (nonatomic) BOOL advanced;
@end

@implementation CYDaemonGroup
@end

static CYDaemonGroup *group(NSString *identifier, NSString *title, NSString *symbol, NSString *summary,
                            NSString *caution, NSArray<NSString *> *labels)
{
    CYDaemonGroup *g = [CYDaemonGroup new];
    g.identifier = identifier;
    g.title = title;
    g.symbol = symbol;
    g.summary = summary;
    g.caution = caution;
    g.labels = labels;
    return g;
}

static CYDaemonGroup *advanced(NSString *identifier, NSString *title, NSString *symbol, NSString *summary,
                               NSString *caution, NSArray<NSString *> *labels)
{
    CYDaemonGroup *g = group(identifier, title, symbol, summary, caution, labels);
    g.advanced = YES;
    return g;
}

NSArray<CYDaemonGroup *> *daemon_catalog_groups(void)
{
    static NSArray<CYDaemonGroup *> *groups;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        groups = @[
            group(@"ota", @"软件更新", @"arrow.down.circle",
                  @"iOS 停止检查和下载更新。与 OTA 更新同一个开关。", nil,
                  @[ @"com.apple.mobile.softwareupdated", @"com.apple.OTATaskingAgent",
                     @"com.apple.softwareupdateservicesd", @"com.apple.mobile.NRDUpdated" ]),
            group(@"usage", @"使用情况追踪", @"chart.bar",
                  @"停止收集应用使用统计。", nil,
                  @[ @"com.apple.UsageTrackingAgent" ]),
            group(@"screentime", @"屏幕使用时间", @"hourglass",
                  @"屏幕使用时间限制、购买请求和家庭共享请求停止工作。", nil,
                  @[ @"com.apple.ScreenTimeAgent", @"com.apple.familycircled",
                     @"com.apple.familynotification", @"com.apple.asktod" ]),
            group(@"gamecenter", @"Game Center", @"gamecontroller",
                  @"Game Center 登录、成就和排行榜停止工作。", nil,
                  @[ @"com.apple.gamed" ]),
            group(@"tips", @"Tips", @"lightbulb",
                  @"不再有“提示”通知。", nil,
                  @[ @"com.apple.tipsd" ]),
            group(@"followup", @"设置建议", @"exclamationmark.bubble",
                  @"移除“完成 iPhone 设置”之类的设置建议。", nil,
                  @[ @"com.apple.followupd" ]),
            group(@"wapi", @"中国无线局域网（WAPI）", @"wifi",
                  @"主要用于中国的 WAPI 网络将无法再加入。", nil,
                  @[ @"com.apple.wifi.wapic" ]),
            group(@"vpn", @"IPsec VPN", @"lock.shield",
                  @"内置的 IPsec（IKEv1）VPN 停止工作。VPN 应用不受影响。", nil,
                  @[ @"com.apple.racoon" ]),
            group(@"assistivetouch", @"AssistiveTouch", @"circle.circle",
                  @"辅助触控按钮停止工作。", nil,
                  @[ @"com.apple.assistivetouchd" ]),
            group(@"hotspot", @"个人热点", @"personalhotspot",
                  @"共享蜂窝连接停止工作。", nil,
                  @[ @"com.apple.MobileInternetSharing" ]),
            group(@"watchface", @"表盘同步", @"applewatch",
                  @"Apple Watch 表盘不再从此 iPhone 同步。", nil,
                  @[ @"com.apple.nanotimekitcompaniond" ]),
            group(@"musiccloud", @"音乐云资料库", @"music.note",
                  @"Apple Music / iTunes 云资料库同步停止。", nil,
                  @[ @"com.apple.itunescloudd" ]),
            advanced(@"diagnostics", @"Diagnostics", @"stethoscope",
                  @"硬件与性能诊断停止，包括 sysdiagnose。", nil,
                  @[ @"com.apple.diagnosticd", @"com.apple.diagnosticextensionsd",
                     @"com.apple.diagnosticservicesd", @"com.apple.diagnosticspushd",
                     @"com.apple.symptomsd-diag", @"com.apple.sysdiagnose",
                     @"com.apple.sysdiagnose_helper" ]),
            advanced(@"crashreports", @"日志与崩溃报告", @"doc.text.magnifyingglass",
                  @"系统日志和崩溃报告停止。",
                  @"不再保存崩溃与重启日志，运行失败导致的重启将无法诊断。报告问题前请重新打开此项。",
                  @[ @"com.apple.ReportCrash", @"com.apple.ReportMemoryException", @"com.apple.OTACrashCopier",
                     @"com.apple.analyticsd", @"com.apple.wifianalyticsd", @"com.apple.aslmanager",
                     @"com.apple.coresymbolicationd", @"com.apple.crash_mover",
                     @"com.apple.crashreportcopymobile", @"com.apple.DumpBasebandCrash",
                     @"com.apple.DumpPanic", @"com.apple.logd", @"com.apple.logd_helper",
                     @"com.apple.logd_reporter", @"com.apple.hangreporter", @"com.apple.hangtracerd",
                     @"com.apple.spindump", @"com.apple.tailspind", @"com.apple.rtcreportingd",
                     @"com.apple.syslogd", @"com.apple.signpost.signpost_reporter",
                     @"com.apple.pluginkit.pkreporter", @"com.apple.ProxiedCrashCopier.ProxyingDevice", @"com.apple.ReportSystemMemory" ]),
            advanced(@"spotlight", @"Spotlight", @"magnifyingglass",
                  @"从主屏和应用内搜索停止工作。",
                  @"Spotlight 搜索、应用内搜索和 Siri 建议停止工作。",
                  @[ @"com.apple.searchd", @"com.apple.corespotlightservice",
                     @"com.apple.spotlightknowledged", @"com.apple.spotlightknowledged.updater",
                     @"com.apple.spotlight.IndexAgent" ]),
            advanced(@"siri", @"Siri 与听写", @"waveform",
                  @"Siri、语音控制和听写停止工作。",
                  @"Siri、“嘿 Siri”、语音控制和键盘听写停止工作。",
                  @[ @"com.apple.assistant_service", @"com.apple.assistantd", @"com.apple.voiced" ]),
            advanced(@"health", @"HealthKit", @"heart",
                  @"健康应用和使用健康数据的应用停止更新。",
                  @"健康数据停止记录和同步，包括来自 Apple Watch 的。",
                  @[ @"com.apple.healthd" ]),
            advanced(@"wallet", @"Wallet", @"wallet.pass",
                  @"钱包凭证和 Apple Pay 停止工作。",
                  @"Apple Pay、交通卡、车钥匙和所有钱包凭证停止工作。",
                  @[ @"com.apple.passd" ]),
            advanced(@"location", @"定位服务", @"location",
                  @"GPS 和一切需要定位的功能停止工作。",
                  @"地图、查找、天气、基于位置的提醒以及 Cyanide 的定位服务开关停止工作。",
                  @[ @"com.apple.locationd" ]),
            advanced(@"thermal", @"温度监控", @"thermometer.medium",
                  @"设备发热时 iOS 不再降低性能。",
                  @"没有 thermalmonitord 时 iOS 不再在发热时降频。高负载下设备可能非常烫；硬件在临界温度仍会关机。",
                  @[ @"com.apple.thermalmonitord" ]),
        ];
    });
    return groups;
}

// These labels were in Cyanide's older catalog, but were removed after the
// iOS 17/18 launchd job audit. Keep this list explicit and finite: persisted
// entries for these labels can be recovered, while arbitrary plist keys never
// become an in-app write route.
static NSArray<NSString *> *daemon_catalog_legacy_labels(void)
{
    static NSArray<NSString *> *labels;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        labels = @[
            @"com.apple.atc.atwakeup",
            @"com.apple.wapic",
            @"com.apple.printd",
            @"com.apple.sysdiagnose.darwinos",
            @"com.apple.ReportCrash.Jetsam",
            @"com.apple.logd.admin",
            @"com.apple.logd.events",
            @"com.apple.logd.watchdog",
            @"com.apple.logd_reporter.report_statistics",
            @"com.apple.system.logger",
            @"com.apple.ProxiedCrashCopier",
        ];
    });
    return labels;
}

BOOL daemon_catalog_contains_label(NSString *label)
{
    static NSSet<NSString *> *all;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSMutableSet *s = [NSMutableSet set];
        for (CYDaemonGroup *g in daemon_catalog_groups()) [s addObjectsFromArray:g.labels];
        all = s;
    });
    return [label isKindOfClass:NSString.class] && [all containsObject:label];
}

BOOL daemon_catalog_is_legacy_label(NSString *label)
{
    static NSSet<NSString *> *legacy;
    static dispatch_once_t once;
    dispatch_once(&once, ^{ legacy = [NSSet setWithArray:daemon_catalog_legacy_labels()]; });
    return [label isKindOfClass:NSString.class] && [legacy containsObject:label];
}

BOOL daemon_catalog_change_is_allowed(NSString *label, BOOL disable)
{
    if (daemon_catalog_contains_label(label)) return YES;
    // Legacy rows are recovery-only. In particular, do not let an arbitrary
    // persisted key or a fabricated UI request become a new disabled entry.
    return !disable && daemon_catalog_is_legacy_label(label);
}

CYDaemonGroup *daemon_catalog_legacy_recovery_group(NSDictionary *disabled)
{
    if (![disabled isKindOfClass:NSDictionary.class]) return nil;
    NSMutableArray<NSString *> *present = [NSMutableArray array];
    for (NSString *label in daemon_catalog_legacy_labels()) {
        id value = disabled[label];
        if ([value isKindOfClass:NSNumber.class] && [value boolValue]) [present addObject:label];
    }
    if (!present.count) return nil;
    return advanced(@"legacy-recovery", @"旧版已禁用服务", @"arrow.uturn.backward.circle",
                    @"旧版 Cyanide 可以禁用这些标签。此系统上未检测其任务是否存在；把它们打开即可移除持久化的条目。",
                    nil, present);
}

NSString *daemon_catalog_executable_guess(NSString *label)
{
    static NSDictionary<NSString *, NSString *> *known;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        known = @{
            @"com.apple.ProxiedCrashCopier.ProxyingDevice": @"ProxiedCrashCopier",
            @"com.apple.spotlightknowledged.updater": @"spotlightknowledged",
        };
    });
    return known[label] ?: [label componentsSeparatedByString:@"."].lastObject;
}
