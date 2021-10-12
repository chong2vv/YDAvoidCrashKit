//
//  YDMmapLogService.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import "YDMmapLogService.h"
#import "YDMmapLogSwizzeling.h"
#import "YDMmapLogSwizzeling.m"
#include "YDMmapLogger.h"
#include <mach/mach_time.h>
#include <execinfo.h>

static yd_logger _logger = nil;

static NSUncaughtExceptionHandler* yd_previousUncaughtExceptionHandler;

static bool _shouldShutDown = true;      // 是否允许app结束进程

/**
 记录崩溃信息，并且关闭映射，使文件大小更新为真实大小

 @param exception 崩溃信息
 */
void yd_uncaughtExceptionHandler (NSException *exception)
{
    if (!_shouldShutDown) {
        [[YDMmapLogService shared] logCrash:exception.reason];
        [[YDMmapLogService shared] closeFileBeforeShutDown];
    }
    
    if (yd_previousUncaughtExceptionHandler)
        yd_previousUncaughtExceptionHandler(exception);
}

/**
 使用Obj-C的异常处理是得不到signal的，如果要处理它，我们还要利用unix标准的signal机制
 注册SIGABRT, SIGBUS, SIGSEGV等信号发生时的处理函数
 Xcode屏蔽了signal的回调，为此，我们需要在【lldb】中输入以下命令，signal的回调才可以进来【pro hand -p true -s false SIGABRT】

 @param sig 返回的signal类型
 */
void yd_signalHandler (int sig)
{
    if (!_shouldShutDown) {
        NSString *name = nil;
        switch (sig) {
            case SIGSEGV:
                name = @"SIGSEGV";
                break;
            case SIGBUS:
                name = @"SIGBUS";
                break;
            case SIGILL:
                name = @"SIGILL";
                break;
            case SIGABRT:
                name = @"SIGABRT";
                break;
            case SIGTRAP:
                name = @"SIGTRAP";
                break;
                
            default:
                name = [NSString stringWithFormat:@"Signal %d was raised!", sig];
        }
        
        // backtrace用来获取当前线程的调用堆栈，获取的信息存放在这里的callstack中
        // 返回值是实际获取的指针个数
        void *callstack[128];
        int frames = backtrace(callstack, 128);
        
        // backtrace_symbols将从backtrace函数获取的信息转化为一个字符串数组
        // 返回一个指向字符串数组的指针
        // 每个字符串包含了一个相对于callstack中对应元素的可打印信息，包括函数名、偏移地址、实际返回地址
        char **strs = backtrace_symbols(callstack, frames);
        NSMutableArray *callStackSymbols = [NSMutableArray arrayWithCapacity:frames];
        for (int i = 0; i < frames; i++) {
            [callStackSymbols addObject:[NSString stringWithUTF8String:strs[i]]];
        }
        free(strs);
        
        [[YDMmapLogService shared] logCrash:name];
        [[YDMmapLogService shared] logCrash:callStackSymbols];
        [[YDMmapLogService shared] closeFileBeforeShutDown];
    }
    
    raise(sig);
}

@interface YDMmapLogService ()

@property (nonatomic, copy)NSString *fileName;                  // 文件名
@property (nonatomic, copy)NSString *filePath;                  // 文件路径

@property (nonatomic, strong)NSThread *logThread;               // 日志记录的线程

@property (nonatomic, assign)BOOL hasHook;                      // 是否已经开启了hook模式

@property (nonatomic, assign)YDLogLevel level;                  // 日志level，默认为YDLogLevelDetail

@end
@implementation YDMmapLogService

+ (instancetype)shared {
    static YDMmapLogService *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YDMmapLogService alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _fileName = @"YDLogger";
        _filePath = [self filePathWithName:_fileName];
        const char *filePath = [_filePath UTF8String];
        
        // 通过构造函数，设定默认的文件路径
        _logger = yd_logger((const_cast<char *>(filePath)));
        
#if YDHOOK_AUTO_SWIZZLE
        _hasHook = YES;
#endif
        
        _logThread = [[NSThread alloc] initWithTarget:self selector:@selector(_openThread) object:nil];
        [_logThread setName:@"com.WYD.YDLogThread"];
        // 设置线程栈空间大小
        _logThread.stackSize = 1024 * 1024;
        [_logThread start];
        
        // 默认日志level为YDLogLevelDetail
        _level = YDLogLevelDetail;
    }
    
    return self;
}


#pragma mark - API

- (BOOL)hasOpened {
    return _logger.hasOpened();
}

- (void)setClassWhiteList:(NSSet *)list {
    _yd_set_dynamic_cwl(list);
}

- (void)setClassBlackList:(NSSet *)list preList:(NSSet *)preList {
    _yd_set_dynamic_cbl(list, preList);
}

- (void)setMethodBlackList:(NSDictionary *)list {
    _yd_set_dynamic_mbl(list);
}

- (void)setLogLevel:(YDLogLevel)level {
    _level = level;
}

- (NSError *)startLogger {
    // 程序崩溃处理
    yd_previousUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
    NSSetUncaughtExceptionHandler(&yd_uncaughtExceptionHandler);
    signal(SIGSEGV, yd_signalHandler);
    signal(SIGBUS, yd_signalHandler);
    signal(SIGILL, yd_signalHandler);
    signal(SIGABRT, yd_signalHandler);
    signal(SIGTRAP, yd_signalHandler);
    return [self _openFile];
}

- (NSError *)startLoggerNeedHook:(BOOL)hook {
    
    // 是否开启hook模式
    if (!_hasHook && hook) {
        _yd_logger_inject_entry_nolock();
        _hasHook = YES;
    }
    
    return [self startLogger];
}

- (NSError *)openFileReadOnly:(NSString *)path {
    if ([self hasOpened])
        return [self _errorWithCode:YDMmapLogErrorHasOpened descStr:[NSString stringWithFormat:@"<file:%@>已被打开，请勿重复映射文件", _filePath]];
    
    if (!path || !path.length)
        return [self _errorWithCode:YDMmapLogErrorPathInvalid descStr:[NSString stringWithFormat:@"<file:%@>无效的path", _filePath]];
    
    // 重新设置文件路径和读写模式
    const char *filePath = [path UTF8String];
    _logger.setFilePath(filePath);
    _logger.setReadWrite(false);
    
    _filePath = path;
    
    // 开启日志
    return [self _openFile];
}

- (NSError *)openFile:(NSString *)path fileName:(NSString *)name {
    if ([self hasOpened])
        return [self _errorWithCode:YDMmapLogErrorHasOpened descStr:[NSString stringWithFormat:@"<file:%@>已被打开，请勿重复映射文件", _filePath]];
    
    if (!path || !path.length)
        return [self _errorWithCode:YDMmapLogErrorPathInvalid descStr:[NSString stringWithFormat:@"<file:%@>无效的path", _filePath]];
    
    const char *filePath = [path UTF8String];
    _logger.setFilePath(filePath);
    _logger.setReadWrite(true);
    
    // 重新设置文件名字
    _filePath = path;
    _fileName = name;
    
    return [self _openFile];
}

- (void)reopenFileReadWrite:(NSString *)fileName {
    [self performSelector:@selector(_reopenFileReadWriteNoLock:) onThread:_logThread withObject:nil waitUntilDone:YES];
}

- (void)syncCurrentFileData {
    [self performSelector:@selector(_syncCurrentFileDataNoLock) onThread:_logThread withObject:nil waitUntilDone:YES];
}

- (void)closeFileBeforeShutDown {
    [self closeFile];

    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    while (!_shouldShutDown) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            if ([mode containsString:@"RunLoopCommonModes"]) continue ;
            CFRunLoopRunInMode((CFStringRef)mode, .4f, false);
        }
    }
    CFRelease(allModes);
}

- (void)closeFile {
    [self performSelector:@selector(_closeFileNoLock) onThread:_logThread withObject:nil waitUntilDone:YES];
}

- (void)logVerbose:(BOOL)print func:(const char *)func file:(char *)file line:(NSInteger)line frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelVerbose) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *desc = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Verb %0.3f [%@] %s in %@:%tu %@\n", [self _timeStamp], [self _currentThreadInfo], func, [NSString stringWithUTF8String:file].lastPathComponent, line, desc];
        
        // 在日志记录的线程完成数据写入，保证线程的安全
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logDebug:(BOOL)print frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelDebug) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *obj = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Dbug %0.3f %@\n", [self _timeStamp], obj];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logDetail:(BOOL)print func:(const char *)func frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelDetail) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *detail = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Deta %0.3f [%@] %s:%@\n", [self _timeStamp], [self _currentThreadInfo], func, detail];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logMonitorDetail:(BOOL)print frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelDetail) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *detail = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Monitor %0.3f [%@] :%@\n", [self _timeStamp], [self _currentThreadInfo], detail];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logInfo:(BOOL)print frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelInfo) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *info = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Info %0.3f %@\n", [self _timeStamp], info];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logError:(BOOL)print frmt:(NSString *)frmt, ... {
    if (_level < YDLogLevelError) return;
    if (!frmt) return;
    
    @autoreleasepool {
        va_list args;
        va_start(args, frmt);
        NSString *error = [[NSString alloc] initWithFormat:frmt arguments:args];
        va_end(args);
        
        NSString *string = [NSString stringWithFormat:@"Erro %0.3f %@\n", [self _timeStamp], error];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
        if (print) NSLog(@"%@", string);
    }
}

- (void)logHttpRequest:(NSString *)url statusCode:(NSInteger)code arguments:(NSString *)args responseStr:(NSString *)repStr {
    @autoreleasepool {
        NSString *string = [NSString stringWithFormat:@"ReqA %0.3f <%@ %tu>:%@_%@\n", [self _timeStamp], url, code, args, repStr];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
    }
}

- (void)logHttpRequest:(NSString *)url statusCode:(NSInteger)code arguments:(NSString *)args error:(NSError *)error {
    @autoreleasepool {
        NSString *string = [NSString stringWithFormat:@"ReqE %0.3f <%@ %tu>:%@_%@\n", [self _timeStamp], url, code, args, error];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
    }
}

- (void)logObject:(id)object cmd:(SEL)cmd {
    @autoreleasepool {
        NSString *string = [NSString stringWithFormat:@"Func %0.3f [%@] %@:[%@]\n", [self _timeStamp], [self _currentThreadInfo], object, NSStringFromSelector(cmd)];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
    }
}

- (void)logMsgForward:(id)object cmd:(SEL)cmd forwardCmd:(SEL)fwdCmd {
    @autoreleasepool {
        NSString *string = [NSString stringWithFormat:@"Fwrd %0.3f [%@] %@:[%@] into msg forward:[%@]\n", [self _timeStamp], [self _currentThreadInfo], object, NSStringFromSelector(cmd), NSStringFromSelector(fwdCmd)];
        [self performSelector:@selector(_logStringNoLock:) onThread:self.logThread withObject:string waitUntilDone:NO];
    }
}

- (void)logCrash:(id)crash {
    NSString *string = [NSString stringWithFormat:@"Cras %0.3f %@\n", [self _timeStamp], crash];
    if ([[NSThread currentThread] isEqual:_logThread]) {
        [self _logStringNoLock:string];
    }
    else {
        [self performSelectorOnMainThread:@selector(_logStringNoLock:) withObject:string waitUntilDone:YES];
    }
}

- (void)logData:(NSData *)data {
    if ([self hasOpened] == NO) {
        NSLog(@"文件未打开，请先打开文件再写入内容");
        return ;
    }
    
    // 单条数据不可以超过文件大小的最小值
    if (data.length > _logger.fileSizeMin()) {
        NSLog(@"字符串过长，超出文件最大值%uKB，无法写入", (_logger.fileSizeMin() / 1024));
        return ;
    }
    // 二进制数据的字节长度如果超过栈空间的3/4，则无法写入；由于静态数组的分配在栈空间上，所以字节数组的长度不是任意长度
    else if (data.length > _logThread.stackSize * 3 / 4) {
        NSLog(@"字符串过长，超出栈空间大小，无法写入");
        return ;
    }
    
    [self performSelector:@selector(_logDataNoLock:) onThread:self.logThread withObject:data waitUntilDone:NO];
}

- (NSString *)filePathWithName:(NSString *)name {
    
    // 获取文件目录，Document/
    NSURL *documentDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].firstObject;
    NSString *fileDir = [[documentDir path] stringByAppendingString:YDFILE_PREFIXNAME];
    
    // 创建文件夹，并设置属性，不备份到icloud
    if ([[NSFileManager defaultManager] fileExistsAtPath:fileDir] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
        [self _addSkipBackupAttributeToItemAtURL:fileDir];
    }
    
    // 文件名通过时间戳和mach_absolute_time来确保在本机中的唯一性
    NSString *filePath = [NSString stringWithFormat:@"%@/%@-%0.0f-%llu", fileDir, name, [self _timeStamp] ,mach_absolute_time()];
    
    // 创建文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath] == NO) {
        if ([[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil] == NO) {
            return nil;
        }
    }
    
    return filePath;
}

+ (id)superCall:(id)target cmd:(SEL)cmd args:(NSArray *)args {
    return _yd_logger_super_function(target, cmd, args);
}


#pragma mark - Private methods

- (NSError *)_openFile {
    if ([self hasOpened])
        return [self _errorWithCode:YDMmapLogErrorHasOpened descStr:[NSString stringWithFormat:@"<file:%@>已被打开，请勿重复映射文件", _filePath]];
    
    // 将文件映射到虚拟内存中
    int errCode = _logger.mmapFile();
    
    if (errCode != 0) {
        return [self _errorWithCode:errCode descChar:_logger.errorDescription(errCode).c_str()];
    }
    
    // 每当有读写文件被打开时，再设置不允许app结束进程，需要先关闭文件再结束进程
    if (_logger.readWrite())
        _shouldShutDown = false;
    
    return nil;
}

- (NSError *)_reopenFileReadWriteNoLock:(NSString *)fileName {
    // 关闭当前文件映射
    [self _closeFileNoLock];
    
    // 不论关闭成功或失败，都将生成新的文件，并开启新的文件映射
    NSString *path = [self filePathWithName:fileName];
    return [self openFile:path fileName:fileName];
}

- (void)_syncCurrentFileDataNoLock {
    _logger.syncAll();
}

- (NSError *)_closeFileNoLock {
    if (![self hasOpened])
        return [self _errorWithCode:YDMmapLogErrorHasClosed descStr:@"当前没有文件被打开"];
    
    // 强制同步所有数据到硬盘
    _logger.syncAll();
    
    // 关闭内存映射
    int errCode = _logger.munmapFile();
    
    // 不论关闭成功或失败，都允许关闭当前App了
    _shouldShutDown = true;
    
    if (errCode != 0)
        return [self _errorWithCode:errCode descChar:_logger.errorDescription(errCode).c_str()];
    
    _filePath = nil;
    _fileName = nil;
    
    return nil;
}

// 获取时间戳
- (double)_timeStamp {
    return [[NSDate date] timeIntervalSince1970];
}

// 获取线程信息
- (NSString *)_currentThreadInfo {
    if ([NSThread currentThread].name && [NSThread currentThread].name.length) {
        return [NSThread currentThread].name;
    }
    else {
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"=,"];
        return [[NSThread currentThread].description componentsSeparatedByCharactersInSet:set][1];
    }
}

// 线程不安全的字符串类型的数据写入
- (void)_logStringNoLock:(NSString *)string {
    if ([self hasOpened] == NO) {
        NSLog(@"文件未打开，请先打开文件再写入内容");
        return ;
    }
    
    // 字符串转二进制，unicod编码的字符串，一个中文为3个字节
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    // 单条数据不可以超过文件大小的最小值
    if (stringData.length > _logger.fileSizeMin()) {
        string = [NSString stringWithFormat:@"Erro %0.3f 字符串过长(%tuKB)，超出文件最大值%uKB，无法写入\n", [self _timeStamp], stringData.length / 1024, (_logger.fileSizeMin() / 1024)];
        stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    // 二进制数据的字节长度如果超过栈空间的3/4，则无法写入；由于静态数组的分配在栈空间上，所以字节数组的长度不是任意长度
    else if (stringData.length > _logThread.stackSize * 3 / 4) {
        string = [NSString stringWithFormat:@"Erro %0.3f 字符串过长(%tuKB)，超出栈空间大小，无法写入\n", [self _timeStamp], stringData.length / 1024];
        stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    [self _logDataNoLock:stringData];
}

// 线程不安全的二进制数据写入
- (void)_logDataNoLock:(NSData *)data {
    if (_logger.readWrite() == NO) {
        NSLog(@"只读文件，不支持写操作");
        return ;
    }
    
    if (data == nil || data.length < 1) {
        NSLog(@"无效数据，无法写入文件");
        return ;
    }
    
    // 将NSData转成字节数组
    uint8_t dataBytes[data.length];
    [data getBytes:&dataBytes length:data.length];
    
    // 如果文件没有足够的空间，增加文件大小，再写入
    if (_logger.totalSize() + data.length > _logger.fileSizeMax())
        if ([self _increaseFileSize])
            return;
    
    // 写入内存
    int err = _logger.mRecordeNext(dataBytes, data.length);
    NSAssert(err == 0, @"日志写入数据操作异常");
}

// 增加文件大小，直到达到最大值；若达到最大值，则关闭当前文件，开启新的文件
- (NSError *)_increaseFileSize {
    // 增加文件大小
    int errCode = _logger.increaseFileSize();
    
    // 文件过大，开启新的文件
    if (errCode != 0) {
        return [self _reopenFileReadWriteNoLock:_fileName];
    }
    else {
        return nil;
    }
}

// 开启日志线程的runloop
- (void)_openThread {
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
}

// 修改文件备份属性
- (NSError *)_addSkipBackupAttributeToItemAtURL:(NSString *)path {
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    
    [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return error;
}

// 生成NSError
- (NSError *)_errorWithCode:(NSInteger)code descStr:(NSString *)desc {
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:@{NSLocalizedDescriptionKey:desc}];
}

// 生成NSError
- (NSError *)_errorWithCode:(int)code descChar:(const char *)desc {
    return [NSError errorWithDomain:NSStringFromClass([self class]) code:code userInfo:@{NSLocalizedDescriptionKey:[[NSString alloc] initWithCString:desc encoding:NSUTF8StringEncoding]}];
}


@end
