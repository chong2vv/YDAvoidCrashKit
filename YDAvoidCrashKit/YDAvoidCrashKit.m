//
//  YDKit.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "YDAvoidCrashKit.h"

@implementation YDAvoidCrashKit

+ (NSBundle *)bundle {
    static NSBundle* bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSBundle.mainBundle pathForResource:@"YDKit" ofType:@"bundle"];
        if (path) {
            bundle = [NSBundle bundleWithPath:path];
        }
        if (bundle == nil) {
            bundle = NSBundle.mainBundle;
        }
    });
    return bundle;
}

@end
