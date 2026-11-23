//
//  TendiesViewController.m
//  Cyanide
//
//  Settings → Lara → Tendies Wallpapers. Pick .tendies files and they are
//  installed right away (tweaks/tendies.m); the wallpapers Cyanide added are
//  listed and can be removed one by one (swipe) or all at once.
//

#import "TendiesViewController.h"
#import "SettingsViewController.h"
#import "tweaks/tendies.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

static NSString * const kTDCredit =
    @".tendies 格式来自 leminlimez 的 Nugget。安装流程参照 Nugget 与 rooootdev 的 mond。";

typedef NS_ENUM(NSInteger, TDSection) {
    TDSectionActions,
    TDSectionAdded,
    TDSectionCount,
};

@interface TendiesViewController () <UIDocumentPickerDelegate>
@property (nonatomic, copy) NSArray<NSDictionary *> *added;
@property (nonatomic) BOOL busy;
@property (nonatomic, copy) NSString *status;
@end

@implementation TendiesViewController

- (instancetype)init
{
    if ((self = [super initWithStyle:UITableViewStyleInsetGrouped])) self.title = @"Tendies 壁纸";
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.added = tendies_added();
}

#pragma mark Running

- (void)run:(NSString *)name work:(BOOL (^)(NSString **message))work done:(void (^)(BOOL ok, NSString *message))done
{
    if (self.busy) return;
    self.busy = YES;
    self.status = [name stringByAppendingString:@"…"];
    [self.tableView reloadData];
    __weak typeof(self) weakSelf = self;
    settings_kernel_file_tool_async("Tendies", NO, work, ^(BOOL ok, NSString *message) {
        typeof(self) me = weakSelf;
        if (!me) return;
        me.busy = NO;
        me.added = tendies_added();
        if ([message isEqualToString:kSettingsFullExploitRequiredMessage]) {
            me.status = kSettingsNoKernelAccessHint;
            [me.tableView reloadData];
            settings_tool_needs_exploit(me, me.tableView, @"Tendies 壁纸", ^{
                [weakSelf run:name work:work done:done];
            });
            return;
        }
        me.status = ok ? message : (message ?: @"未生效，请查看日志。");
        if (done) done(ok, message);
        [me.tableView reloadData];
    });
}

- (void)pickFiles
{
    if (self.busy) return;
    // .tendies has no registered type; it is a zip, so any data file is offered.
    UIDocumentPickerViewController *picker =
        [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[ UTTypeZIP, UTTypeData ] asCopy:YES];
    picker.allowsMultipleSelection = YES;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    if (urls.count == 0) return;
    NSArray<NSURL *> *files = [urls copy];
    __block NSUInteger count = 0;
    __weak typeof(self) weakSelf = self;
    [self run:@"Installing" work:^BOOL(NSString **message) {
        BOOL ok = tendies_install(files, &count, message);
        for (NSURL *url in files) [NSFileManager.defaultManager removeItemAtURL:url error:nil];  // our picked copies
        return ok;
    } done:^(BOOL ok, NSString *message) {
        typeof(self) me = weakSelf;
        if (!ok || !me) return;
        NSString *body = [NSString stringWithFormat:
            @"已添加 %lu 张壁纸%@。长按锁屏、点按 +，从图库中选择（“合集”，视频壁纸在“照片”）%@",
            (unsigned long)count, count == 1 ? @"" : @"s",
            message.length ? [@"\n\n" stringByAppendingString:message] : @""];
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"壁纸已安装" message:body
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [me presentViewController:ac animated:YES completion:nil];
    }];
}

- (void)removePaths:(NSArray<NSString *> *)paths title:(NSString *)title
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
        message:@"从图库移除该壁纸并重启 PosterBoard。如果它是你当前的锁屏，请先另选一个。Apple 自带壁纸不受影响。"
        preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    __weak typeof(self) weakSelf = self;
    [ac addAction:[UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *a) {
        [weakSelf run:@"Removing" work:^BOOL(NSString **message) {
            return tendies_remove(paths, message);
        } done:nil];
    }]];
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return TDSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TDSectionActions) return self.added.count ? 2 : 1;
    return self.added.count ? (NSInteger)self.added.count : 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == TDSectionAdded ? @"由 Cyanide 添加" : nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == TDSectionActions) {
        NSString *help = @"把 .tendies 壁纸加入锁屏壁纸图库。之后 PosterBoard 会重启，锁屏可能闪烁。请每次安装少量：自定义壁纸过多时 PosterBoard 会变慢。";
        return self.status.length ? [NSString stringWithFormat:@"%@\n\n%@", self.status, help] : help;
    }
    return self.added.count ? [@"横扫壁纸即可移除。\n\n" stringByAppendingString:kTDCredit] : kTDCredit;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    UIListContentConfiguration *c = cell.defaultContentConfiguration;
    if (indexPath.section == TDSectionActions) {
        BOOL import = indexPath.row == 0;
        c.text = import ? @"安装 .tendies 文件…" : @"移除全部已添加";
        c.image = [UIImage systemImageNamed:import ? @"square.and.arrow.down" : @"trash"];
        c.textProperties.color = self.busy ? UIColor.secondaryLabelColor
                                           : (import ? self.view.tintColor : UIColor.systemRedColor);
        c.imageProperties.tintColor = c.textProperties.color;
    } else if (self.added.count == 0) {
        c.text = @"暂无";
        c.textProperties.color = UIColor.secondaryLabelColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        NSDictionary *item = self.added[indexPath.row];
        c.text = item[@"name"];
        NSDate *date = item[@"date"];
        if ([date isKindOfClass:NSDate.class])
            c.secondaryText = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle
                                                             timeStyle:NSDateFormatterShortStyle];
        c.image = [UIImage systemImageNamed:@"photo.on.rectangle"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.contentConfiguration = c;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section != TDSectionActions || self.busy) return;
    if (indexPath.row == 0) {
        [self pickFiles];
    } else {
        [self removePaths:nil title:[NSString stringWithFormat:@"要移除 %lu 张壁纸%@吗？",
                                     (unsigned long)self.added.count, self.added.count == 1 ? @"" : @"s"]];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == TDSectionAdded && self.added.count > 0 && !self.busy;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete || ![self tableView:tableView canEditRowAtIndexPath:indexPath]) return;
    NSDictionary *item = self.added[indexPath.row];
    [self removePaths:@[item[@"path"]] title:[NSString stringWithFormat:@"要移除“%@”吗？", item[@"name"]]];
}

@end
