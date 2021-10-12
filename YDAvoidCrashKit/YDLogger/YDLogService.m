//
//  YDLogService.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import "YDLogService.h"

@interface YDLogService ()
//@property (nonatomic, strong)dispatch_queue_t dpQueue;          // 业务处理线程
//@property (nonatomic, strong)NSMutableSet *uploadingSet;        // 正在上传的文件名集合
//@property (nonatomic, strong)NSOperationQueue *opQueue;         // 上传日志的队列
//@property (nonatomic, strong)dispatch_semaphore_t semaphore;    // 信号量，保证opQueue同步执行

@property (nonatomic, copy)NSString *logFileDir;                // 日志文件夹路径
@property (nonatomic, strong)NSDateFormatter        *dateFormatter;

@property (nonatomic, copy)NSString                 *tagKey;
@property (nonatomic, copy)NSString                 *lastTagKey;

@property (nonatomic, assign)NSInteger clearDayTime;
@end

/**
 创建NSInvocationOperation时，用到的方法的参数的key
 */
static NSString * const kYDLoggerFilePathKey = @"YDLoggerFilePath";
static NSString * const kYDLoggerZipPathKey = @"YDLoggerZipPath";
static NSString * const kYDLoggerLogTypeKey = @"YDLoggerLogType";

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

@implementation YDLogService

+ (instancetype)shared {
    static YDLogService *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YDLogService alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        // 创建日志文件夹
        _logFileDir = [self _createDirectory:YDFILE_PREFIXNAME];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _tagKey = kYDLogAllLinesKey;
        _clearDayTime = 10;
    }
    
    return self;
}

- (void)startLogNeedHook:(BOOL)hook {
    [[YDMmapLogService shared] setLogLevel:YDLogLevelDetail];
    
    // 开起日志
    [[YDMmapLogService shared] startLoggerNeedHook:hook];
    
    [self _autoClearLogFile];
}

- (void)resetLogLevel:(YDLogLevel)level {
    [[YDMmapLogService shared] setLogLevel:level];
}

- (void)syncFileData {
    [[YDMmapLogService shared] syncCurrentFileData];
}

- (void)closeFileBeforeShutDown {
    [[YDMmapLogService shared] closeFileBeforeShutDown];
}

- (NSString *)currentFilePath {
    return [YDMmapLogService shared].filePath;
}

- (void)clearAllLog {
    [self _cleanLogFile];
}

// 清除历史遗留的日志文件
- (void)_cleanLogFile {
    NSString *fileDir = _logFileDir;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm subpathsOfDirectoryAtPath:fileDir error:nil];
    if (!files) return;
    
    // fileDir文件夹下的所有文件
    for (int i = 0; i < (NSInteger)files.count; ++i) {
        @autoreleasepool {
            NSString *fileName = files[i];
            if (![self _isValidFileName:fileName]) continue ;
            [fm removeItemAtPath:[fileDir stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void)clearLogWithDayTime:(NSInteger)day {
    self.clearDayTime = day;
}

- (void)_autoClearLogFile {
    NSString *fileDir = _logFileDir;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm subpathsOfDirectoryAtPath:fileDir error:nil];
    if (!files) return;
    
    // fileDir文件夹下的所有文件
    for (int i = 0; i < (NSInteger)files.count; ++i) {
        @autoreleasepool {
            NSString *fileName = files[i];
            if (![self _isValidFileName:fileName]) continue ;
            NSString *time = [fileName componentsSeparatedByString:@"-"][1];
            //秒级时间戳
            if ([[NSDate date] timeIntervalSince1970] - time.doubleValue > self.clearDayTime * 24 * 60 * 60)
                [fm removeItemAtPath:[fileDir stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (NSArray *)getAllLogFileData {
    NSString *fileDir = _logFileDir;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileNames = [fm subpathsOfDirectoryAtPath:fileDir error:nil];
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *name in fileNames) {
        if (![self _isValidFileName:name]) continue ;
        [files addObject:[NSString stringWithFormat:@"%@/%@",fileDir, name]];
    }
    
    NSArray *sortedPaths = [files sortedArrayUsingComparator:^(NSString * firstPath, NSString* secondPath) {


    NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstPath error:nil];/*获取前一个文件信息*/

    NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondPath error:nil];/*获取后一个文件信息*/

    id firstData = [firstFileInfo objectForKey:NSFileCreationDate];/*获取前一个文件创建时间*/

    id secondData = [secondFileInfo objectForKey:NSFileCreationDate];/*获取后一个文件创建时间*/
        return [secondData compare:firstData];
    }];
    return sortedPaths;
}

- (NSDictionary *)getYDLogInfo:(NSString *)filePath {
    // 读取本地文件数据
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *data = [fileHandle readDataToEndOfFile];
    NSMutableDictionary *fileLinesDic = [NSMutableDictionary new];
    if (data && data.length) {

        // 将数据按行分开
        NSString *txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableArray *allLines = [NSMutableArray arrayWithArray:[txt componentsSeparatedByString:@"\n"]];

        // 如果有连续的二进制0填充，则需要删除此条数据；如果一条完整数据中含有\n，需要拼接成一行，且删除无用数据
        uint8_t nobytes[5] = {0,0,0,0,0};
        NSString *noData = [[NSString alloc] initWithData:[NSData dataWithBytes:&nobytes length:5] encoding:NSUTF8StringEncoding];
        NSMutableArray *deleteArr = [NSMutableArray new];
        NSString *appendingStr = @"";
        uint64_t lastTagIndex = 0;

        // 按标签分类的数据的index
        NSMutableArray *errorArr = [NSMutableArray new];
        NSMutableArray *infoArr = [NSMutableArray new];
        NSMutableArray *detailArr = [NSMutableArray new];
        NSMutableArray *debugArr = [NSMutableArray new];
        NSMutableArray *verboseArr = [NSMutableArray new];
        NSMutableArray *reqArr = [NSMutableArray new];
        NSMutableArray *reqErrArr = [NSMutableArray new];
        NSMutableArray *funcArr = [NSMutableArray new];
        NSMutableArray *funcErrArr = [NSMutableArray new];
        NSMutableArray *crashArr = [NSMutableArray new];

        for (uint64_t i = 0; i < (uint64_t)allLines.count; i++) {
            @autoreleasepool {
                NSString *str = allLines[(NSUInteger)i];

                // 如果是连续的二进制0，则记录index，待删除
                if ([str hasPrefix:noData]) {
                    [deleteArr addObject:@(i)];
                    continue;
                }

                // 解析数据tag
                NSArray *elements = [str componentsSeparatedByString:@" "];
                NSString *tag = elements.firstObject;
                BOOL isTag = NO;

                if ([tag isEqualToString:@"Info"]) {
                    [infoArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Func"]) {
                    [funcArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Erro"]) {
                    [errorArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Deta"]) {
                    [detailArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"ReqA"]) {
                    [reqArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"ReqE"]) {
                    [reqErrArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Dbug"]) {
                    [debugArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Verb"]) {
                    [verboseArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Fwrd"]) {
                    [funcErrArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Cras"]) {
                    [crashArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Desc"]) {
                    [infoArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }
                else if ([tag isEqualToString:@"Monitor"]) {
                    [infoArr addObject:@(i - deleteArr.count)];
                    isTag = YES;
                }

                // 第一条数据就无tag，视为其他的日志，避免崩溃
                if (!isTag && i == 0) {
                    [fileLinesDic setValue:allLines forKey:kYDLogAllLinesKey];
                    return fileLinesDic;
                }

                // 此条数据没有tag，表示完整的数据被\n分隔开了，需要拼接
                if (!isTag) {
                    [deleteArr addObject:@(i)];
                    if (!appendingStr.length) {
                        appendingStr = [allLines[(NSUInteger)(i - 1)] stringByAppendingString:@"\n"];
                        lastTagIndex = i - 1;
                    }
                    appendingStr = [[appendingStr stringByAppendingString:str] stringByAppendingString:@"\n"];

                    // 最后一条数据是无tag的时候，需要替换字符串
                    if (i == allLines.count - 2 && appendingStr.length) {
                        [allLines setObject:appendingStr atIndexedSubscript:(NSUInteger)lastTagIndex];
                        appendingStr = @"";
                    }
                    continue;
                }

                // 此条数据有tag，需要查看是否有拼接的数据未保存；如果有需要保存到上一条tag的位置上
                if (appendingStr.length) {
                    [allLines setObject:appendingStr atIndexedSubscript:(NSUInteger)lastTagIndex];
                    appendingStr = @"";
                }

                // 对此条tag数据进行替换时间戳，且将新的字符串替换原字符串
                NSString *dateStr = [self _dateStringFormTimeStamp:elements[1]];
                NSString *newStr = [dateStr stringByAppendingString:[str substringFromIndex:19]];
                [allLines setObject:newStr atIndexedSubscript:(NSUInteger)i];
            }
        }

        // 删除无用数据
        if (deleteArr.count) {
            __block NSUInteger count = 0;
            [deleteArr enumerateObjectsUsingBlock:^(NSNumber *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [allLines removeObjectAtIndex:obj.integerValue - count];
                count ++;
            }];
        }

        // 添加分类的index数组
        [fileLinesDic setValue:allLines forKey:kYDLogAllLinesKey];
        [fileLinesDic setValue:errorArr forKey:kYDLogErrorKey];
        [fileLinesDic setValue:infoArr forKey:kYDLogInfoKey];
        [fileLinesDic setValue:detailArr forKey:kYDLogDetailKey];
        [fileLinesDic setValue:debugArr forKey:kYDLogDebugKey];
        [fileLinesDic setValue:verboseArr forKey:kYDLogVerboseKey];
        [fileLinesDic setValue:reqErrArr forKey:kYDLogReqErrKey];
        [fileLinesDic setValue:reqArr forKey:kYDLogRequsetKey];
        [fileLinesDic setValue:funcArr forKey:kYDLogFuncKey];
        [fileLinesDic setValue:funcErrArr forKey:kYDLogFuncErrKey];
        [fileLinesDic setValue:crashArr forKey:kYDLogCrashKey];
    }
    
    return fileLinesDic;
}

- (NSString *)_dateStringFormTimeStamp:(NSString *)timeStamp {
    return [_dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeStamp.doubleValue]];
}

// 创建文件夹
- (NSString *)_createDirectory:(NSString *)dirName {
    
    // 获取文件夹目录：Document/dirName
    NSURL *documentDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSString *fileDir = [[documentDir path] stringByAppendingFormat:@"%@", dirName];
    
    // 创建文件夹
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileDir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:&error];
        NSURL *url = [NSURL fileURLWithPath:fileDir];
        [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
    }
    
    if (error)
        YDLogError(@"创建目录失败:%@ error:%@", dirName, error);
    
    return fileDir;
}
    
// 判断文件名格式是否正确
- (BOOL)_isValidFileName:(NSString *)fileName {
    BOOL hasPrefix = [fileName hasPrefix:@"YDLogger"];
    BOOL hasTime = [fileName componentsSeparatedByString:@"-"].count == 3 ? YES : NO;
    return (hasPrefix && hasTime);
}
@end
