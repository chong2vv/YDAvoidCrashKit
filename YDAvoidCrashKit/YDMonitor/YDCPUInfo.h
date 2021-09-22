//
//  YDCPUInfo.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDCPUInfo : NSObject

/**
 设置CPU记录的使用率，默认为超过80%开始记录。
 */
+ (void)setCPUMonitorRate:(NSInteger) rate;

+ (void)updateCPU;

@end

NS_ASSUME_NONNULL_END
