//
//  YDMainThread.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/26.
//

#import "YDMainThread.h"

static const void *kYDMainQueueKey = @"yd_call_mainQueue";
static void *kYDMainQueueContext = @"yd_call_mainQueue";

@implementation YDMainThread

+ (BOOL)yd_dispatch_is_main_queue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), kYDMainQueueKey, kYDMainQueueContext, NULL);
    });
    return dispatch_get_specific(kYDMainQueueKey) == kYDMainQueueContext;
}

void yd_dispatch_async_main_safe(dispatch_block_t block) {
    if (!block) {
        return;
    }
    if (![YDMainThread yd_dispatch_is_main_queue]) {
        dispatch_async(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

void yd_dispatch_sync_main_safe(dispatch_block_t block) {
    if (!block) {
        return;
    }
    if (![YDMainThread yd_dispatch_is_main_queue]) {
        dispatch_sync(dispatch_get_main_queue(), block);
    }else{
        block();
    }
}

@end
