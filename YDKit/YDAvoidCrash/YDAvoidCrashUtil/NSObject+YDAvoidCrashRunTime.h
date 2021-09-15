//
//  NSObject+YDAvoidCrashRunTime.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (YDAvoidCrashRunTime)

/**
 *  类方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1
 *  @param method2Sel 方法2
 */
+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;

/**
 *  对象方法的交换
 *
 *  @param anClass    哪个类
 *  @param method1Sel 方法1(原本的方法)
 *  @param method2Sel 方法2(要替换成的方法)
 */
+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel;

/**
 *  获取固定前缀的所有方法名
 *
 *  @param prefix    前缀
 */
- (NSArray <NSString *> *)getAvoidCrashMethodByListPrefix:(NSString *)prefix;

/**
 *  获取固定前缀的所有方法名
 *
 *  @param prefix    前缀
 */
+ (NSArray <NSString *> *)getAvoidCrashMethodByListPrefix:(NSString *)prefix;

@end

NS_ASSUME_NONNULL_END
