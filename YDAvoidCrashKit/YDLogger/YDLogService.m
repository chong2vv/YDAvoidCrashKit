//
//  YDLogService.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import "YDLogService.h"

@interface YDLogService ()
@property (nonatomic, strong)dispatch_queue_t dpQueue;          // 业务处理线程
@property (nonatomic, strong)NSMutableSet *uploadingSet;        // 正在上传的文件名集合
@property (nonatomic, strong)NSOperationQueue *opQueue;         // 上传日志的队列
@property (nonatomic, strong)dispatch_semaphore_t semaphore;    // 信号量，保证opQueue同步执行

@property (nonatomic, copy)NSString *logFileDir;                // 日志文件夹路径
@end

/**
 创建NSInvocationOperation时，用到的方法的参数的key
 */
static NSString * const kYDLoggerFilePathKey = @"YDLoggerFilePath";
static NSString * const kYDLoggerZipPathKey = @"YDLoggerZipPath";
static NSString * const kYDLoggerLogTypeKey = @"YDLoggerLogType";

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
    }
    
    return self;
}

- (void)startLogNeedHook:(BOOL)hook {
    [[YDMmapLogService shared] setLogLevel:YDLogLevelDetail];
    
    // 开起日志
    [[YDMmapLogService shared] startLoggerNeedHook:hook];
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

// 清除历史遗留的日志文件
- (void)_cleanLogFile {
    NSString *fileDir = _logFileDir;
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm subpathsOfDirectoryAtPath:fileDir error:nil];
    if (!files) return;
    
    // fileDir文件夹下的所有文件，将超过YDLOG_EXPIRY_TIME时间限制的文件删除
    for (int i = 0; i < (NSInteger)files.count; ++i) {
        @autoreleasepool {
            NSString *fileName = files[i];
            if (![self _isValidFileName:fileName]) continue ;
            [fm removeItemAtPath:[fileDir stringByAppendingPathComponent:fileName] error:nil];
        }
    }
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
    BOOL hasPrefix = [fileName hasPrefix:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
    BOOL hasTime = [fileName componentsSeparatedByString:@"-"].count == 3 ? YES : NO;
    return (hasPrefix && hasTime);
}
@end
