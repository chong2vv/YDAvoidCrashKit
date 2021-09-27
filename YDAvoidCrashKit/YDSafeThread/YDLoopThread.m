//
//  YDLoopThread.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/27.
//


#import "YDLoopThread.h"

@interface YDThread : NSThread

@end

@implementation YDThread


@end

@interface YDLoopThread ()

@property (strong, nonatomic) YDThread *innerThread;

@end

@implementation YDLoopThread

- (instancetype)initWithName:(NSString *)name
{
    if (self = [super init]) {
        self.innerThread = [[YDThread alloc] initWithTarget:self selector:@selector(__addThreadRunloop) object:nil];
        self.innerThread.name = name;
        [self.innerThread start];
    }
    return self;
}

- (void)executeTask:(YDLoopTask)task  complete:(nullable YDCompleteTask)complete
{
    if (!self.innerThread || !task) return;
    
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:task waitUntilDone:NO];

    if (!complete) return;
    
    [self performSelector:@selector(__executeTask:) onThread:self.innerThread withObject:complete waitUntilDone:NO];
}


- (void)executeTask:(YDLoopTask)task
{
    [self executeTask:task complete:nil];
}

- (void)stop
{
    if (!self.innerThread) return;
    
    [self performSelector:@selector(__stop) onThread:self.innerThread withObject:nil waitUntilDone:YES];
}

- (void)dealloc
{
    NSLog(@"%s", __func__);
    
    [self stop];
}

#pragma mark - private methods
- (void)__stop
{
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.innerThread = nil;
}

- (void)__executeTask:(YDLoopTask)task
{
    task();
    NSLog(@"线程 %@执行了任务",[NSThread currentThread]);
}

- (void)__addThreadRunloop {
        NSLog(@"begin----");
        
        // 创建上下文（要初始化一下结构体）
        CFRunLoopSourceContext context = {0};
        
        // 创建source
        CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        
        // 往Runloop中添加source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, kCFRunLoopDefaultMode);
        
        // 销毁source
        CFRelease(source);
        
        // 启动
        CFRunLoopRunInMode(kCFRunLoopDefaultMode, 1.0e10, false);
        
        NSLog(@"end----");
}


- (BOOL)isExecuting {
    return self.innerThread.isExecuting;
}

@end
