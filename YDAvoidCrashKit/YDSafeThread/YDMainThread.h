//
//  YDMainThread.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void yd_dispatch_async_main_safe(dispatch_block_t block);
FOUNDATION_EXPORT void yd_dispatch_sync_main_safe(dispatch_block_t block);

@interface YDMainThread : NSObject

@end

NS_ASSUME_NONNULL_END
