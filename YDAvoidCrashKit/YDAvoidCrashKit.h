//
//  YDKit.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import <Foundation/Foundation.h>
//YDAvoidCrash 防崩溃库
#import "YDAvoidCrash.h"
//YDLogger 日志库
#import "YDLogService.h"

//YDLogger UI库 可快速查看本地的YDLog信息
#import "YDLoggerUI.h"

/**
 YDSafeThread 多线程下数据操作可以使用:
 YDThreadSafeMutableSet、YDThreadSafeMutableArray、YDThreadSafeMutableDictionary
 替换系统的：
 NSMutableSet、NSMutableArray、NSMutableDictionary
 来进行数据安全操作。
 
 同时可以使用dispatch_async_main_safe、dispatch_sync_main_safe方法快速获取安全主线程进行操作，详细可看YDSafeThread下的类。
 */
#import "YDSafeThread.h"

//卡顿监测（包括CPU使用率），监控结果可以再YDLog中查看
#import "YDMonitor.h"
