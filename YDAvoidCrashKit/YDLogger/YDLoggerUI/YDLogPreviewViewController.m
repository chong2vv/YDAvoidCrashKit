//
//  YDLogPreviewViewController.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/24.
//

#import "YDLogPreviewViewController.h"

static NSString * const kArtLogAllLinesKey = @"ArtLogAllLines";
static NSString * const kArtLogCrashKey = @"ArtLogCrash";
static NSString * const kArtLogFuncKey = @"ArtLogFunc";
static NSString * const kArtLogFuncErrKey = @"ArtLogFuncErr";
static NSString * const kArtLogReqErrKey = @"ArtLogReqErr";
static NSString * const kArtLogRequsetKey = @"ArtLogRequset";
static NSString * const kArtLogErrorKey = @"ArtLogError";
static NSString * const kArtLogInfoKey = @"ArtLogInfo";
static NSString * const kArtLogDetailKey = @"ArtLogDetail";
static NSString * const kArtLogDebugKey = @"ArtLogDebug";
static NSString * const kArtLogVerboseKey = @"ArtLogVerbose";
static NSString * const kArtLogSearchKey = @"ArtLogSearch";

@interface YDLogPreviewViewController ()<UIDocumentInteractionControllerDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, copy)NSDictionary *logInfoDic;
@property (nonatomic, copy)NSString                 *tagKey;
@property (nonatomic, copy)NSString                 *lastTagKey;

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UISearchBar *searchBar;
@end

@implementation YDLogPreviewViewController

- (instancetype)initWithLogInfo:(NSDictionary *)logInfo {
    self = [super init];
    if (self) {
        self.logInfoDic = [logInfo copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
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
    NSArray *allLines = self.logInfoDic[kArtLogAllLinesKey];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 0;
    if ([_tagKey isEqualToString:kArtLogAllLinesKey]) {
        cell.textLabel.text = allLines[indexPath.row];
    }
    else {
        NSInteger index = [strArr[indexPath.row] integerValue];
        cell.textLabel.text = allLines[index];
    }
    
    return cell;
}


- (UITableView *)tableView {
    if (_tableView == nil) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGFloat height = screenSize.height - [UIApplication sharedApplication].statusBarFrame.size.height - 44.f - 49.f;
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
