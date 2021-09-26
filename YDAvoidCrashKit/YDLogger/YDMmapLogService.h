//
//  YDMmapLogService.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import <Foundation/Foundation.h>

#define YDFILE_PREFIXNAME  @"/YDLog"                               // 默认文件名的前缀

/**
 日志记录宏，只记录到本地，使用方法和NSLog相同
 根据日志level的不同，记录的日志不同
 当调用setLogLevel:设置需要记录的日志level为YDLogDebug时，那么YDLogDebug等级以下的等级（含YDLogDebug）都会被记录
 默认设置为YDLogDetail
 
 YDLogError()           记录错误信息，适用于线上/线下环境，格式：@"Erro timeStamp error"
 YDLogInfo()            记录极简信息，适用于线上/线下环境，格式：@"Info timeStamp info"
 YDLogDetail()          记录详细信息，适用于线上/线下环境，格式：@"Deta timeStamp [thread] func str"
 YDLogMonitorDetail()   记录详细信息，适用于线上/线下环境，格式：@"Deta timeStamp [thread] str"
 YDLogDebug()           记录开发信息，适用于Debug环境，格式：@"Dbug timeStamp str"
 YDLogVerbose()         记录复杂信息，适用于Debug环境，格式：@"Verb timeStamp [thread] func in file:line desc"
 */
#define YDLogError(fmt, ...)    [[YDMmapLogService shared] logError:YES frmt:(fmt), ##__VA_ARGS__]
#define YDLogInfo(fmt, ...)     [[YDMmapLogService shared] logInfo:YES frmt:(fmt), ##__VA_ARGS__]
#define YDLogDetail(fmt, ...)   [[YDMmapLogService shared] logDetail:NO func:__PRETTY_FUNCTION__ frmt:(fmt), ##__VA_ARGS__]
#define YDLogMonitorDetail(fmt, ...)   [[YDMmapLogService shared] logMonitorDetail:NO frmt:(fmt), ##__VA_ARGS__]
#define YDLogDebug(fmt, ...)    [[YDMmapLogService shared] logDebug:YES frmt:(fmt), ##__VA_ARGS__]
#define YDLogVerbose(fmt, ...)  [[YDMmapLogService shared] logVerbose:NO func:__PRETTY_FUNCTION__ file:__FILE__ line:__LINE__ frmt:(fmt), ##__VA_ARGS__]


/**
 super方法的调用

 @param ... 将参数传入其中，自动封装成数组
 @return super方法的返回值
 */
#define YD_SUPER_CALL(...) [YDMmapLogService superCall:self cmd:_cmd args:@[__VA_ARGS__]]

/**
 自定义错误码

 - YDMmapLogErrorHasOpened: 已经有文件打开
 - YDMmapLogErrorHasClosed: 文件已经被关闭
 - YDMmapLogErrorPathInvalid: 文件路径非法
 */
typedef NS_ENUM(NSInteger, YDMmapLogError) {
    YDMmapLogErrorHasOpened = -1,
    YDMmapLogErrorHasClosed = -2,
    YDMmapLogErrorPathInvalid = -3,
};

/**
 YDLog的日志等级

 - YDLogLevelNone:      占位无实际意义
 - YDLogLevelError:     Error   level:记录程序的异常情况
 - YDLogLevelInfo:      Info    level:记录埋点
 - YDLogLevelDetail:    Detail  level:记录埋点以及其他详细信息
 - YDLogLevelDebug:     Debug   level:记录调试时的埋点
 - YDLogLevelVerbose:   Verbose level:记录调试时的埋点及其他全部信息
 */
typedef NS_ENUM(NSUInteger, YDLogLevel) {
    YDLogLevelNone,
    YDLogLevelError,
    YDLogLevelInfo,
    YDLogLevelDetail,
    YDLogLevelDebug,
    YDLogLevelVerbose,
};

NS_ASSUME_NONNULL_BEGIN

@interface YDMmapLogService : NSObject

@property (nonatomic, copy, readonly)NSString       *fileName;    // 文件名
@property (nonatomic, copy, readonly)NSString       *filePath;    // 文件路径
@property (nonatomic, strong, readonly)NSThread     *logThread;   // 日志记录的线程
@property (nonatomic, assign, readonly)YDLogLevel   level;        // 日志level，默认为YDLogLevelDetail


+ (instancetype)shared;


/**
 是否已有文件被开启

 @return 文件是否开启
 */
- (BOOL)hasOpened;


/**
 动态设置类名和类名前缀的白名单，需要在开启日志前调用

 @param list 类名和类名前缀的白名单
 */
- (void)setClassWhiteList:(NSSet * _Nullable)list;


/**
 动态设置类名和类名前缀的黑名单，需要在开启日志前调用

 @param list 类名的黑名单
 @param preList 类名前缀的黑名单
 */
- (void)setClassBlackList:(NSSet * _Nullable)list
                  preList:(NSSet * _Nullable)preList;


/**
 动态设置方法名的黑名单，需要在开启日志前调用

 @param list 方法名的黑名单；key为方法名，value是类名的数组
 */
- (void)setMethodBlackList:(NSDictionary * _Nullable)list;


/**
 设置日志等级，默认为YDLogLevelDetail

 @param level 日志等级
 */
- (void)setLogLevel:(YDLogLevel)level;


/**
 快速开启日志，不需要hook模式

 @return 日志开启失败的原因，成功在返回nil
 */
- (nullable NSError *)startLogger;


/**
 开启日志，且可动态控制hook模式

 @param hook 是否开启hook模式
 @return 日志开启失败的原因，成功在返回nil
 */
- (nullable NSError *)startLoggerNeedHook:(BOOL)hook;


/**
 打开指定文件，且是只读模式
 
 @param path 指定文件路径
 @return 日志开启失败的原因，成功在返回nil
 */
- (nullable NSError *)openFileReadOnly:(NSString *)path;


/**
 开启指定日志，且自定义日志文件名

 @param path 指定日志文件路径
 @param name 自定义日志名
 @return 日志开启失败的原因，成功在返回nil
 */
- (nullable NSError *)openFile:(NSString *)path
                      fileName:(NSString *)name;


/**
 关闭当前日志，重新创建指定日志

 @param fileName 日志名
 */
- (void)reopenFileReadWrite:(NSString *)fileName;


/**
 强制I/O将当前虚拟内存映射中的数据写回磁盘中
 */
- (void)syncCurrentFileData;


/**
 在APP被杀死前调用的方法，关闭当前文件的虚拟内存映射，主要用于恢复日志文件的真实大小
*/
- (void)closeFileBeforeShutDown;


/**
 关闭当前文件的虚拟内存映射，无论关闭成功或失败，都可以重新打开新的日志
 */
- (void)closeFile;


/**
 记录详细的信息，且日志level为YDLogLevelVerbose
 @"Verb timeStamp [thread] func in file:line desc"

 @param print 是否用NSLog打印
 @param func 当前方法
 @param file 文件名
 @param line 代码行数
 @param frmt 字符串的格式
 */
- (void)logVerbose:(BOOL)print
              func:(const char *)func
              file:(char *)file
              line:(NSInteger)line
              frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(5, 6);



/**
 记录debug的信息，且日志level为YDLogLevelDebug
 @"Dbug timeStamp str"
 
 @param print 是否用NSLog打印
 @param frmt 字符串的格式
 */
- (void)logDebug:(BOOL)print
            frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(2, 3);


/**
 记录包含线程信息的自定义信息，且日志level为YDLogLevelDetail
 @"Deta timeStamp [thread] func detail"
 
 @param print 是否用NSLog打印
 @param func 当前方法
 @param frmt 字符串的格式
 */
- (void)logDetail:(BOOL)print
             func:(const char *)func
             frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(3, 4);

/**
 记录包含线程信息的性能检测信息，且日志level为YDLogLevelDetail
 @"Deta timeStamp [thread] func detail"
 
 @param print 是否用NSLog打印
 @param frmt 字符串的格式
 */
- (void)logMonitorDetail:(BOOL)print
             frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(2, 3);


/**
 记录极简自定义信息，且日志level为YDLogLevelInfo
 @"Info timeStamp info"
 
 @param print 是否用NSLog打印
 @param frmt 字符串的格式
 */
- (void)logInfo:(BOOL)print
           frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(2, 3);


/**
 记录错误信息，且日志level为YDLogLevelError
 @"Erro timeStamp error"

 @param print 是否用NSLog打印
 @param frmt 字符串的格式
 */
- (void)logError:(BOOL)print
            frmt:(NSString *)frmt, ... NS_FORMAT_FUNCTION(2, 3);


/**
 记录http请求成功的日志
 @"ReqA timeStamp <url code>:args_repStr"
 
 @param url http请求的url
 @param code 请求的状态码
 @param args 请求的参数
 @param repStr 返回的数据，json字符串
 */
- (void)logHttpRequest:(NSString *)url
            statusCode:(NSInteger)code
             arguments:(NSString *)args
           responseStr:(NSString *)repStr;


/**
 记录http请求失败的日志，不受日志level限制
 @"ReqE %0.3f timeStamp <url code>:args_error"
 
 @param url http请求的url
 @param code 请求的状态码
 @param args 请求的参数
 @param error 请求的错误信息
 */
- (void)logHttpRequest:(NSString *)url
            statusCode:(NSInteger)code
             arguments:(NSString *)args
                 error:(NSError *)error;


/**
 记录方法调用，不受日志level限制
 @"Func timeStamp [thread] object:[cmd]"
 
 @param object 对象实例
 @param cmd 调用的方法
 */
- (void)logObject:(id)object
              cmd:(SEL)cmd;


/**
 记录方法调用进入转发流程的日志（未找到方法），不受日志level限制
 @"Fwrd timeStamp [thread] object:[cmd] into msg forward:[fwdCmd]"
 
 @param object 对象实例
 @param cmd 未找到的方法名
 @param fwdCmd 当前进入转发流程中的某个方法
 */
- (void)logMsgForward:(id)object
                  cmd:(SEL)cmd
           forwardCmd:(SEL)fwdCmd;


/**
 只在记录崩溃信息时使用，其他地方不可使用
 
 @param crash 崩溃信息
 */
- (void)logCrash:(id)crash;


/**
 记录二进制数据，不受日志level限制
 
 @param data 二进制数据
 */
- (void)logData:(NSData *)data;


/**
 根据指定文件名获取在document/YDFILE_PREFIXNAME/下的文件
 如果文件不存在则创建新的文件，为确保生成的文件的唯一性，加入了时间戳和mach_absolute_time
 文件名格式 @"name-timeStamp-mach_absolute_time"

 @param name 文件名
 @return 文件存在则返回绝对路径，若文件不存在则返回nil
 */
- (nullable NSString *)filePathWithName:(NSString *)name;


/**
 super方法调用的OC语言的封装

 @param target 方法的接受者，传self即可
 @param cmd 调用的方法名
 @param args 参数的数组
 @return super方法的返回值
 */
+ (id)superCall:(id)target
            cmd:(SEL)cmd
           args:(NSArray * _Nullable)args;

@end

NS_ASSUME_NONNULL_END
