//
//  PackageCatalog.m
//  Cyanide
//

#import "PackageCatalog.h"
#import "../SettingsViewController.h"
#import "../tweaks/RepoTweaks.h"
#import "../tweaks/experimental_tweaks.h"

@interface Package ()
@property (nonatomic, readwrite, copy) NSString *symbolName;
@property (nonatomic, readwrite, copy) NSString *author;
@end

@implementation PackageCatalog

static NSString *catalog_string_or_empty(id value)
{
    return [value isKindOfClass:NSString.class] ? (NSString *)value : @"";
}

static NSArray<NSString *> *catalog_repotweaks_urls(NSUserDefaults *d)
{
    id raw = [d objectForKey:@"RepoTweaksURLs"];
    if (![raw isKindOfClass:NSArray.class]) return @[];
    NSMutableArray<NSString *> *urls = [NSMutableArray array];
    for (id value in (NSArray *)raw) {
        if ([value isKindOfClass:NSString.class]) [urls addObject:value];
    }
    return urls;
}

static NSDictionary *catalog_repotweaks_caches(NSUserDefaults *d)
{
    id raw = [d objectForKey:@"RepoTweaksCaches"];
    return [raw isKindOfClass:NSDictionary.class] ? (NSDictionary *)raw : @{};
}

static BOOL catalog_repo_script_requires_native_bridge(NSString *rawScript)
{
    if (![rawScript isKindOfClass:NSString.class] || rawScript.length == 0) return NO;
    return [rawScript containsString:@"nativeCallBuff"] ||
           [rawScript containsString:@"runOnMainEvaluate"] ||
           [rawScript containsString:@"Native.callSymbol"];
}

+ (NSArray<Package *> *)repoPackages
{
    if (!repotweaks_sources_enabled()) return @[];
    repotweaks_seed_default_repos();

    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    NSDictionary *caches = catalog_repotweaks_caches(d);
    NSMutableArray<Package *> *packages = [NSMutableArray array];

    for (NSString *url in catalog_repotweaks_urls(d)) {
        id repoRaw = caches[url];
        if (![repoRaw isKindOfClass:NSDictionary.class]) continue;
        NSDictionary *repo = (NSDictionary *)repoRaw;
        NSString *repoName = catalog_string_or_empty(repo[@"repoName"]);
        NSString *author = catalog_string_or_empty(repo[@"author"]);
        id tweaksRaw = repo[@"tweaks"];
        if (![tweaksRaw isKindOfClass:NSArray.class]) continue;

        for (id tweakRaw in (NSArray *)tweaksRaw) {
            if (![tweakRaw isKindOfClass:NSDictionary.class]) continue;
            NSDictionary *tweak = (NSDictionary *)tweakRaw;
            NSString *tweakID = catalog_string_or_empty(tweak[@"id"]);
            NSString *name = catalog_string_or_empty(tweak[@"name"]);
            NSString *scriptURL = catalog_string_or_empty(tweak[@"scriptURL"]);
            if (tweakID.length == 0 || name.length == 0 || scriptURL.length == 0) continue;

            NSString *identifier = [NSString stringWithFormat:@"repo.%@", repotweaks_storage_key(url, tweakID)];
            Package *pkg = [[Package alloc] initRepoTweakWithIdentifier:identifier
                                                                   name:name
                                                       shortDescription:catalog_string_or_empty(tweak[@"description"])
                                                                version:catalog_string_or_empty(tweak[@"version"])
                                                                 author:author
                                                               repoName:repoName
                                                                repoURL:url
                                                            repoTweakID:tweakID
                                                           repoScriptURL:scriptURL];
            NSString *symbol = catalog_string_or_empty(tweak[@"symbol"]);
            if (symbol.length > 0) pkg.symbolName = symbol;
            NSString *tweakAuthor = catalog_string_or_empty(tweak[@"author"]);
            if (tweakAuthor.length > 0) pkg.author = tweakAuthor;
            NSString *rawScript = [d stringForKey:repotweaks_script_defaults_key(url, tweakID)];
            NSString *unsupportedReason = repotweaks_unsupported_reason(tweak);
            if (unsupportedReason.length > 0) {
                pkg.installDisabledReason = unsupportedReason;
                pkg.unstableWarning = unsupportedReason;
            } else if (rawScript.length == 0) {
                pkg.installDisabledReason = @"安装前请先在“源”标签页刷新此源。";
            } else if (pkg.repoTweakUsesQuickLoader && catalog_repo_script_requires_native_bridge(rawScript)) {
                pkg.installDisabledReason = @"此仓库插件需要专属的 Cyanide 原生后端才能安装。";
            }
            [packages addObject:pkg];
        }
    }

    return [packages sortedArrayUsingComparator:^NSComparisonResult(Package *a, Package *b) {
        return [a.name caseInsensitiveCompare:b.name];
    }];
}

// Underlying section indices for the detail-mode SettingsViewController push.
// Defined directly from the shared SettingsSection enum (SettingsViewController.h)
// so they track the enum automatically — the previous hand-copied numbers had
// drifted (e.g. kSecLayoutExtras was 15 = SectionSnowBoardLite, so "Customize
// Home Layout Extras" opened the theme selector).
static const NSInteger kSecSBC              = SectionSBC;
static const NSInteger kSecStatBar          = SectionStatBar;
static const NSInteger kSecNSBar            = SectionNSBar;
static const NSInteger kSecNiceBarLite      = SectionNiceBarLite;
static const NSInteger kSecPowercuff        = SectionPowercuff;
static const NSInteger kSecDragCoefficient  = SectionDragCoefficient;
static const NSInteger kSecLayoutExtras     = SectionLayoutExtras;
static const NSInteger kSecNanoRegistry     = SectionNanoRegistry;
static const NSInteger kSecSnowBoardLite    = SectionSnowBoardLite;
static const NSInteger kSecLiveWP           = SectionLiveWP;
static const NSInteger kSecLocationSim      = SectionLocationSim;
static const NSInteger kSecAppSwitcherGrid  = SectionAppSwitcherGrid;
static const NSInteger kSecFloatingDock     = SectionFloatingDock;
static const NSInteger kSecFastLockXLite    = SectionFastLockXLite;
static const NSInteger kSecQuickLoader      = SectionQuickLoader;
static const NSInteger kSecRepoTweaks       = SectionRepoTweaks;
static const NSInteger kSecLockScreenDuration = SectionLockScreenDuration;
static const NSInteger kSecPasscodeTheme    = SectionPasscodeTheme;
static const NSInteger kSecOTA              = SectionOTA;

+ (NSArray<Package *> *)allPackages
{
    NSArray<Package *> *full = [self allPackagesIncludingExperimental];
    BOOL experimentalOn = [[NSUserDefaults standardUserDefaults]
                            boolForKey:kSettingsExperimentalTweaksEnabled];

    NSMutableArray<Package *> *out = [NSMutableArray arrayWithCapacity:full.count];
    for (Package *p in full) {
        if (p.creatorOnly) continue;
        if (p.experimental && !experimentalOn) continue;
        [out addObject:p];
    }
    return out;
}

+ (NSArray<Package *> *)allPackagesIncludingExperimental
{
    static NSArray<Package *> *list;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *version = @"1.0";
        Package *statBar = [[Package alloc] initWithIdentifier:@"com.darksword.statbar"
                                           name:@"StatBar"
                               shortDescription:@"电池温度 + 可用内存覆盖层"
                                longDescription:@"在 SpringBoard 安装一个覆盖窗口，在系统状态栏旁实时显示电池温度和可用内存。刷新频率可调，可在实时性与续航之间权衡。\n\n请在设置标签页配置单位、可见指标和刷新速度。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"状态栏"
                                     symbolName:@"thermometer.medium"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsStatBarEnabled
                                          isNew:NO];
        statBar.settingsSection = kSecStatBar;

        Package *nsBar = [[Package alloc] initWithIdentifier:@"com.darksword.nsbar"
                                           name:@"NSBar"
                               shortDescription:@"状态栏网速覆盖层"
                                longDescription:@"在紧凑的 SpringBoard 状态栏覆盖层中显示实时上传和下载速度。可在设置中选择角落或居中位置。\n\n来自 d1y/cyanide-ios。"
                                        version:version
                                         author:@"d1y"
                                       category:@"状态栏"
                                     symbolName:@"network"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsNSBarEnabled
                                          isNew:NO];
        nsBar.settingsSection = kSecNSBar;

        Package *niceBarLite = [[Package alloc] initWithIdentifier:@"com.darksword.nicebarlite"
                                           name:@"NiceBar Lite"
                               shortDescription:@"NiceBar 风格状态栏标签"
                                longDescription:@"在状态栏周围添加可配置的文本标签。槽位可显示自定义文本、日期时间格式，以及电池、内存、网速、运行时长、IP 地址、磁盘空间、温度状态和流量计数等系统数值。\n\n来自 d1y/cyanide-ios。"
                                        version:version
                                         author:@"d1y"
                                       category:@"状态栏"
                                     symbolName:@"textformat.size"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsNiceBarLiteEnabled
                                          isNew:NO];
        niceBarLite.settingsSection = kSecNiceBarLite;

#if CYANIDE_EXPERIMENTAL_TWEAKS_AVAILABLE
#endif

        Package *sbc = [[Package alloc] initWithIdentifier:@"com.darksword.sbcustomizer"
                                           name:@"SBCustomizer"
                               shortDescription:@"自定义程序坞、网格、应用位置和页数"
                                longDescription:@"自定义程序坞图标数和主屏图标网格（列数与行数）。可把选定应用移入程序坞新空出的位置、可选隐藏图标名称，并可为第一页和其余主屏页面分别设置图标容量。\n\n可选的程序坞移动默认选择 Watusi 的 WhatsApp 副本；在设置中输入其他应用的 bundle 标识符即可更改。"
                                        version:@"1.1"
                                         author:@"zeroxjf / Kolbicz"
                                       category:@"主屏幕"
                                     symbolName:@"square.grid.3x3.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsSBCEnabled
                                          isNew:NO];
        sbc.settingsSection = kSecSBC;

        Package *powercuff = [[Package alloc] initWithIdentifier:@"com.darksword.powercuff"
                                           name:@"Powercuff"
                               shortDescription:@"按热压力降低 CPU/GPU 频率"
                                longDescription:@"用合成热压力驱动 thermalmonitord 以降低 CPU 和 GPU 频率。适合散热敏感的任务或延长高负载续航。效果持续到重启。\n\nNominal 是日常默认档。Light、Moderate 和 Heavy 刻意加大 CPU 降频幅度，因此卡顿和应用启动变慢正是它在按设计工作。这些档位对日常使用可能太慢，尤其在旧设备上。\n\n请在设置标签页选择档位。"
                                        version:version
                                         author:@"rpetrich"
                                       category:@"System"
                                     symbolName:@"bolt.slash.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsPowercuffEnabled
                                          isNew:NO];
        powercuff.settingsSection = kSecPowercuff;

        Package *carPlayWithoutSiri = [[Package alloc] initWithIdentifier:@"com.darksword.carplay-without-siri"
                                           name:@"无 Siri 使用 CarPlay"
                               shortDescription:@"在关闭 Siri 的情况下使用 CarPlay"
                                longDescription:@"从 iOS 18 起，Siri 关闭时 CarPlay 会显示“CarPlay 不可用——要使用 CarPlay，请开启 Siri”。这个画面由 iPhone 自己绘制；本插件将其解除，且 Siri 保持关闭。\n\nCarPlay 每次连接都会重新启动，因此按连接逐次应用：用控制中心的“CarPlay”按钮、“无 Siri 使用 CarPlay”快捷指令操作（例如在“连接 CarPlay 时”自动化中设为立即运行）、cyanide://carplay 链接，或在连接车机时点按“运行”。它需要之前“运行”留下的内核访问；未连接车机时不做任何事。\n\nSiri 关闭时车机语音按钮无效。尚未在多款车型上测试：如果无效，请在应用后立刻发送日志。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"System"
                                     symbolName:@"car.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsCarPlayWithoutSiriEnabled
                                          isNew:YES];

        Package *axon = [[Package alloc] initWithIdentifier:@"com.darksword.axonlite"
                                           name:@"Axon Lite"
                               shortDescription:@"按应用分组通知中心请求"
                                longDescription:@"在 SpringBoard 覆盖层中按应用对通知中心的可见请求分组，并在 Cyanide 保持 RemoteCall 会话期间过滤重复项。\n\n无需额外配置。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"SpringBoard"
                                     symbolName:@"bell.badge.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsAxonLiteEnabled
                                          isNew:NO];
        axon.unstableWarning = @"⚠️ 实验性：开发中。可能出现 SpringBoard 崩溃、通知丢失、布局错乱，以及不同 Cyanide 版本间的失效。不要把它用于重要事项。";

#if CYANIDE_EXPERIMENTAL_TWEAKS_AVAILABLE



        Package *stageStrip = [[Package alloc] initWithIdentifier:@"com.darksword.stagestrip"
                                           name:@"Dynamic Stage Lite"
                               shortDescription:@"两个悬浮应用窗口，iPad 风格"
                                longDescription:
            @"以悬浮、可调大小的窗口在 SpringBoard 之上运行两个应用。\n\n"
            @"基于 tomt000 的 Dynamic Stage——原版 iPhone 版台前调度插件。Dynamic Stage Lite 是独立的、仅 RemoteCall 的分屏 + 场景托管设计重实现；未复用原插件的任何代码或素材。完整版请移步 Havoc。\n\n"
            @"使用方法：\n"
            @"• 点按屏幕右下角的圆点打开选择器。\n"
            @"• 点按两个应用，并排启动它们。\n"
            @"• 拖动顶栏移动；拖动任意角落调整大小。\n"
            @"• 窗口左上角的 X 可关闭它。\n"
            @"• 选择器托盘中的齿轮可跳回 Cyanide 设置。\n\n"
            @"首次运行较慢。选择器要通过 RemoteCall 枚举所有已安装应用并为每个应用构建磁贴——全新安装预计需要 1-2 分钟。再次运行会复用缓存，速度很快。\n\n"
            @"尚未完善：\n"
            @"• 触摸尚未传入托管的窗口应用——窗口只用于查看/切换，不能滚动或输入。\n"
            @"• 全屏启动时的自动关闭尚未接线；请用 X 手动关闭。\n"
            @"• App 资源库填充期间手势可能卡顿。"
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"Beta"
                                     symbolName:@"sidebar.left"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsStageStripEnabled
                                          isNew:NO];
        stageStrip.unstableWarning = @"Beta / 不稳定：首次运行需 1-2 分钟，因为选择器要枚举所有已安装应用并为每个构建磁贴。再次运行很快。触摸传入托管窗口尚未接线，悬浮窗口内滚动/输入可能无效。";
#endif

        Package *locationSim = [[Package alloc] initWithIdentifier:@"com.darksword.locationsim"
                                           name:@"位置模拟器"
                               shortDescription:@"CoreLocation 定点模拟"
                                longDescription:@"Spoofs the device's GPS location via Apple's CLSimulationManager. Requires Apple Maps installed and set up — Maps is the RemoteCall host process that drives the simulation.\n\nThis is a manual tool, not an installable package. Open Controls, choose a target, then use Simulate Current Target or Restore Real Location. Each run opens the activity log and marks completion when the request returns. Reset may take a few minutes and may require a reboot plus extra wait time.\n\nSettings exposes the current target plus altitude and accuracy. v1 is static-point only; route playback and alternate daemon hosts are next.\n\nNot all apps respect the simulated location. Apps that use their own location validation or additional signals may ignore it.\n\nCredits: kolbicz provided the GPS spoofer RemoteCall/CLSimulationManager prototype this is based on. ezzuldinSt's LSpoof provided the app-side CLLocationManager spoofing, picker, bookmarks, and route-simulation reference.\n\nSystem-behavior warning: simulated locations can affect more than maps. Features tied to location, including time zone, date/time behavior, weather, automation, reminders, and service checks, may behave unexpectedly. Only use this if you know what you're doing.\n\nLegal and service-use note: simulated locations may violate app terms, platform rules, game rules, ride-share or delivery policies, or local law depending on how they are used. Use only where you have permission. You are responsible for your use and apply or restore this tweak at your own risk."
                                        version:version
                                         author:@"zeroxjf、kolbicz、ezzuldinSt"
                                       category:@"System"
                                     symbolName:@"location.fill"
                                           kind:PackageInstallKindDirectTool
                                     enabledKey:nil
                                          isNew:NO];
        locationSim.settingsSection = kSecLocationSim;
        locationSim.experimental = NO;
        locationSim.unstableWarning = @"Beta：需安装并设置好 Apple 地图。会更改 CoreLocation 的活动模拟状态——可能影响时区、日期时间及其他与定位相关的行为。部分应用和服务禁止或检测模拟定位。请确认自己清楚在做什么再使用。";

        Package *snowboardLite = [[Package alloc] initWithIdentifier:@"com.darksword.snowboardlite"
                                           name:@"SnowBoard Lite"
                               shortDescription:@"本地 SnowBoard 风格图标主题"
                                longDescription:@"把 SnowBoard/IconBundles 主题导入本地库，并通过 Cyanide 的图标替换管线应用所选主题。支持内置 iOS 6 主题和本地目录导入。\n\nSnowBoard Lite 是 Cyanide 的图标主题主入口。\n\n来自 d1y/cyanide-ios。"
                                        version:version
                                         author:@"d1y"
                                       category:@"Theming"
                                     symbolName:@"square.stack.3d.up.fill"
                                          kind:PackageInstallKindToggle
                                     enabledKey:kSettingsSnowBoardLiteEnabled
                                          isNew:NO];
        snowboardLite.settingsSection = kSecSnowBoardLite;
        snowboardLite.unstableWarning = @"预览：应用前请先导入或选择 SnowBoard Lite 主题。";

        Package *liveWP = [[Package alloc] initWithIdentifier:@"com.darksword.livewp"
                                           name:@"LiveWP"
                               shortDescription:@"主屏与锁屏视频壁纸"
                                longDescription:@"在 Cyanide 保持 RemoteCall 会话期间，于 SpringBoard 的主屏和锁屏窗口之后播放选定的 MP4/MOV/M4V 视频。\n\n来自 d1y/cyanide-ios。"
                                        version:version
                                         author:@"d1y"
                                       category:@"Theming"
                                     symbolName:@"play.rectangle.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsLiveWPEnabled
                                          isNew:NO];
        liveWP.settingsSection = kSecLiveWP;

        Package *layoutExtras = [[Package alloc] initWithIdentifier:@"com.darksword.layoutextras"
                                           name:@"主屏布局增强"
                               shortDescription:@"额外主屏/程序坞边距和逐图标缩放"
                                longDescription:@"Adds extra padding around the home grid and the dock, and scales icons up or down. Stacks on top of SBCustomizer.\n\nDial in left/right/top/bottom padding for the home screen, horizontal padding for the dock, and home/dock icon scale in the Settings tab. Defaults match stock (zero padding, 100% scale).\n\nApplied at Run; not persisted across respring.\n\niOS 18: mutates the SBIconController layout configuration directly (upstream kolbicz path).\niOS 26: walks the live SBIconListView/SBIconView hierarchy and adjusts frames + iconImageInfo per icon (the iOS 26 layout class is read-only). One-shot at Run on iOS 26 — rotation/page swipe may force iOS 26's auto-layout to re-fit, so re-Run if that happens."
                                        version:version
                                         author:@"kolbicz"
                                      category:@"主屏幕"
                                     symbolName:@"square.dashed.inset.filled"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsLayoutExtrasEnabled
                                          isNew:NO];
        layoutExtras.settingsSection = kSecLayoutExtras;
        NSInteger iosMajor = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
        if (iosMajor >= 26) {
            layoutExtras.knownIssues = @[
                @"iOS 26：旋转或翻页后布局可能重置。请重新运行以再次应用。",
            ];
        }

        // Lock Screen Duration is a manual tool (DirectTool): it appears in the
        // tweak list with author/version, but instead of a queued install it
        // opens its own Settings section whose Apply / Remove / Read buttons
        // write the SBMinimumLockscreenIdleTime floor and offer a respring. Like
        // OTA Updates it is not part of the Run queue.
        Package *lockScreenDuration = [[Package alloc] initWithIdentifier:@"com.darksword.lockscreen-duration"
                                           name:@"锁屏亮屏时长"
                               shortDescription:@"让锁屏亮得更久"
                                longDescription:@"Extends the lock screen's own dim-then-sleep timer — the short countdown that turns the screen off while you read notifications, separate from Settings > Auto-Lock.\n\nThis is a manual tool, not a queued package. Open Controls, set the number of seconds, then tap Apply Lock Screen Duration. It writes the SpringBoard preference SBMinimumLockscreenIdleTime (a global floor applied to every lock-screen idle state, including after Face ID) and offers a respring to apply it. The value persists across respring and reboot. Use Remove to restore stock timing, or Read Current Value to see what is configured.\n\nMechanism: -[SBIdleTimerDescriptorFactory sanitizeDescriptorForLockscreenDefaults:] floors every lock-screen interval with max(interval, minimumLockscreenIdleTime). Face ID gaze (Attention Aware) can keep the screen on even longer.\n\nRun the chain at least once first so kernel access is active. Takes effect on the next respring."
                                        version:@"1.0"
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"lock.rectangle.on.rectangle"
                                           kind:PackageInstallKindDirectTool
                                     enabledKey:nil
                                          isNew:YES];
        lockScreenDuration.settingsSection = kSecLockScreenDuration;

        Package *appSwitcherGrid = [[Package alloc] initWithIdentifier:@"com.darksword.appswitchergrid"
                                           name:@"网格多任务切换器"
                               shortDescription:@"网格多任务切换器"
                                longDescription:@"应用运行时 SpringBoard 方法补丁，让多任务切换器使用网格/层叠样式。\n\n不写入系统文件。重加载即恢复原生切换器。隐藏 Home 条后如果重加载过，请重新运行“网格多任务切换器”，因为重加载会重置此实时 SpringBoard 补丁。\n\n来自 d1y/cyanide-ios。"
                                        version:version
                                         author:@"rooootdev"
                                       category:@"SpringBoard"
                                     symbolName:@"square.grid.2x2.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsAppSwitcherGridEnabled
                                          isNew:NO];
        appSwitcherGrid.settingsSection = kSecAppSwitcherGrid;
        appSwitcherGrid.unstableWarning = @"Beta：在内存中修补 SpringBoard 运行时方法。重加载即恢复原生，但不受支持的版本可能导致切换器故障或 SpringBoard 崩溃。每次重加载后请重新运行。";

        Package *floatingDock = [[Package alloc] initWithIdentifier:@"com.darksword.floatingdock"
                                           name:@"iPad 式程序坞"
                               shortDescription:@"带 App 资源库的 iPad 式程序坞"
                                longDescription:@"为当前 SpringBoard 会话把程序坞变成 SpringBoard 自带的 iPad 式程序坞（含 App 资源库按钮）。\n\n不写入系统文件。关闭即恢复原生程序坞；重加载也一样。与“禁用 App 资源库”配合使用：此时资源库只出现在程序坞。\n\n来自 hxhlb/cyanide。"
                                        version:version
                                         author:@"Banana"
                                       category:@"SpringBoard"
                                     symbolName:@"dock.rectangle"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsFloatingDockEnabled
                                          isNew:YES];
        floatingDock.settingsSection = kSecFloatingDock;
        floatingDock.unstableWarning = @"在内存中使用 SpringBoard 的私有程序坞控制器。如果程序坞显示异常，请关闭或重加载。";

        Package *lockedPreviews = [[Package alloc] initWithIdentifier:@"com.darksword.locked-previews"
                                           name:@"锁定应用通知预览"
                               shortDescription:@"Face ID 锁定应用的通知预览"
                                longDescription:@"用“需要 Face ID”锁定的应用（iOS 18）无论预览设置为何，通知都不显示内容。本插件让常规预览设置重新对它们生效：始终、解锁时或从不，可按应用或全局设置。打开锁定应用仍会要求 Face ID。\n\n恢复的设置由 iOS 保存，重加载后仍有效。关闭后锁定应用的通知预览会再次被隐藏。iOS 18 及更高版本。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"lock.rectangle.stack"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsLockedPreviewsEnabled
                                          isNew:YES];

        Package *quickLoader = [[Package alloc] initWithIdentifier:@"com.darksword.quickloader"
                                           name:@"QuickLoader"
                               shortDescription:@"执行自定义 .js 代码"
                                longDescription:@"Select a local JavaScript file from Files, configure any declared parameters, and run it through Cyanide's SpringBoard RemoteCall bridge.\n\nOnly run scripts you trust. JavaScript tweaks can send private SpringBoard messages and destabilize the device if the script is buggy."
                                        version:@"1.0"
                                         author:@"Iggy05"
                                       category:@"SpringBoard"
                                     symbolName:@"bolt.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsQuickLoaderEnabled
                                          isNew:NO];
        quickLoader.settingsSection = kSecQuickLoader;
        quickLoader.unstableWarning = @"运行用户选择的 JavaScript，可访问 Cyanide 的 RemoteCall 辅助函数。只使用你信任的脚本；糟糕的脚本可能让 SpringBoard 崩溃。";

#if CYANIDE_EXPERIMENTAL_TWEAKS_AVAILABLE
        Package *fastLockXLite = [[Package alloc] initWithIdentifier:@"com.darksword.fastlockx-lite"
                                           name:@"FastLockX Lite"
                               shortDescription:@"Face ID 重试 + 解锁控制"
                                longDescription:@"RemoteCall-only port of the usable FastLockX primitives recovered from the iOS 15 tweak by Artem Kasper.\n\nCredits: original FastLockX by Artem Kasper; Cyanide FastLockX Lite port by zeroxjf.\n\nIt can pulse SpringBoard's biometric retry path, ask the iOS 26 biometric coordinator to start a Mesa/Face ID unlock, and send the original Lock Screen unlock request as a fallback. Installing it through Apply Tweaks keeps those retry/unlock requests armed with SpringBoard timers so pickup-to-unlock can work after Cyanide closes. The pulse loop pauses again after unlock.\n\nUse Disable, Clean Up, or a respring to stop the timers."
                                        version:version
                                         author:@"Artem Kasper / zeroxjf"
                                       category:@"Beta"
                                     symbolName:@"lock.open.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsFastLockXLiteEnabled
                                          isNew:NO];
        fastLockXLite.settingsSection = kSecFastLockXLite;
        fastLockXLite.unstableWarning = @"Beta / 不稳定：向 SpringBoard 发送私有的锁屏和生物识别资源消息。设备锁定期间“始终开启”会让 SpringBoard 定时器持续运行，如果 Face ID 表现吵闹或不稳定，请停用或重加载。";
#endif

        Package *nanoRegistry = [[Package alloc] initWithIdentifier:@"com.darksword.nanoregistry"
                                           name:@"手表配对覆盖"
                               shortDescription:@"配对新表或救活旧表"
                                longDescription:@"Changes the watchOS pairing range saved on this iPhone.\n\nMost people should use watchOS Range 99/23/10/6 in Settings, then apply the override. These are pairing protocol generations, not Apple Watch model numbers. 99 raises the watchOS pairing ceiling. 23 keeps the generation-23 setup protocol accepted. 10 and 6 leave the legacy chip and multi-watch floors at their normal values.\n\nApple Watch Ultra 3 cannot pair on iOS versions below 26 at this time.\n\nSystem-file warning: this modifies the local NanoRegistry compatibility-index MobileAsset and saves a .cyanide.bak backup beside the original file. Pairing-asset edits can fail, partially apply, require a respring or reboot to settle, or leave pairing state inconsistent. You apply or remove this override at your own risk.\n\nRespring or reboot after installing or removing the override before trying to pair."
                                        version:version
                                         author:@"zeroxjf"
                                       category:@"System"
                                     symbolName:@"applewatch.radiowaves.left.and.right"
                                           kind:PackageInstallKindNanoRegistry
                                     enabledKey:nil
                                          isNew:NO];
        nanoRegistry.settingsSection = kSecNanoRegistry;
        nanoRegistry.unstableWarning = @"警告：修改本地 NanoRegistry MobileAsset。Cyanide 会在原文件旁保存 .cyanide.bak 备份，但系统文件编辑可能失败或需要重加载/重启。应用或移除此覆盖风险自负。";

        Package *callRecordingSound = [[Package alloc] initWithIdentifier:@"com.darksword.callrecording-sound"
                                           name:@"通话录音提示音"
                               shortDescription:@"静音通话披露开始/结束提示音"
                                longDescription:@"Replaces the CallServices StartDisclosureWithTone and StopDisclosure audio files with Cyanide's bundled silent payloads.\n\nCredits: YangJiiii (@duongduong0908) for the EnsWilde and Disable Call Recording BookRestore reference tools. @Little_34306 is credited by the original projects for the Disable Call Recording concept. Cyanide port, KRW-backed implementation, and generated replacement silent audio assets by zeroxjf.\n\nSystem-file warning: this modifies files under /var/mobile/Library/CallServices/Greetings/default. Cyanide backs up the first originals into its app container, but system file replacement can fail, partially apply, or require a respring/reboot to settle.\n\nLegal note: call-recording disclosure sounds may exist to satisfy consent, notification, or privacy-law requirements in some places. You are responsible for understanding and following the laws that apply to you.\n\nThis port does not use the old Books/BookRestore/sparserestore path. Cyanide runs KRW, unlocks local /private/var write access, then writes directly to the CallServices files.\n\nUse Restore Original Sounds to write Cyanide's backups back when present. You apply or restore this tweak at your own risk."
                                        version:version
                                         author:@"YangJiiii（@duongduong0908）/ zeroxjf"
                                       category:@"System"
                                     symbolName:@"speaker.slash.fill"
                                           kind:PackageInstallKindCallRecordingSound
                                     enabledKey:nil
                                          isNew:NO];
        callRecordingSound.experimental = NO;
        callRecordingSound.unstableWarning = @"Beta：持久的 CallServices 系统文件替换。披露提示音在你所在地区可能是法律要求；使用及应用风险自负。卸载 Cyanide 前想写回备份请先用“还原原始提示音”。";

        Package *passcodeTheme = [[Package alloc] initWithIdentifier:@"com.darksword.passcode-theme"
                                           name:@"密码盘样式"
                               shortDescription:@"自定义锁屏密码盘图案"
                                longDescription:@"Replaces the Lock Screen keypad artwork under /var/mobile/Library/Caches/TelephonyUI-* with a style you import or build in the Passcode Style panel. A style may cover only some digits; the rest stay stock.\n\nOpen Controls to apply it or restore the saved originals. Lock and unlock (or respring) to see the change.\n\nSystem-file warning: the originals Cyanide saves live in Cyanide's own app container, so reinstalling Cyanide deletes them — export them from the Passcode Style panel first if you plan to reinstall.\n\nCredits: ported from the Passcode implementation created for Lara by ruter and neonmodder123, inherited and extended by leonardob8777-bit in Eagle (https://github.com/leonardob8777-bit/Eagle, AGPL-3.0). Cyanide port by FleetingDreamso."
                                        version:version
                                         author:@"ruter / neonmodder123 / leonardob8777-bit / FleetingDreamso"
                                       category:@"Theming"
                                     symbolName:@"circle.grid.3x3.fill"
                                           kind:PackageInstallKindDirectTool
                                     enabledKey:nil
                                          isNew:YES];
        passcodeTheme.settingsSection = kSecPasscodeTheme;
        passcodeTheme.unstableWarning = @"警告：重写锁屏使用的系统键盘图案。Cyanide 会验证每次写入，但编辑仍可能失败或部分应用。“还原原始数字”会把已存原件写回。";

        Package *hideHomeBar = [[Package alloc] initWithIdentifier:@"com.darksword.hide-home-bar"
                                           name:@"隐藏 Home 条"
                               shortDescription:@"隐藏底部主屏幕指示条"
                                longDescription:@"Zeros the first page of /System/Library/PrivateFrameworks/MaterialKit.framework/Assets.car using Cyanide's stable file-page zero path, which hides the bottom home indicator after SpringBoard reloads assets.\n\nRun Hide Home Bar by itself, then respring so SpringBoard refreshes the asset cache. To bring the home indicator back, choose Restore Home Bar and respring again. Other live SpringBoard tweaks, such as App Switcher Grid, should be applied in a separate run after the respring.\n\nCredits: C4ndyF1sh/ZeroCalories for the Home Bar target and jailbreakdotparty/dirtyZero for the original page-zeroing idea. Cyanide port by zeroxjf."
                                        version:version
                                         author:@"C4ndyF1sh / jailbreakdotparty / zeroxjf"
                                       category:@"主屏幕"
                                     symbolName:@"line.3.horizontal"
                                           kind:PackageInstallKindHideHomeBar
                                     enabledKey:nil
                                          isNew:NO];
        hideHomeBar.unstableWarning = @"Beta：系统素材页清零。请单独运行，隐藏后再重加载。要恢复主屏幕指示条，请选择“恢复 Home 条”并重加载。";

        // Manual tool (DirectTool), same shape as Lock Screen Duration: the
        // detail view offers Open Controls, which opens the OTA Updates
        // section in Settings where Disable / Enable / Read Current Status
        // act immediately. It was a queued Disable/Enable menu before, which
        // routed a one-tap system-file edit through the install queue for no
        // benefit and split the read button off into Settings on its own.
        Package *otaBlock = [[Package alloc] initWithIdentifier:@"com.darksword.ota-block"
                                           name:@"OTA 系统更新"
                               shortDescription:@"启用或禁用 OTA 系统更新"
                                longDescription:@"Disables or enables the launchd jobs responsible for over-the-air system updates by editing disabled.plist. State persists across reboots.\n\nSystem-file warning: this edits /private/var/db/com.apple.xpc.launchd/disabled.plist. Incorrect or partial writes can affect launchd job state across boot. You disable or re-enable OTA updates at your own risk.\n\nThis is a manual tool, not a queued package. Open Controls, then tap Disable OTA Updates to block them or Enable OTA Updates to restore them; the change is written immediately, with no Run or Apply step. Read Current Status reports whether the update daemons are currently blocked.\n\nRun the chain at least once first so kernel access is active — Read Current Status will not start it on its own.\n\nVersion 1.2 moves the controls into Settings; 1.1 added Read Current Status."
                                        version:@"1.2"
                                         author:@"kolbicz"
                                       category:@"System"
                                     symbolName:@"icloud.slash.fill"
                                          kind:PackageInstallKindDirectTool
                                    enabledKey:nil
                                         isNew:NO];
        otaBlock.settingsSection = kSecOTA;
        otaBlock.unstableWarning = @"警告：持久的系统文件编辑。此软件包修改 launchd disabled.plist 以跨重启改变 OTA 任务状态。禁用或重新启用 OTA 更新风险自负。";

        Package *disableAppLibrary = [[Package alloc] initWithIdentifier:@"com.darksword.disable-app-library"
                                           name:@"禁用 App 资源库"
                               shortDescription:@"移除 App 资源库页面"
                                longDescription:@"移除排在最后一个主屏页面之后的 App 资源库页面。翻过最后一页将不再有任何反应。\n\n适用于 iOS 17 及更高版本。"
                                        version:@"1.1"
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"square.grid.2x2.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDisableAppLibrary
                                          isNew:NO];

        list = @[
            statBar,
            nsBar,
            niceBarLite,
            sbc,
            layoutExtras,
            powercuff,

            disableAppLibrary,

            [[Package alloc] initWithIdentifier:@"com.darksword.disable-icon-flyin"
                                           name:@"禁用图标飞入动画"
                               shortDescription:@"跳过图标弹跳动画"
                                longDescription:@"跳过解锁或切换应用后主屏图标出现时的弹跳动画。图标直接出现在最终位置。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"sparkles"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDisableIconFlyIn
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.lara.springboard-tools"
                                           name:@"SpringBoard 工具"
                               shortDescription:@"你的程序坞、文件夹和控制中心外观"
                                longDescription:@"把“设置 → Lara → SpringBoard 工具”中设定的外观（程序坞、文件夹、控制中心、通知、多任务切换器）与其他插件一起应用，重加载后随“应用插件”恢复。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"dock.rectangle"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsSBToolsWithTweaks
                                          isNew:YES],

            [[Package alloc] initWithIdentifier:@"com.darksword.hide-new-app-dots"
                                           name:@"隐藏新应用圆点"
                               shortDescription:@"新应用和更新旁不再有蓝点"
                                longDescription:@"移除 iOS 在新装和刚更新应用名称旁显示的蓝点，并让新的蓝点直到下次重加载前不再出现。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"circle.slash"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSHideNewAppDots
                                          isNew:YES],

            [[Package alloc] initWithIdentifier:@"com.darksword.zero-wake-animation"
                                           name:@"去除唤醒动画"
                               shortDescription:@"唤醒时立即点亮"
                                longDescription:@"移除唤醒屏幕时的淡入动画。屏幕立即以全亮度点亮。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"moon.zzz.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSZeroWakeAnimation
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.zero-backlight-fade"
                                           name:@"去除背光渐变"
                               shortDescription:@"锁定/解锁背光即时切换"
                                longDescription:@"把背光渐变时长降为零，锁定和解锁时屏幕立即点亮或熄灭。"
                                        version:version
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"sun.max.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSZeroBacklightFade
                                          isNew:NO],

            [[Package alloc] initWithIdentifier:@"com.darksword.double-tap-to-lock"
                                           name:@"双击锁定"
                               shortDescription:@"双击壁纸锁定"
                                longDescription:@"双击主屏或锁屏背景的空白区域即可锁定设备。1.1 版排除了图标和密码界面，修复了打开应用或输入密码时误锁的问题。"
                                        version:@"1.1"
                                         author:@"kolbicz"
                                       category:@"SpringBoard"
                                     symbolName:@"hand.tap.fill"
                                           kind:PackageInstallKindToggle
                                     enabledKey:kSettingsDSDoubleTapToLock
                                          isNew:NO],

            ({
                Package *drag = [[Package alloc] initWithIdentifier:@"com.darksword.drag-coefficient"
                                                               name:@"拖拽系数"
                                                   shortDescription:@"自定义 SpringBoard 动画速度倍率"
                                                    longDescription:@"Overrides _UIAnimationDragCoefficient in SpringBoard to make all UIKit spring animations faster or slower.\n\nSet the coefficient in the Drag Coefficient settings panel. 50% = 0.50× (2× faster), 25% = 0.25× (4× faster), 100% = stock.\n\nImported from kolbicz/DarkSword-Tweaks."
                                                            version:@"1.1"
                                                             author:@"kolbicz"
                                                           category:@"SpringBoard"
                                                         symbolName:@"dial.medium.fill"
                                                               kind:PackageInstallKindToggle
                                                         enabledKey:kSettingsDSDragCoefficientEnabled
                                                              isNew:NO];
                drag.settingsSection = kSecDragCoefficient;
                drag;
            }),

            otaBlock,
            lockScreenDuration,

            // Higher-risk/manual packages last so their warnings sit below core tweaks.
#if CYANIDE_EXPERIMENTAL_TWEAKS_AVAILABLE
#endif
            axon,
            nanoRegistry,
            callRecordingSound,
            passcodeTheme,
            hideHomeBar,
#if CYANIDE_EXPERIMENTAL_TWEAKS_AVAILABLE
            stageStrip,
            fastLockXLite,
#endif
            locationSim,
            snowboardLite,
            liveWP,
            appSwitcherGrid,
            floatingDock,
            lockedPreviews,
            carPlayWithoutSiri,
            quickLoader,
        ];
    });
    NSArray<Package *> *repoPackages = [self repoPackages];
    if (repoPackages.count == 0) return list;
    return [list arrayByAddingObjectsFromArray:repoPackages];
}

+ (NSArray<NSString *> *)categoriesInOrder
{
    NSArray<NSString *> *preferred = @[
        @"开发中",
        @"Beta",
        @"Experimental",
        @"状态栏",
        @"主屏幕",
        @"Theming",
        @"SpringBoard",
        @"System",
        @"JavaScript 插件",
    ];
    NSMutableArray<NSString *> *all = [NSMutableArray array];
    for (Package *p in [self allPackages]) {
        if (![all containsObject:p.category]) [all addObject:p.category];
    }
    NSMutableArray<NSString *> *order = [NSMutableArray array];
    for (NSString *cat in preferred) {
        if ([all containsObject:cat]) [order addObject:cat];
    }
    for (NSString *cat in all) {
        if (![order containsObject:cat]) [order addObject:cat];
    }
    return order;
}

+ (NSDictionary<NSString *, NSArray<Package *> *> *)packagesByCategory
{
    NSMutableDictionary<NSString *, NSMutableArray<Package *> *> *buckets = [NSMutableDictionary dictionary];
    for (Package *p in [self allPackages]) {
        NSMutableArray<Package *> *bucket = buckets[p.category];
        if (!bucket) {
            bucket = [NSMutableArray array];
            buckets[p.category] = bucket;
        }
        [bucket addObject:p];
    }
    return buckets;
}

@end
