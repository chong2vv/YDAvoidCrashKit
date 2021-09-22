//
//  YDCallStackModel.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YDCallStackModel : NSObject
@property (nonatomic, copy) NSString *stackStr;       //完整堆栈信息
@property (nonatomic) BOOL isStuck;                   //是否被卡住
@property (nonatomic, assign) NSTimeInterval dateString;   //可展示信息
@end

NS_ASSUME_NONNULL_END
