//
//  YDMmapLogger.hpp
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#ifndef YDMmapLogger_hpp
#define YDMmapLogger_hpp

#include <stdio.h>
#include <libkern/OSAtomic.h>
#include <unistd.h>
#include <string>

/**
 自定义错误类型
 
 YDMmapLogger 文件中，除了C函数的错误外，其他无法处理或者不予处理的错误类型
 */
typedef enum : int {
    /****** 文件映射/关闭映射相关错误 ******/
    YD_NOPATH      =     1001,      // 文件路径为nil
    YD_NOSPACE     =     1002,      // 磁盘空间不足
    YD_EXCESSIVE   =     1003,      // 文件过大
    YD_NOFILE      =     1004,      // 只读模式，且待读取的文件大小为0
    YD_UNOPENED    =     1005,      // 没有被打开的文件
    YD_INVALIDFD   =     1006,      // 无效的文件描述符
    
    /****** 日志写入相关错误 ******/
    YD_NOSTART     =     2001,      // 写入文件的起始指针为NULL
    YD_NORAM       =     2002,      // 文件没有足够空间保存即将写入的数据
} YDERROR;

/**
 汇编代码优化，减少条件分支语句的跳转，提高汇编代码效率
 正常的条件分支语句必要跳转一次，使用__builtin_expect后，大部分的情况可以避免跳转
 由于汇编层优化，会导致分支语句以下的代码会生成相同的2份，一份是不跳转执行，一份是跳转后执行，会造成代码冗余
 示例：https://blog.csdn.net/grublinux/article/details/37543489
 */
#if __GNUC__
#define YD_LIKELY(x) __builtin_expect(!!(x),1)
#define YD_UNLIKELY(x) __builtin_expect(!!(x),0)
#else
#define YD_LIKELY(x) (!!(x))
#define YD_UNLIKELY(x) (!!(x))
#endif

/**
 union yd_flags 的位域
 
 opened 默认为0 文件是否打开
 read_write 默认为1 文件打开模式是否为可读写
 block_size 默认为1024 自定义的文件运输块的大小，方便不同的系统计算磁盘剩余空间
 fsize_min 默认为256*1024 文件大小的最小值，但不是绝对最小值，因为mmap映射的虚拟内存大小是内存页大小的整倍数
 fsize_max 默认为256*1024 文件大小的最大值，但不是绝对最大值，因为mmap映射的虚拟内存大小是内存页大小的整倍数
 reserved_size 默认为32*1024*1024 剩余的磁盘空间需不小于reserved_size，才可以写入数据
 */
#define YDFLAGS_BITFIELD                       \
    uint32_t opened         : 1;               \
    uint32_t read_write     : 1;               \
    uint32_t block_size     : 11;              \
    uint32_t fsize_min      : 11;              \
    uint32_t fsize_max      : 1;               \
    uint32_t reserved_size  : 7


/**
 yd_flags成员变量datas的默认值
 */
#define YD_FLAGS_VALUE      0x03040402


/**
 union yd_flags 位域的mask
 */
#define YD_OPENED_MASK      1
#define YD_RW_MASK          (1<<1)
#define YD_BS_MASK          0x00001ffc
#define YD_FSMIN_MASK       0x00ffe000
#define YD_FSMAX_MASK       0x01000000
#define YD_RS_MASK          0xfe000000


/**
 yd_logger bits
 */
typedef union yd_flags {
    yd_flags ():datas(YD_FLAGS_VALUE) {}
    yd_flags (uint32_t datas):datas(datas) {}
    
private:
    uint32_t datas;
    struct {
        YDFLAGS_BITFIELD;
    };
    
public:
    // 根据传入的mask，获取标志位数据
    uint32_t getFlags (uint32_t flag)
    {
        return datas & flag;
    }
    
    // 原子性或操作
    void setFlags (uint32_t set)
    {
        OSAtomicOr32Barrier(set, &datas);
    }
    // 原子性异或操作
    void clearFlags (uint32_t clear)
    {
        OSAtomicXor32Barrier(clear, &datas);
    }
    
    // 原子性CAS操作，且同时进行set和clear
    void changeFlags (uint32_t set, uint32_t clear)
    {
        if ((set & clear) != 0) return;
        
        uint32_t oldf, newf;
        do {
            oldf = datas;
            newf = (oldf | set) & ~clear;
        } while (!OSAtomicCompareAndSwap32Barrier(oldf, newf, (volatile int32_t *)&datas));
    }
    
}dataBits;

struct yd_logger {
    yd_logger ():bits(yd_flags()), fpath(NULL), fd(0), start_p(NULL), current_p(NULL), msize(0), msize_file(0), msize_max(0) {}
    yd_logger (char *fpath):bits(yd_flags()), fpath(fpath), fd(0), start_p(NULL), current_p(NULL), msize(0), msize_file(0), msize_max(0) {}
    yd_logger (char *fpath, bool readOnly):bits(yd_flags()), fpath(fpath), fd(0), start_p(NULL), current_p(NULL), msize(0), msize_file(0), msize_max(0)
    {
        // 设置文件读写模式，可读写或只读
        if (readOnly == false) bits.clearFlags(YD_RW_MASK);
    }
    
private:
    dataBits bits;          // 标志位以及默认设置的数据
    char *fpath;            // 保存文件路径
    int fd;                 // 文件描述符
    
    void *start_p;          // 文件映射到虚拟内存的首地址
    void *current_p;        // 文件数据的当前位置
    uint32_t msize;         // 文件映射到虚拟内存中的真实数据的大小
    uint32_t msize_file;    // 文件映射到虚拟内存中的大小
    uint32_t msize_max;     // 文件映射到虚拟内存中的最大值，绝对最大值
    
public:
    /**
     将fpath路径的文件映射到虚拟内存，大小是内存页大小的整倍数

     @param offset 读取位置与文件起始的偏移长度
     @return 错误码为0则成功，否则失败
     */
    int mmapFile (off_t offset);
    int mmapFile ()
    {
        return mmapFile(0);
    }
    
    /**
     关闭虚拟内存映射，并且更新文件大小为文件的真实大小
     cpu消耗很大，且不支持密集操作

     @param start 文件在虚拟内存中的首地址
     @param fsize 文件长度
     @return 错误码为0则成功，否则失败
     */
    int munmapFile (void *start, const uint32_t fsize);
    int munmapFile ()
    {
        return munmapFile(start_p, msize);
    }
    
    /**
     增加文件的大小，先更新文件大小，然后关闭当前的映射，再将更新过的大小的文件映射到虚拟内存中

     @param increasedSize 文件更新后的大小
     @return 错误码为0则成功，否则失败
     */
    int increaseFileSize (uint32_t increasedSize);
    int increaseFileSize ()
    {
        uint32_t size = pageCountMin() * getpagesize() + msize;
        return increaseFileSize(size);
    }
    
    /**
     向虚拟内存中写入数据，系统内核会定时将脏页面回写到磁盘中

     @param start 写入数据位置的首地址
     @param data 即将写入的数据
     @param length 数据长度
     @return 错误码为0则成功，否则失败
     */
    int mRecorde (void *start, const void *data, const size_t length);
    int mRecordeNext (const void *data, const size_t length);
    
    /**
     立即回写数据，不支持密集操作

     @param start 数据起始位置
     @param length 数据长度
     @return 错误码为0则成功，否则失败
     */
    int syncData (void *start, const size_t length);
    int syncData (const uint32_t off, const size_t length)
    {
        return syncData((uint8_t *)start_p + off, length);
    }
    int syncAll ()
    {
        return syncData(start_p, msize);
    }
    
    /**
     根据错误码，获取错误描述

     @param err 错误码
     @return 错误描述
     */
    std::string errorDescription (const int err);
    
    /**
     修改文件路径，无法在文件已开启状态下更换文件路径

     @param path 文件路径
     */
    void setFilePath (const char *path)
    {
        if (hasOpened()) return ;
        fpath = const_cast<char *>(path);
    }
    
    /**
     修改文件读写模式

     @param rw 是否为可读写
     */
    void setReadWrite (bool rw)
    {
        if ((rw ^ (readWrite())) == 0)
            return;
        if (rw)
            bits.setFlags(YD_RW_MASK);
        else
            bits.clearFlags(YD_RW_MASK);
    }
    
    // 当前文件的总数据大小
    const uint32_t totalSize ()
    {
        return msize;
    }
    
    // 文件数据长度的最小值
    const uint32_t fileSizeMin ()
    {
        return pageCountMin() * getpagesize();
    }
    
    // 文件数据长度的最大值
    const uint32_t fileSizeMax ()
    {
        return msize_file;
    }
    
    // 文件是否已打开
    bool hasOpened ()
    {
        return bits.getFlags(YD_OPENED_MASK);
    }
    
    // 文件是否是可读写模式
    bool readWrite ()
    {
        return bits.getFlags(YD_RW_MASK);
    }
    
    // 自定义文件运输块的大小
    uint32_t blockSize ()
    {
        return bits.getFlags(YD_BS_MASK);
    }
    
    // 文件最少支持的内存页的个数
    uint32_t pageCountMin ()
    {
        int ps = getpagesize();
        
        // 向上取整，为了可以读取文件
        return (bits.getFlags(YD_FSMIN_MASK) + ps - 1) / ps;
    }
    
    // 文件最多支持的内存页的个数
    uint32_t pageCountMax ()
    {
        int ps = getpagesize();
        
        // 向上取整，为了可以读取文件
        return (bits.getFlags(YD_FSMAX_MASK) + ps - 1) / ps;
    }
    
    // 磁盘预留空间的文件运输块个数
    uint32_t reservedBC ()
    {
        return bits.getFlags(YD_RS_MASK) / blockSize();
    }
};


#endif /* YDMmapLogger_hpp */
