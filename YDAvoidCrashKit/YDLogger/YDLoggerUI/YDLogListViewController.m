//
//  YDLogListViewController.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/24.
//

#import "YDLogListViewController.h"
#import "YDLogService.h"
#import "YDLogPreviewViewController.h"

@interface YDLogListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)UITableView *homeTableView;
@property (nonatomic, copy)NSArray *logList;
@property (nonatomic, strong)NSDateFormatter        *dateFormatter;

@end

@implementation YDLogListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logList = [[[YDLogService shared] getAllLogFileData] copy];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self configUI];
}

- (void)configUI {
    [self.view addSubview:self.homeTableView];
    self.homeTableView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [self.homeTableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *filePath = [self.logList objectAtIndex:indexPath.row];
    NSArray *array = [filePath componentsSeparatedByString:@"/"];
    NSString *logName = [array lastObject];
    NSString *title = [[logName componentsSeparatedByString:@"-"] objectAtIndex:1];
    cell.textLabel.text = [self _dateStringFormTimeStamp:title];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [self.logList objectAtIndex:indexPath.row];
    NSDictionary *info = [[YDLogService shared] getYDLogInfo:filePath];
    YDLogPreviewViewController *vc = [[YDLogPreviewViewController alloc] initWithLogInfo:info];
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSString *)_dateStringFormTimeStamp:(NSString *)timeStamp {
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp.doubleValue]];
}

- (UITableView *)homeTableView {
    if (!_homeTableView) {
        _homeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _homeTableView.delegate = self;
        _homeTableView.dataSource = self;
    }
    return _homeTableView;
}

@end
