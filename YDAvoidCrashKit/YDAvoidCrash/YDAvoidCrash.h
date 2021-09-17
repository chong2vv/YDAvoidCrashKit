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



//user can ignore below define
#define AvoidCrashDefaultReturnNil  @"This framework default is to return nil to avoid crash."
#define AvoidCrashDefaultIgnore     @"This framework default is to ignore this operation to avoid crash."


#ifdef DEBUG

#define  AvoidCrashLog(...) NSLog(@"%@",[NSString stringWithFormat:__VA_ARGS__])

#else

#define AvoidCrashLog(...)
#endif


@interface YDAvoidCrash : NSObject

/**
 * 一般出现找不到方法，多数是 服务端返回数据类型问题导致的, NSNUll NSArray  NSString NSDictionary 所以拦截 NS开头 和一些确定类开头的，如@[@"NS", @"YD"]; 防止拦截其它造成一些问题。（已知键盘弹起）,开启前设置
 *
 */
+ (void)setAvoidCrashEnableMethodPrefixList:(NSArray<NSString *> *)enableMethodPrefixList;

+ (NSArray *)getAvoidCrashEnableMethodPrefixList;


/**
 * 设置信息回掉收集
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
 */
+ (void)becomeEffective:(NSArray<NSString *> *)openavoidcrash;

// 直接开启所有拦截，不由服务端控制
+ (void)becomeAllEffective;

/**
 * 以 avoidCrash_ 加模块名命名用于其它模块对各自 crash的处理
 */
//- (void)avoidCrash_模块名


//user can ignore below method <用户可以忽略以下方法>

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo;

+ (void)noteErrorWithException:(NSException *)exception defaultToDo:(NSString *)defaultToDo upload:(BOOL)upload;

@end

