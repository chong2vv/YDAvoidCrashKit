//
//  YDMmapLogSwizzeling.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import "YDMmapLogSwizzeling.h"
#import "YDMmapLogService.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define YD_ORIGIN_FORWARD_SEL     NSSelectorFromString(@"forwardInvocation:")
#define YD_NEW_FORWARD_SEL        NSSelectorFromString([YDHOOK_PREFIXNAME stringByAppendingString:@"forwardInvocation:"])

#define YD_ORIGIN_SIGNATURE_SEL   NSSelectorFromString(@"methodSignatureForSelector:")
#define YD_NEW_SIGNATURE_SEL      NSSelectorFromString([YDHOOK_PREFIXNAME stringByAppendingString:@"methodSignatureForSelector:"])

#define YD_ORIGIN_INITIALIZE_SEL   NSSelectorFromString(@"initialize")
#define YD_NEW_INITIALIZE_SEL      NSSelectorFromString([YDHOOK_PREFIXNAME stringByAppendingString:@"initialize"])

// 获取本地类名与类名前缀的白名单
static NSSet * _yd_static_class_white_list ()
{
    static NSSet *cwl = nil;
    static dispatch_once_t cwlToken;
    dispatch_once(&cwlToken, ^{
        cwl = _yd_class_white_list();
    });
    
    return cwl;
}

// 获取本地类名与类名前缀的黑名单
static NSSet * _yd_static_class_black_list (bool pre)
{
    static NSSet *cblp = nil;
    static dispatch_once_t cblpToken;
    dispatch_once(&cblpToken, ^{
        cblp = _yd_class_black_list_pre();
    });
    
    static NSSet *cbl = nil;
    static dispatch_once_t cblToken;
    dispatch_once(&cblToken, ^{
        cbl = _yd_class_black_list();
    });
    
    if (pre) return cblp;
    return cbl;
}

// 获取本地方法名与方法名前缀的黑名单
static NSDictionary * _yd_static_method_black_list (bool pre)
{
    static NSDictionary *mblp = nil;
    static dispatch_once_t mblpToken;
    dispatch_once(&mblpToken, ^{
        mblp = _yd_method_black_list_pre();
    });
    
    static NSDictionary *mbl = nil;
    static dispatch_once_t mblToken;
    dispatch_once(&mblToken, ^{
        mbl = _yd_method_black_list();
    });
    
    if (pre) return mblp;
    return mbl;
}


#pragma mark - C Business Funcion

// 是否可以hook该类，只hook白名单中出现的类
static bool _yd_logger_can_hook (Class cls)
{
    NSString *clsName = NSStringFromClass(cls);
    
    // 先判断动态黑名单，再判断静态黑名单
    for (NSString *name in _yd_dynamic_cbl_pre) {
        if ([clsName hasPrefix:name]) return false;
    }
    for (NSString *name in _yd_dynamic_cbl) {
        if ([clsName isEqualToString:name]) return false;
    }
    for (NSString *name in _yd_static_class_black_list(true)) {
        if ([clsName hasPrefix:name]) return false;
    }
    for (NSString *name in _yd_static_class_black_list(false)) {
        if ([clsName isEqualToString:name]) return false;
    }
    
    // 若不在黑名单之中，再判断白名单
    for (NSString *name in _yd_dynamic_cwl) {
        if ([clsName hasPrefix:name]) return true;
    }
    for (NSString *name in _yd_static_class_white_list()) {
        if ([clsName hasPrefix:name]) return true;
    }
    
    return false;
}

// C函数重载
// 是否可以hook此类的该方法，其中属性的setter/getter方法不hook
__attribute__((overloadable))
static bool _yd_logger_can_hook (Class cls, Method mth, objc_property_t *proList, unsigned proCnt)
{
    NSString *selName = NSStringFromSelector(method_getName(mth));
    
    // 不hook属性的setter/getter方法
    bool hook = true;
    for (unsigned i = 0; i < proCnt; ++i) {
        @autoreleasepool {
            objc_property_t property = proList[i];
            const char *proName = property_getName(property);
            NSString *getPro = [NSString stringWithUTF8String:proName];
            NSString *setPro = [@"set" stringByAppendingFormat:@"%@:", [getPro stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[getPro substringToIndex:1] capitalizedString]]];
            if ([selName isEqualToString:getPro] || [selName isEqualToString:setPro]) {
                hook = false;
                break;
            }
        }
    }
    
    if (!hook) return false;
    
    // 先判断是否在动态黑名单中
    NSArray *bmList = _yd_dynamic_mbl[selName];
    if (bmList) {
        if (bmList.count == 0) return false;
        NSString *clsName = NSStringFromClass(cls);
        for (NSString *name in bmList) {
            if ([clsName isEqualToString:name]) return false;
        }
    }
    
    // 先静态方法名黑名单
    bmList = _yd_static_method_black_list(false)[selName];
    if (bmList) {
        if (bmList.count == 0) return false;
        NSString *clsName = NSStringFromClass(cls);
        for (NSString *name in bmList) {
            if ([clsName isEqualToString:name]) return false;
        }
    }
    
    // 再静态方法名前缀的黑名单
    for (NSString *pre in _yd_static_method_black_list(true).allKeys) {
        if ([selName hasPrefix:pre]) {
            bmList = _yd_static_method_black_list(true)[pre];
            if (bmList) {
                if (bmList.count == 0) return false;
                NSString *clsName = NSStringFromClass(cls);
                for (NSString *name in bmList) {
                    if ([clsName isEqualToString:name]) return false;
                }
            }
        }
    }
    
    // 若黑名单中没有，则可以hook此方法
    return true;
}


#pragma mark - C Core Function

/**
 IMP指针函数的声明
 由于ARM_64架构下，abi的不同，导致不定参数的函数指针的调用会崩溃，所以需要在IMP指针调用时指定其类型
 */
typedef NSMethodSignature *(*_yd_method_sigature_IMP)(id, SEL, SEL);
typedef void (*_yd_forward_invocation_IMP)(id, SEL, NSInvocation *);
typedef void (*_yd_initialize_IMP)(Class, SEL);

/**
 外部调用
 由于同时hook了子类和父类的方法，导致super调用的方法通过_objc_msgForward流程后，得到的target和selector都是相同的，所以实质上调用了同一个方法，造成了循环调用，会引发线程栈溢出的崩溃bug
 因此super方法调用需要单独的方法调用来模拟objc_msgSendSuper

 @param target 方法的接受者
 @param cmd 调用的方法
 @param args 参数数组
 @return 方法的返回值
 */
id _yd_logger_super_function (id target, SEL cmd, NSArray *args)
{
    SEL supSel = NSSelectorFromString([@"YDSUPER_" stringByAppendingString:NSStringFromSelector(cmd)]);
    Class supCls = [target class];
    BOOL isClass = object_isClass(target);
    Method supMth = nil;
    NSMethodSignature *sig = nil;
    
    // 先从当前类中寻找super的方法实现（实例方法/类方法）
    if (isClass)
        supMth = class_getClassMethod(supCls, supSel);
    else
        supMth = class_getInstanceMethod(supCls, supSel);
    
    // 若该类保存了super的方法实现，使用ObjCType创建NSMethodSignature是为了保证返回值的TypeEncoding的正确性
    if (supMth) {
        sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(supMth)];
    }
    // 循环传递给super直到找到该方法的实现或不在有super为止
    else {
        supCls = [target superclass];
        do {
            if (isClass)
                supMth = class_getClassMethod(supCls, cmd);
            else
                supMth = class_getInstanceMethod(supCls, cmd);
            
            supCls = [supCls superclass];
        } while (supCls && !supMth);
        
        // 找到了super的实现，动态创建方法，将super的方法实现保存到该类中
        if (supMth) {
            IMP supIMP = method_getImplementation(supMth);
            class_addMethod(object_getClass(target), supSel, supIMP, method_getTypeEncoding(supMth));
            sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(supMth)];
        }
        // 若没有找到，则按照苹果的逻辑传递给_objc_msgForward
        else {
            sig = [target methodSignatureForSelector:cmd];
        }
    }
    
    // 通过invocation调用方法
    NSInvocation *invo = [NSInvocation invocationWithMethodSignature:sig];
    [invo setTarget:target];
    [invo setSelector:supSel];
    
    if (args) {
        for (unsigned i = 0; i < args.count; ++i) {
            id arg = args[i];
            [invo setArgument:&arg atIndex:i+2];
        }
    }
    
    [invo invoke];
    
    // 获取返回值
    void *ret = NULL;
    if (sig.methodReturnLength)
        [invo getReturnValue:&ret];
    
    return (__bridge id)(ret);
}

/**
 methodSignatureForSelector:方法的替换方法
 若有类实现了methodSignatureForSelector:则会用此方法替换掉，否则会造成循环调用

 @param target 方法的接收者
 @param cmd 方法名
 @param aSel 触发转发流程的方法
 @return NSMethodSignature方法签名
 */
static NSMethodSignature * _yd_logger_method_signature (id target, SEL cmd, SEL aSel)
{
    // 由于将类中的方法都hook到转发流程中，所以当实现了methodSignatureForSelector:后，所有被hook的方法都会走到该方法中
    // 先判断是否是因为未找到方法而触发的转发流程，所以先在该类中查找aSel方法的实现
    SEL newSel = NSSelectorFromString([YDHOOK_PREFIXNAME stringByAppendingString:NSStringFromSelector(aSel)]);
    Method newMth = nil;
    if (object_isClass(target))
        newMth = class_getClassMethod([target class], newSel);
    else
        newMth = class_getInstanceMethod([target class], newSel);

    // 未找到方法实现，表示应该走真正的转发流程，所以调用原methodSignatureForSelector:方法实现
    // 直接调用IMP函数指针，实现方法的调用，是因为class_getMethodImplementation会递归向super类查找IMP
    if (!newMth) {
        _yd_method_sigature_IMP oriSigIMP = (_yd_method_sigature_IMP)class_getMethodImplementation([target class], YD_NEW_SIGNATURE_SEL);

        [[YDMmapLogService shared] logMsgForward:target cmd:aSel forwardCmd:YD_ORIGIN_SIGNATURE_SEL];

        return (*oriSigIMP)(target, cmd, aSel);
    }

    // 找到了aSel方法实现，则说明是hook造成的转发流程，所以返回方法签名，使之走到forwardInvocation:方法中
    Method oldMth = class_getInstanceMethod([target class], aSel);
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(oldMth)];
    return sig;
}

/**
 forwardInvocation:方法的替换方法
 被hook的方法调用都会走到此方法中，在此方法中添加日志埋点，实现全埋点
 由于方法的参数不定，所以为了解决获得任意方法的参数问题，采用了forwardInvocation:可以获取到方法的完整的invocation
 还可以采用汇编语言来实现，就不需要走转发流程来获取不定参数
 还可以用va_list来获取，但是arm_64架构由于abi不同的原因造成不定参数获取不一定是正确的

 @param target 方法接收者
 @param sel 方法名
 @param invocation 被转发的方法的完整invocation
 */
static void _yd_logger_forward_invocation (id target, SEL sel, NSInvocation *invocation)
{
    SEL oldSel = [invocation selector];
    SEL newSel = NSSelectorFromString([YDHOOK_PREFIXNAME stringByAppendingString:NSStringFromSelector(oldSel)]);
    Method newMth = nil;
    Method oldMth = nil;
    
    // 获取被转发的方法实现，可能是直接调用了YDHOOK_PREFIXNAME为前缀的方法，例如，super的调用
    // 所以要获取invocation中方法的实现和添加了前缀的方法实现
    // 查找方法实现不用查找IMP的方式是因为IMP的查找会向super类递归查找，而Method只会在本类中查找
    if (object_isClass(target)) {
        newMth = class_getClassMethod([target class], newSel);
        oldMth = class_getClassMethod([target class], oldSel);
    }
    else {
        newMth = class_getInstanceMethod([target class], newSel);
        oldMth = class_getInstanceMethod([target class], oldSel);
    }

    // 先原方法的调用
    if (newMth) {
        [invocation setSelector:newSel];

        [[YDMmapLogService shared] logObject:target cmd:oldSel];

        [invocation invoke];
    }
    // 再直接调用带前缀的方法
    else if (oldMth) {
        [[YDMmapLogService shared] logObject:target cmd:oldSel];
        
        [invocation invoke];
    }
    // 如果没找到方法实现，走转发流程的forwardInvocation:
    else {
        // 类中自己实现的forwardInvocation:方法，并且会递归向super类继续查找
        if (class_getInstanceMethod([target class], YD_NEW_FORWARD_SEL)) {
            _yd_forward_invocation_IMP oriFwdIMP = (_yd_forward_invocation_IMP)class_getMethodImplementation([target class], YD_NEW_FORWARD_SEL);

            [[YDMmapLogService shared] logMsgForward:target cmd:oldSel forwardCmd:YD_ORIGIN_FORWARD_SEL];

            (*oriFwdIMP)(target, sel, invocation);
        }
        // 类中没有实现forwardInvocation:方法，则通过NSObject的forwardInvocation:方法结束转发流程
        else {
            _yd_forward_invocation_IMP objcFwdIMP = (_yd_forward_invocation_IMP)class_getMethodImplementation(NSClassFromString(@"NSObject"), YD_ORIGIN_FORWARD_SEL);

            [[YDMmapLogService shared] logMsgForward:target cmd:oldSel forwardCmd:YD_NEW_FORWARD_SEL];

            (*objcFwdIMP)(target, sel, invocation);
        }
    }
}

/**
 hook类中的所有方法

 @param targetCls 被hook的类
 @param proList 类的属性列表
 @param proCnt 类的属性的个数
 */
static void _yd_logger_inject_class (Class targetCls, objc_property_t *proList, unsigned proCnt)
{
    unsigned mthCnt = 0;
    Method *mthList = class_copyMethodList(targetCls, &mthCnt);
    Method oldSigMth = nil;
    Method oldFwdMth = nil;
    
    // 查找类中是否实现了转发流程中的方法
    for (unsigned i = 0; i < mthCnt; ++i) {
        @autoreleasepool {
            Method oldMth = mthList[i];
            SEL oldSel = method_getName(oldMth);
            if (oldSel == YD_ORIGIN_FORWARD_SEL) {
                oldFwdMth = oldMth;
                if (oldSigMth) break;
                else continue;
            }
            if (oldSel == YD_ORIGIN_SIGNATURE_SEL) {
                oldSigMth = oldMth;
                if (oldFwdMth) break;
                else continue;
            }
        }
    }
    
    // 如果实现了methodSignatureForSelector:方法，则替换
    if (oldSigMth) {
        if (!class_addMethod(targetCls, YD_NEW_SIGNATURE_SEL, (IMP)_yd_logger_method_signature, "@@::")) {
            free(mthList);
            return;
        }
    }
    
    // 如果实现了forwardInvocation:方法，则替换
    if (oldFwdMth) {
        if (!class_addMethod(targetCls, YD_NEW_FORWARD_SEL, (IMP)_yd_logger_forward_invocation, "v@:@")) {
            free(mthList);
            return;
        }
    }
    // 没有实现，则添加
    else {
        if (!class_addMethod(targetCls, YD_ORIGIN_FORWARD_SEL, (IMP)_yd_logger_forward_invocation, "v@:@")) {
            free(mthList);
            return;
        }
    }
    
    
    Method *newmthList = class_copyMethodList(targetCls, &mthCnt);
    Method newFwdMth = nil;
    Method newSigMth = nil;
    
    // 类中方法黑名单之外的都需要hook
    for (unsigned i = 0; i < mthCnt; ++i) {
        @autoreleasepool {
            Method oldMth = newmthList[i];
            if (!_yd_logger_can_hook(targetCls, oldMth, proList, proCnt)) continue;
            SEL oldSel = method_getName(oldMth);
            
            if (oldSel == YD_NEW_SIGNATURE_SEL) {
                newSigMth = oldMth;
                continue;
            }
            if (oldSel == YD_NEW_FORWARD_SEL) {
                newFwdMth = oldMth;
                continue;
            }

            IMP oldImp = method_getImplementation(oldMth);
            const char *oldType = method_getTypeEncoding(oldMth);

            NSString *newCmd = [YDHOOK_PREFIXNAME stringByAppendingString:NSStringFromSelector(oldSel)];
            SEL newSel = NSSelectorFromString(newCmd);
            
            // 动态创建一个新方法来保存原方法的实现，且将原方法的IMP指针替换成_objc_msgForward，使之调用走转发流程
            if (class_addMethod(targetCls, newSel, oldImp, oldType))
                class_replaceMethod(targetCls, oldSel, _objc_msgForward, oldType);
        }
    }
    
    // 待类中方法hook成功后，再交换转发流程中的方法
    if (oldSigMth && newSigMth)
        method_exchangeImplementations(oldSigMth, newSigMth);
    
    if (oldFwdMth && newFwdMth)
        method_exchangeImplementations(oldFwdMth, newFwdMth);
    
    free(mthList);
    free(newmthList);
}

/**
 initialize方法的替换方法，通过替换initialize把hook类方法的时间延后到类的第一次使用的时候

 @param target 被替换的类
 @param sel 方法名
 */
static void _yd_logger_initialize (Class target, SEL sel)
{
    Method oldInitMth = class_getClassMethod(target, YD_NEW_INITIALIZE_SEL);
    
    // 先调用原initialize方法，通过IMP函数指针可以找到super的initialize
    if (oldInitMth) {
        _yd_initialize_IMP initIMP = (_yd_initialize_IMP)method_getImplementation(oldInitMth);
        
        (*initIMP)(target, sel);
    }
    
    Class aclass = NSClassFromString([NSString stringWithUTF8String:object_getClassName(target)]);
    unsigned proCnt = 0;
    objc_property_t *proList = class_copyPropertyList(aclass, &proCnt);
    
    // hook类中的实例方法以及类方法，类方法存在meta class中，通过object_getClass获取类对象的meta class
    _yd_logger_inject_class(aclass, proList, proCnt);
    _yd_logger_inject_class(object_getClass(target), proList, proCnt);
    
    free(proList);
}

/**
 hook该类的initialize方法

 @param cls 被hook的类
 */
static void _yd_logger_inject_initialize (Class cls)
{
    unsigned mthCnt = 0;
    Method *mthList = class_copyMethodList(cls, &mthCnt);
    Method oldInitMth = nil;
    
    // 先判断该类是否被hook过
    // 由于从objc_copyClassList中获取到的类，有重复的现象，所以通过添加特殊的方法作为是否hook过的标志
    SEL hasHook = NSSelectorFromString(@"YD_HASHOOK");
    bool needHook = true;
    
    // 一次遍历，既找出是否实现了initialize方法，又找出是否hook的标志方法
    for (unsigned i = 0; i < mthCnt; ++i) {
        @autoreleasepool {
            Method oldMth = mthList[i];
            SEL oldSel = method_getName(oldMth);
            if (oldSel == hasHook) {
                needHook = false;
                break;
            }
            if (oldSel == YD_ORIGIN_INITIALIZE_SEL) {
                oldInitMth = oldMth;
            }
        }
    }
    
    // 未被hook的类，通过添加特殊方法，标记为已hook
    if (needHook) {
        if (!class_addMethod(cls, hasHook, (IMP)_objc_msgForward, "v@:")) {
            free(mthList);
            return;
        }
    }
    else {
        free(mthList);
        return;
    }
    
    // initialize方法的替换
    if (oldInitMth) {
        if (class_addMethod(cls, YD_NEW_INITIALIZE_SEL, (IMP)_yd_logger_initialize, "v@:")) {
            Method newInitMth = class_getClassMethod(cls, YD_NEW_INITIALIZE_SEL);
            method_exchangeImplementations(oldInitMth, newInitMth);
        }
    }
    // 添加initialize方法，来hook类中的方法
    else {
        class_addMethod(cls, YD_ORIGIN_INITIALIZE_SEL, (IMP)_yd_logger_initialize, "v@:");
    }
    
    free(mthList);
}

/**
 开启hook模式的方法
 通过constructor标记，可以在main函数方法执行前，+load方法执行后，执行此方法
 通过YDHOOK_AUTO_SWIZZLE宏控制是否允许动态下发配置，以及hook initialize的时机
 */
#if YDHOOK_AUTO_SWIZZLE
__attribute__((constructor))
#endif
void _yd_logger_inject_entry_nolock (void)
{
    unsigned classCount = 0;
    Class *allClasses = objc_copyClassList(&classCount);
    
    for (unsigned classIndex = 0; classIndex < classCount; ++classIndex) {
        @autoreleasepool {
            Class aclass = allClasses[classIndex];
            if (!_yd_logger_can_hook(aclass)) continue;
            
            _yd_logger_inject_initialize(object_getClass(aclass));
        }
    }
    
    free(allClasses);
}
