//
//  YDKit.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import <Foundation/Foundation.h>
#import "YDAvoidCrash.h"
#import "YDLogService.h"
#import "YDAvoidDB.h"

//YDLog UI
#import "YDLogListViewController.h"

//! Project version number for YDKit.
FOUNDATION_EXPORT double YDKitVersionNumber;

//! Project version string for YDKit.

FOUNDATION_EXPORT const unsigned char YDKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <YDKit/YDKit.h>

@interface YDAvoidCrashKit : NSObject

@property (nonatomic, class, readonly) NSBundle *bundle;

@end

