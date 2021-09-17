//
//  YDUnrecognizedSelectorSolveObject.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "YDUnrecognizedSelectorSolveObject.h"
#import <objc/runtime.h>
#import "YDCallStack.h"
#import "YDAvoidDB.h"

@interface YDUnrecognizedSelectorSolveObject ()

@property (nonatomic, assign) BOOL isOpenCallStack;

@end

@implementation YDUnrecognizedSelectorSolveObject

+ (instancetype) sharedInstance{
    static YDUnrecognizedSelectorSolveObject *unrecognizedSelectorSolveObject;
    static dispatch_once_t  once_token;
    dispatch_once(&once_token, ^{
        unrecognizedSelectorSolveObject = [[YDUnrecognizedSelectorSolveObject alloc] init];
        unrecognizedSelectorSolveObject.isOpenCallStack = YES;
    });
    return unrecognizedSelectorSolveObject;
}

+ (BOOL) resolveInstanceMethod:(SEL)selector {
    
    //向类中动态的添加方法，第三个参数为函数指针，指向待添加的方法。最后一个参数表示待添加方法的“类型编码”
    class_addMethod([self class], selector,(IMP)autoAddMethod,"v@:@");
    return YES;
}

- (void)openCallStack:(BOOL)isOpen {
    self.isOpenCallStack = isOpen;
}

+ (NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSDate *datenow = [NSDate date];
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    return currentTimeString;
    
}

id autoAddMethod(id self, SEL _cmd) {
//    NSLog(@"%@ __ %@ ",self,NSStringFromSelector(_cmd));
//    //可以在此加入日志信息，栈信息的获取等，方便后面分析和改进原来的代码。
    
#ifdef DEBUG
    NSString *message = [NSString stringWithFormat:@"unrecognized selector: %@",NSStringFromSelector(_cmd)];
    
    if ([[YDUnrecognizedSelectorSolveObject sharedInstance] isOpenCallStack]) {
        NSString *callStackMessage = [YDCallStack YDCallStackWithType:YDCallStackTypeCurrent];
        NSDictionary *messageInfo = @{
            @"selector_mesaage":message,
            @"call_stack_message":callStackMessage
        };
        
        NSLog(@"AvoidCrashInfo: ========== %@", messageInfo);
        YDAvoidCrashModel *model = [[YDAvoidCrashModel alloc] init];
        model.errorInfoDic = [NSString stringWithFormat:@"%@", messageInfo];
        model.crashTime = [YDUnrecognizedSelectorSolveObject getCurrentTimes];
        [[YDAvoidDB shareInstance] insertWithCrashModel:model];
    }else {
        NSLog(@"crash_sel: %@",message);
    }
    
#endif
    
    return nil;
}

@end
