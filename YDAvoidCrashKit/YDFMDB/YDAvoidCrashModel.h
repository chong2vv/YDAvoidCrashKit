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
@property (nonatomic, copy) NSString *errorInfoDic; //错误日志信息
@property (nonatomic, copy) NSString *crashTime;//crash时间

@end

NS_ASSUME_NONNULL_END
