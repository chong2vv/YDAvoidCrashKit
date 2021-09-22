//
//  YDMmapLogSwizzeling.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import <Foundation/Foundation.h>

// 添加的hook方法名的前缀
#define YDHOOK_PREFIXNAME   @"YD_"

// 是否开启自动hook模式，只根据本地黑白名单hook
#define YDHOOK_AUTO_SWIZZLE 0

/**
 动态黑白名单声明
 */
static NSSet * _yd_dynamic_cwl;
static NSSet * _yd_dynamic_cbl_pre;
static NSSet * _yd_dynamic_cbl;
static NSDictionary * _yd_dynamic_mbl;

// 本地类名与类名前缀的白名单
static NSMutableSet * _yd_class_white_list ()
{
    return [NSMutableSet setWithArray:@[
                                        @"Art",
                                        ]];
}

// 本地类名前缀的黑名单
static NSMutableSet * _yd_class_black_list_pre ()
{
    return [NSMutableSet setWithArray:@[
                                        @"YDMmap",
                                        @"ArtThreadSafe",
                                        ]];
}

// 本地类名的黑名单
static NSMutableSet * _yd_class_black_list ()
{
    return [NSMutableSet setWithArray:@[
                                        @"ArtLoggerService",
                                        @"ArtCommand",
                                        ]];
}

// 本地方法名前缀的黑名单，方法名的前缀作为key，对应的类的数组为value；若为空数组，则表示所有类
static NSDictionary * _yd_method_black_list_pre ()
{
    return @{
             @".":@[],
             YDHOOK_PREFIXNAME:@[],
             @"scrollView":@[],
             @"init":@[],
             };
}

// 本地方法名的黑名单，方法名的前缀作为key，对应的类的数组为value；若为空数组，则表示所有类
static NSDictionary * _yd_method_black_list ()
{
    return @{
             @"dealloc":@[],
             @"forwardInvocation:":@[],
             @"methodSignatureForSelector:":@[],
             @"descriptionWithLocale:":@[],
             };
}

// 动态设置类名前缀和类名的白名单
void _yd_set_dynamic_cwl (NSSet *list)
{
    _yd_dynamic_cwl = list;
}

// 动态设置类名前缀和类名的黑名单
void _yd_set_dynamic_cbl (NSSet *list, NSSet *preList)
{
    _yd_dynamic_cbl_pre = preList;
    _yd_dynamic_cbl = list;
}

// 动态设置方法名的黑名单
void _yd_set_dynamic_mbl (NSDictionary *list)
{
    _yd_dynamic_mbl = list;
}
