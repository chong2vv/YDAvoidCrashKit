//
//  YDLogPreviewViewController.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/24.
//

#import "YDLogPreviewViewController.h"
#import "YDLogService.h"

static NSString * const kYDLogAllLinesKey = @"YDLogAllLines";
static NSString * const kYDLogCrashKey = @"YDLogCrash";
static NSString * const kYDLogFuncKey = @"YDLogFunc";
static NSString * const kYDLogFuncErrKey = @"YDLogFuncErr";
static NSString * const kYDLogReqErrKey = @"YDLogReqErr";
static NSString * const kYDLogRequsetKey = @"YDLogRequset";
static NSString * const kYDLogErrorKey = @"YDLogError";
static NSString * const kYDLogInfoKey = @"YDLogInfo";
static NSString * const kYDLogDetailKey = @"YDLogDetail";
static NSString * const kYDLogDebugKey = @"YDLogDebug";
static NSString * const kYDLogVerboseKey = @"YDLogVerbose";
static NSString * const kYDLogSearchKey = @"YDLogSearch";

@interface YDLogPreviewViewController ()<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, copy)NSDictionary *logInfoDic;
@property (nonatomic, copy)NSString                 *tagKey;
@property (nonatomic, copy)NSString                 *lastTagKey;
@property (nonatomic, strong)NSDateFormatter        *dateFormatter;
@property (nonatomic, strong)NSMutableDictionary    *offsetDic;
@property (nonatomic, strong)NSNumber               *tagOffsetY;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UISearchBar *searchBar;
@property (nonatomic, strong)UITextView  *focusTV;
@property (nonatomic, strong)UIView      *focusMask;
@property (nonatomic, strong)UIDocumentInteractionController *documentController;

@property (nonatomic, copy)NSString                 *filePath;

@end

@implementation YDLogPreviewViewController

- (instancetype)initWithLogFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
        self.logInfoDic = [[[YDLogService shared] getYDLogInfo:filePath] copy];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
        
        _tagKey = kYDLogAllLinesKey;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self configUI];
}

- (void)configUI {
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(_shareAction)];
    UIBarButtonItem *tagItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(_exchangeTag)];
    self.navigationItem.rightBarButtonItems = @[shareItem, tagItem];
    
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.focusMask];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_copyFileString:)];
    longGes.minimumPressDuration = 1.f;
    [self.view addGestureRecognizer:longGes];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyBoard:)];
    [self.view addGestureRecognizer:tapGes];
    
    UITapGestureRecognizer *doubleClickGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_showTextView:)];
    doubleClickGes.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleClickGes];
    
    [self.tableView reloadData];
    
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (![_tagKey isEqualToString:kYDLogSearchKey]) {
        [self.offsetDic setValue:_tagOffsetY forKey:_tagKey];
    }
    
    NSMutableArray *result = [NSMutableArray new];
    
    NSArray *indexArr = self.logInfoDic[_tagKey];
    if (!indexArr) {
        [searchBar resignFirstResponder];
        return ;
    }
    
    if ([_tagKey isEqualToString:kYDLogAllLinesKey]) {
        [indexArr enumerateObjectsUsingBlock:^(NSString *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj containsString:searchBar.text]) {
                [result addObject:@(idx)];
            }
        }];
    }
    else {
        NSArray *allLines = self.logInfoDic[kYDLogAllLinesKey];
        for (NSNumber *idx in indexArr) {
            if ([allLines[idx.integerValue] containsString:searchBar.text]) {
                [result addObject:idx];
            }
        }
    }
    
    [_logInfoDic setValue:result forKey:kYDLogSearchKey];
    if (![_tagKey isEqualToString:kYDLogSearchKey]) _lastTagKey = _tagKey;
    _tagKey = kYDLogSearchKey;
    [self.tableView reloadData];
    [searchBar resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.tableView.contentOffset = CGPointZero;
    });
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    if ([_tagKey isEqualToString:kYDLogSearchKey] && searchBar.text.length < 1) {
        _tagKey = _lastTagKey;
        [self.tableView reloadData];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.offsetDic[self.tagKey]) {
                self.tableView.contentOffset = CGPointMake(0, [self.offsetDic[self.tagKey] floatValue]);
            }
            else {
                self.tableView.contentOffset = CGPointZero;
            }
        });
    }
    return YES;
}

#pragma mark - tableDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *strArr = self.logInfoDic[_tagKey];
    return strArr ? strArr.count : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    NSArray *strArr = self.logInfoDic[_tagKey];
    NSArray *allLines = self.logInfoDic[kYDLogAllLinesKey];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    if ([_tagKey isEqualToString:kYDLogAllLinesKey]) {
        cell.textLabel.text = allLines[indexPath.row];
    }
    else {
        NSInteger index = [strArr[indexPath.row] integerValue];
        cell.textLabel.text = allLines[index];
    }
    
    return cell;
}

#pragma mark - Private method
- (void)_exchangeTag {
    __weak typeof(self) ws = self;

    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"All Log" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogAllLinesKey];
    }];
    [vc addAction:action1];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Level Error" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogErrorKey];
    }];
    [vc addAction:action2];
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Level Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogInfoKey];
    }];
    [vc addAction:action3];
    
    UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"Level Detail" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogDetailKey];
    }];
    [vc addAction:action4];
    
    UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"Level Debug" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogDebugKey];
    }];
    [vc addAction:action5];
    
    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"Level Verbose" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogVerboseKey];
    }];
    [vc addAction:action6];
    
    UIAlertAction *action7 = [UIAlertAction actionWithTitle:@"HTTP Requset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogRequsetKey];
    }];
    [vc addAction:action7];
    
    UIAlertAction *action8 = [UIAlertAction actionWithTitle:@"HTTP Error" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogReqErrKey];
    }];
    [vc addAction:action8];
    
    UIAlertAction *action9 = [UIAlertAction actionWithTitle:@"Function Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogFuncKey];
    }];
    [vc addAction:action9];
    
    UIAlertAction *action10 = [UIAlertAction actionWithTitle:@"Forward Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogFuncErrKey];
    }];
    [vc addAction:action10];
    
    UIAlertAction *action11 = [UIAlertAction actionWithTitle:@"Crash Log" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ws _reloadDataWithTag:kYDLogCrashKey];
    }];
    [vc addAction:action11];

    [self presentViewController:vc animated:YES completion:nil];
}

- (void)_reloadDataWithTag:(NSString *)tagKey {
    [self.offsetDic setValue:_tagOffsetY forKey:_tagKey];
    _tagKey = tagKey;
    [self.tableView reloadData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.offsetDic[tagKey]) {
            self.tableView.contentOffset = CGPointMake(0, [self.offsetDic[tagKey] floatValue]);
        }
        else {
            self.tableView.contentOffset = CGPointZero;
        }
    });
}

- (void)_showTextView:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    NSInteger row = [self.tableView indexPathForRowAtPoint:location].row;
    NSArray *strArr = self.logInfoDic[_tagKey];
    NSArray *allLines = self.logInfoDic[kYDLogAllLinesKey];
    
    if ([_tagKey isEqualToString:kYDLogAllLinesKey]) {
        self.focusTV.text = allLines[row];
    }
    else {
        NSInteger index = [strArr[row] integerValue];
        self.focusTV.text = allLines[index];
    }
    
    self.focusMask.hidden = NO;
}

- (void)_copyFileString:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.tableView];
    NSInteger row = [self.tableView indexPathForRowAtPoint:location].row;
    NSArray *strArr = self.logInfoDic[_tagKey];
    NSArray *allLines = self.logInfoDic[kYDLogAllLinesKey];
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    
    if ([_tagKey isEqualToString:kYDLogAllLinesKey]) {
        pasteboard.string = allLines[row];
    }
    else {
        NSInteger index = [strArr[row] integerValue];
        pasteboard.string = allLines[index];
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"复制成功" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [vc addAction:action];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)_dismissFocusView:(UITapGestureRecognizer *)gesture {
    [self.focusTV resignFirstResponder];
    self.focusMask.hidden = YES;
}

- (void)_dismissKeyBoard:(UITapGestureRecognizer *)gesture {
    [self.searchBar resignFirstResponder];
}

- (void)_shareAction{
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:self.filePath]];
    self.documentController.delegate = self;
    self.documentController.UTI = [self _getUTI:self.filePath.pathExtension];
    [self.documentController presentOpenInMenuFromRect:CGRectZero
                                                inView:self.view
                                              animated:YES];
}

- (NSString *)_getUTI:(NSString *)pathExtension{
    NSString *typeStr = [self _getFileTypeStr:pathExtension];
    
    if ([typeStr isEqualToString:@"PDF"]) {
        return @"com.adobe.pdf";
    }
    if ([typeStr isEqualToString:@"Word"]){
        return @"com.microsoft.word.doc";
    }
    if ([typeStr isEqualToString:@"PowerPoint"]){
        return @"com.microsoft.powerpoint.ppt";
    }
    if ([typeStr isEqualToString:@"Excel"]){
        return @"com.microsoft.excel.xls";
    }
    return @"public.data";
}

- (NSString *)_getFileTypeStr:(NSString *)pathExtension{
    if ([pathExtension isEqualToString:@"pdf"] || [pathExtension isEqualToString:@"PDF"]) {
        return @"PDF";
    }
    if ([pathExtension isEqualToString:@"doc"] || [pathExtension isEqualToString:@"docx"] || [pathExtension isEqualToString:@"DOC"] || [pathExtension isEqualToString:@"DOCX"]) {
        return @"Word";
    }
    if ([pathExtension isEqualToString:@"ppt"] || [pathExtension isEqualToString:@"PPT"]) {
        return @"PowerPoint";
    }
    if ([pathExtension isEqualToString:@"xls"] || [pathExtension isEqualToString:@"XLS"]) {
        return @"Excel";
    }
    return @"public";
}

#pragma mark - Lazy

- (UIView *)focusMask {
    if (_focusMask == nil) {
        _focusMask = [[UIView alloc] initWithFrame:self.view.frame];
        _focusMask.backgroundColor = [UIColor colorWithWhite:0.f alpha:.5f];
        _focusMask.hidden = YES;
        [_focusMask addSubview:self.focusTV];
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissFocusView:)];
        [_focusMask addGestureRecognizer:tapGes];
    }
    
    return _focusMask;
}

- (UITextView *)focusTV {
    if (_focusTV == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = screenSize.height - self.view.window.windowScene.statusBarManager.statusBarFrame.size.height - 44.f;
        _focusTV = [[UITextView alloc] initWithFrame:CGRectMake(screenSize.width / 8, 0, screenSize.width * 3 / 4, height)];
        _focusTV.font = [UIFont systemFontOfSize:15.f];
        _focusTV.editable = NO;
        [_focusTV setTextContainerInset:UIEdgeInsetsMake(20.f, 0, 0, 0)];
    }
    
    return _focusTV;
}

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 49.f)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"搜索";
    }
    
    return _searchBar;
}

- (NSMutableDictionary *)offsetDic {
    if (_offsetDic == nil) {
        _offsetDic = [NSMutableDictionary new];
    }
    
    return _offsetDic;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = screenSize.height - self.view.window.windowScene.statusBarManager.statusBarFrame.size.height - 44.f - 49.f;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 49.f, screenSize.width, height) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60.f;
        _tableView.tableHeaderView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, FLT_MIN)];
        _tableView.tableFooterView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, FLT_MIN)];
        _tableView.separatorColor = [UIColor blueColor];
    }
    return _tableView;
}

@end
