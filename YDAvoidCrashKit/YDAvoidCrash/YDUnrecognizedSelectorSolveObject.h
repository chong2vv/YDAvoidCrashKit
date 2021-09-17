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

- (void)openCallStack:(BOOL)isOpen;

@end

NS_ASSUME_NONNULL_END
