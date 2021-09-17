//
//  YDAvoidDB.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "YDAvoidCrashModel.h"

#define PATH_OF_APP_HOME    NSHomeDirectory()
#define PATH_OF_TEMP        NSTemporaryDirectory()
#define PATH_OF_DOCUMENT    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]


@interface YDAvoidDB : NSObject

+ (YDAvoidDB *)shareInstance;
- (void)insertWithCrashModel:(YDAvoidCrashModel *)model; //插入Crash
- (NSArray *)selectAllCrashModel; //读取所有Crash信息
- (void)clearAllDB;
@end


