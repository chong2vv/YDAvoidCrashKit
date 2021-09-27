//
//  YDCPUInfo.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#import "YDCPUInfo.h"
#import "YDCallStack.h"
#import "YDLogService.h"

#define key_stackStr    @"stackStr" //完整堆栈信息
#define key_isStuck     @"isStuck" //是否被卡住
#define key_monitor_info  @"monitor_info" //可展示信息

@interface YDCPUInfo ()

@property (class, nonatomic, assign) NSInteger cpuRate;

@end

@implementation YDCPUInfo
static NSInteger _cpuRate = 80;

+ (void)setCPUMonitorRate:(NSInteger)rate {
    YDCPUInfo.cpuRate = rate;
}

+ (void)setCpuRate:(NSInteger)cpuRate{
    if (cpuRate != _cpuRate) {
        _cpuRate = cpuRate;
    }
}

+ (NSInteger)cpuRate {
    if (_cpuRate == 0) {
        _cpuRate = 80;
    }
    return _cpuRate;
}

+ (void)updateCPU {
    thread_act_array_t threads;
    mach_msg_type_number_t threadCount = 0;
    const task_t thisTask = mach_task_self();
    kern_return_t kr = task_threads(thisTask, &threads, &threadCount);
    if (kr != KERN_SUCCESS) {
        return;
    }
    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t threadInfo;
        thread_basic_info_t threadBaseInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        if (thread_info((thread_act_t)threads[i], THREAD_BASIC_INFO, (thread_info_t)threadInfo, &threadInfoCount) == KERN_SUCCESS) {
            threadBaseInfo = (thread_basic_info_t)threadInfo;
            if (!(threadBaseInfo->flags & TH_FLAGS_IDLE)) {
                integer_t cpuUsage = threadBaseInfo->cpu_usage / 10;
                if (cpuUsage > YDCPUInfo.cpuRate) {
                    //cup 消耗大于设置值时打印和记录堆栈
                    NSString *reStr = YDStackOfThread(threads[i]);
                    BOOL isStuck = YES;
                    NSDictionary *infoDic = @{
                        key_stackStr: reStr,
                        key_isStuck: [NSNumber numberWithBool:isStuck],
                        key_monitor_info: @"CPU useage overload thread stack"
                    };
                    YDLogMonitorDetail(@"%@", infoDic);
                    
                    NSLog(@"CPU useage overload thread stack：\n%@",reStr);
                }
            }
        }
    }
}

uint64_t memoryFootprint(void) {
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if (result != KERN_SUCCESS)
        return 0;
    return vmInfo.phys_footprint;
}

@end
