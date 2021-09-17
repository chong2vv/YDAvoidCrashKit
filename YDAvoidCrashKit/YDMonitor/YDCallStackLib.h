//
//  YDCallStackLib.h
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/17.
//

#import <Foundation/Foundation.h>
#include <mach/mach.h>
#include <dlfcn.h>
#include <pthread.h>
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

#include <mach/task.h>
#include <mach/vm_map.h>
#include <mach/mach_init.h>
#include <mach/thread_act.h>
#include <mach/thread_info.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/sysctl.h>
#include <objc/message.h>
#include <objc/runtime.h>
#include <dispatch/dispatch.h>


#ifdef __LP64__
typedef struct mach_header_64     machHeaderByCPU;
typedef struct segment_command_64 segmentComandByCPU;
typedef struct section_64         sectionByCPU;
typedef struct nlist_64           nlistByCPU;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT_64

#else
typedef struct mach_header        machHeaderByCPU;
typedef struct segment_command    segmentComandByCPU;
typedef struct section            sectionByCPU;
typedef struct nlist              nlistByCPU;
#define LC_SEGMENT_ARCH_DEPENDENT LC_SEGMENT
#endif

#ifndef SEG_DATA_CONST
#define SEG_DATA_CONST  "__DATA_CONST"
#endif

@interface YDCallStackLib : NSObject

@end

