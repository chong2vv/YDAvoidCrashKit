//
//  YDAvoidCrash.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import <Foundation/Foundation.h>

/**
 *  if you want to get the reason that can cause crash, you can add observer notification in AppDelegate.
 *  for example:
 *
 *  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealwithCrashMessage:) name:AvoidCrashNotification object:nil];
 *
 *  ===========================================================================
 *
 *  你如果想要得到导致崩溃的原因，你可以在AppDelegate中监听通知，代码如上。
 *  不管你在哪个线程导致的crash,监听通知的方法都会在主线程中
 *
 */
#define AvoidCrashNotification @"AvoidCrashNotification"

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

//user can ignore below define
#define AvoidCrashDefaultReturnNil  @"This framework default is to return nil to avoid crash."
#define AvoidCrashDefaultIgnore     @"This framework default is to ignore this operation to avoid crash."


#ifdef DEBUG

#define  YDAvoidCrashLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])

#define  YDAvoidTLog(_var) ({ NSString *name = @#_var; NSLog(@"%@: %@ -> %p : %@", name, [_var class], _var, _var); })

#else

#define YDAvoidCrashLog(...)
#endif


@interface YDAvoidCrash : NSObject

/**
 * 一般出现找不到方法，多数是 服务端返回数据类型问题导致的, NSNUll NSArray  NSString NSDictionary 所以拦截 NS开头 和一些确定类开头的，如@[@"NS", @"YD"]; 防止拦截其它造成一些问题。（已知键盘弹起）,开启前设置
 *
 */
+ (void)setAvoidCrashEnableMethodPrefixList:(NSArray<NSString *> *)enableMethodPrefixList;

/**
 获取当前设置的防拦截前缀
 */
+ (NSArray *)getAvoidCrashEnableMethodPrefixList;


/**
 * 设置信息回掉收集，可以将回调结果上行服务端
 */
+ (void)setupBlock:(void(^)(NSException *exception,NSString *defaultToDo,BOOL upload))aBlock;

/**
 *  become effective . You can call becomeEffective method in AppDelegate didFinishLaunchingWithOptions
 *
 *  开始生效.你可以在AppDelegate的didFinishLaunchingWithOptions方法中调用becomeEffective方法
 *
 *  这是全局生效，若你只需要部分生效，你可以单个进行处理，比如:
 *  [NSArray avoidCrashExchangeMethod];
 *  [NSMutableArray avoidCrashExchangeMethod];
 *  .................
 *  .................
 *  @param openavoidcrash 需要开启的配置类
 *  @param openLogger 是否同时开启日志
 */
+ (void)becomeEffective:(NSArray<NSString *> *)openavoidcrash openLogger:(BOOL) openLogger;

/**
 直接开启所有拦截，不由服务端控制
 @param openLogger 是否同时开启日志
 */
+ (void)becomeAllEffectiveWithLogger:(BOOL) openLogger;


/**
 * 以 avoidCrash_ 加模块名命名用于其它模块对各自 crash的处理
 */
//- (void)avoidCrash_模块名


//user can ignore below method <用户可以忽略以下方法>

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo;

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo upload:(BOOL)upload;

@end

