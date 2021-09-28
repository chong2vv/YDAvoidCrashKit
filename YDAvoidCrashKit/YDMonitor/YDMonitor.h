//
//  YDMonitor.h
//  YDKitDemo
//
//  Created by 王远东 on 2021/9/26.
//

#import <Foundation/Foundation.h>
#import "YDCPUInfo.h"
#import "YDCallStack.h"

NS_ASSUME_NONNULL_BEGIN

@interface YDMonitor : NSObject

@property (nonatomic) BOOL isMonitoring;

+ (instancetype)shared;

- (void)beginMonitor; //开始监视卡顿
- (void)endMonitor;   //停止监视卡顿

@end

NS_ASSUME_NONNULL_END
