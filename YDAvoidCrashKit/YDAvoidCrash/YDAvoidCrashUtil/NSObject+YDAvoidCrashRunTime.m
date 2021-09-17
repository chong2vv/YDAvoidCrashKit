//
//  NSObject+YDExchangeMethod.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "NSObject+YDAvoidCrashRunTime.h"
#import <objc/runtime.h>

@implementation NSObject (YDAvoidCrashRunTime)


+ (void)exchangeClassMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    Method method1 = class_getClassMethod(anClass, method1Sel);
    Method method2 = class_getClassMethod(anClass, method2Sel);
    method_exchangeImplementations(method1, method2);
}

+ (void)exchangeInstanceMethod:(Class)anClass method1Sel:(SEL)method1Sel method2Sel:(SEL)method2Sel {
    
    
    Method originalMethod = class_getInstanceMethod(anClass, method1Sel);
    Method swizzledMethod = class_getInstanceMethod(anClass, method2Sel);
    
    BOOL didAddMethod =
    class_addMethod(anClass,
                    method1Sel,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(anClass,
                            method2Sel,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    }
    
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
}

- (NSArray <NSString *> *)getAvoidCrashMethodByListPrefix:(NSString *)prefix {
    return [[self class] getAvoidCrashMethodByListPrefix:prefix];
}

+ (NSArray <NSString *> *)getAvoidCrashMethodByListPrefix:(NSString *)prefix {
    
    Class currentClass = [self class];
    NSMutableArray <NSString *> *selArrayM = [[NSMutableArray alloc] init];
    while (currentClass) {
        unsigned int methodCount;
        Method *methodList = class_copyMethodList(currentClass, &methodCount);
        unsigned int i = 0;
        for (; i < methodCount; i++) {
            
            SEL sel = method_getName(methodList[i]);
            NSString *methodString = [NSString stringWithCString:sel_getName(sel) encoding:NSUTF8StringEncoding];
            if ([methodString hasPrefix:prefix]) {
                [selArrayM addObject:methodString];
            }
        }
        
        free(methodList);
        currentClass = class_getSuperclass(currentClass);
    }
    
    if (selArrayM.count <= 0) {
        return nil;
    }
    
#if DEBUG
    for (int i = 0; i < selArrayM.count; i ++) {
        for (int j = i + 1; j < selArrayM.count; j ++) {
            NSString *stri = selArrayM[i];
            NSString *strj = selArrayM[j];
            if ([stri isEqualToString:strj]) {
                NSAssert(NO, @"请检查有同名分类名注意修改-- %@",stri);
            }
        }
    }
#endif
    return [selArrayM copy];
}

@end
