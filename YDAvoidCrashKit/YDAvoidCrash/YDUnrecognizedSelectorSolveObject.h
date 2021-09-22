//
//  YDUnrecognizedSelectorSolveObject.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDUnrecognizedSelectorSolveObject : NSObject

+ (instancetype) sharedInstance;

+ (BOOL) resolveInstanceMethod:(SEL)selector;

//是否开启出错堆栈信息及本地保存，默认开启
- (void) openCallStack:(BOOL)isOpen;

@end

NS_ASSUME_NONNULL_END
