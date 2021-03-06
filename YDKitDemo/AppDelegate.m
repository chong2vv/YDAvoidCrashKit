//
//  AppDelegate.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "AppDelegate.h"
#import "YDTestAction.h"
#import "YDAvoidCrashKit.h"

#import <objc/runtime.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置允许防崩溃类前缀
    [YDAvoidCrash setAvoidCrashEnableMethodPrefixList:@[@"NS",@"YD"]];
    //接收异常的回调处理，可以用来上报等
    [YDAvoidCrash setupBlock:^(NSException *exception, NSString *defaultToDo, BOOL upload) {
            
    }];
    [YDAvoidCrash becomeAllEffectiveWithLogger:YES];
    
    [[YDMonitor shared] beginMonitor];
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
