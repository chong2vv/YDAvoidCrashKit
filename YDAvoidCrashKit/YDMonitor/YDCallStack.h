//
//  YDCallStack.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/17.
//

#import <Foundation/Foundation.h>
#import "YDCallStackLib.h"

typedef NS_ENUM(NSUInteger, YDCallStackType) {
    YDCallStackTypeAll,     //全部线程
    YDCallStackTypeMain,    //主线程
    YDCallStackTypeCurrent  //当前线程
};

@interface YDCallStack : NSObject

+ (NSString *)YDCallStackWithType:(YDCallStackType)type;

//多用类型常量，少用#define预处理指令。。。
extern NSString *YDStackOfThread(thread_t thread);

@end

