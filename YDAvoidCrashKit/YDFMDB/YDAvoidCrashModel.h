//
//  YDAvoidCrashModel.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDAvoidCrashModel : NSObject

@property (nonatomic) NSUInteger crashId;
@property (nonatomic, copy) NSString *errorInfoDic;
@property (nonatomic, copy) NSString *crashTime;

@end

NS_ASSUME_NONNULL_END
