//
//  NSString+YDAvoidCrash.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/15.
//

#import "NSString+YDAvoidCrash.h"
#import "YDAvoidCrash.h"
#import "NSObject+YDAvoidCrashRunTime.h"

@implementation NSString (YDAvoidCrash)

+ (void)avoidCrashExchangeMethod {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class stringClass = NSClassFromString(@"__NSCFConstantString");
        
        //characterAtIndex
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(characterAtIndex:) method2Sel:@selector(avoidCrashCharacterAtIndex:)];
        
        //substringFromIndex
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(substringFromIndex:) method2Sel:@selector(avoidCrashSubstringFromIndex:)];
        
        //substringToIndex
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(substringToIndex:) method2Sel:@selector(avoidCrashSubstringToIndex:)];
        
        //substringWithRange:
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(substringWithRange:) method2Sel:@selector(avoidCrashSubstringWithRange:)];
        
        //stringByReplacingOccurrencesOfString:
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingOccurrencesOfString:withString:) method2Sel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:)];
        
        //stringByReplacingOccurrencesOfString:withString:options:range:
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingOccurrencesOfString:withString:options:range:) method2Sel:@selector(avoidCrashStringByReplacingOccurrencesOfString:withString:options:range:)];
        
        //stringByReplacingCharactersInRange:withString:
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(stringByReplacingCharactersInRange:withString:) method2Sel:@selector(avoidCrashStringByReplacingCharactersInRange:withString:)];
        
        //=================================================================
        //                  来自 https://github.com/jasenhuang/NSObjectSafe
        //=================================================================
        //=================
        //   class method
        //=================
        
        //instance array method exchange
        [NSObject exchangeClassMethod:[self class] method1Sel:@selector(stringWithUTF8String:) method2Sel:@selector(hookStringWithUTF8String:)];
        
        [NSObject exchangeClassMethod:[self class] method1Sel:@selector(stringWithCString:encoding:) method2Sel:@selector(hookStringWithCString:encoding:)];
        
        
        //====================
        //   instance method
        //====================
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(stringByAppendingString:) method2Sel:@selector(hookStringByAppendingString:)];
        
        [NSObject exchangeInstanceMethod:stringClass method1Sel:@selector(rangeOfString:options:range:locale:) method2Sel:@selector(hookRangeOfString:options:range:locale:)];
    });
    
}


//=================================================================
//                           characterAtIndex:
//=================================================================
#pragma mark - characterAtIndex:

- (unichar)avoidCrashCharacterAtIndex:(NSUInteger)index {
    
    unichar characteristic;
    @try {
        characteristic = [self avoidCrashCharacterAtIndex:index];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = @"This framework default is to return a without assign unichar.";
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
    }
    @finally {
        return characteristic;
    }
}

//=================================================================
//                           substringFromIndex:
//=================================================================
#pragma mark - substringFromIndex:

- (NSString *)avoidCrashSubstringFromIndex:(NSUInteger)from {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringFromIndex:from];
    }
    @catch (NSException *exception) {
        
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

//=================================================================
//                           substringToIndex
//=================================================================
#pragma mark - substringToIndex

- (NSString *)avoidCrashSubstringToIndex:(NSUInteger)to {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringToIndex:to];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}


//=================================================================
//                           substringWithRange:
//=================================================================
#pragma mark - substringWithRange:

- (NSString *)avoidCrashSubstringWithRange:(NSRange)range {
    
    NSString *subString = nil;
    
    @try {
        subString = [self avoidCrashSubstringWithRange:range];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        subString = nil;
    }
    @finally {
        return subString;
    }
}

//=================================================================
//                stringByReplacingOccurrencesOfString:
//=================================================================
#pragma mark - stringByReplacingOccurrencesOfString:

- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

//=================================================================
//  stringByReplacingOccurrencesOfString:withString:options:range:
//=================================================================
#pragma mark - stringByReplacingOccurrencesOfString:withString:options:range:

- (NSString *)avoidCrashStringByReplacingOccurrencesOfString:(NSString *)target withString:(NSString *)replacement options:(NSStringCompareOptions)options range:(NSRange)searchRange {
    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingOccurrencesOfString:target withString:replacement options:options range:searchRange];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}


//=================================================================
//       stringByReplacingCharactersInRange:withString:
//=================================================================
#pragma mark - stringByReplacingCharactersInRange:withString:

- (NSString *)avoidCrashStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)replacement {

    
    NSString *newStr = nil;
    
    @try {
        newStr = [self avoidCrashStringByReplacingCharactersInRange:range withString:replacement];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

//=================================================================
//                  来自 https://github.com/jasenhuang/NSObjectSafe
//=================================================================

+ (NSString*) hookStringWithUTF8String:(const char *)nullTerminatedCString
{
    NSString *newStr = nil;
    
    @try {
        newStr = [self hookStringWithUTF8String:nullTerminatedCString];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

+ (nullable instancetype) hookStringWithCString:(const char *)cString encoding:(NSStringEncoding)enc
{
    NSString *newStr = nil;
    
    @try {
        newStr = [self hookStringWithCString:cString encoding:enc];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultReturnNil;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = nil;
    }
    @finally {
        return newStr;
    }
}

- (NSString *)hookStringByAppendingString:(NSString *)aString
{
    NSString *newStr = nil;
    
    @try {
        newStr = [self hookStringByAppendingString:aString];
    }
    @catch (NSException *exception) {
        NSString *defaultToDo = AvoidCrashDefaultIgnore;
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:defaultToDo];
        newStr = self;
    }
    @finally {
        return newStr;
    }
}

- (NSRange)hookRangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(nullable NSLocale *)locale {
    NSRange range = NSMakeRange(0, 0);
    @try {
        range = [self hookRangeOfString:searchString options:mask range:rangeOfReceiverToSearch locale:locale];
    } @catch (NSException *exception) {
        [YDAvoidCrash noteErrorWithException:exception defaultToDo:AvoidCrashDefaultReturnNil];
        range = NSMakeRange(0, 0);
    } @finally {
        return range;
    }
}

@end
