//
//  CALayer+YDAvoidCrash.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod;

@end

NS_ASSUME_NONNULL_END
