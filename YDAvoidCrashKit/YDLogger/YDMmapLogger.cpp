//
//  YDMmapLogger.cpp
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/22.
//

#include "YDMmapLogger.h"
#include <fcntl.h>
#include <sys/errno.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <string.h>
#include <sys/mount.h>

/**
 获取磁盘信息需要的文件目录
 
 在PC端或iOS模拟器的架构中，获取磁盘信息，需要的文件目录是 "/"
 在移动端iOS系统中，获取磁盘信息的文件目录是 "/var"
 */
#if __x86_64__  ||  __i386__
#   define STATFS_DIR "/"
#else
#   define STATFS_DIR "/var"
#endif



#pragma mark - Declare

/**
 静态方法，关闭文件的同时，返回错误信息

 @param err 需要返回的错误码
 @param fd 需要关闭的文件描述符
 @return 错误码 err
 */
static int returnErr (int err, int fd);

int yd_logger::mmapFile (off_t offset)
{
    if (fpath == NULL)
        return YD_NOPATH;
    
    struct stat statInfo;
    
    // 获取dataBits中的数据
    bool rw = readWrite();
    uint32_t pc_min = pageCountMin();
    uint32_t pc_max = pageCountMax();
    uint32_t rbc = reservedBC();
    uint32_t bs = blockSize();
    int ps = getpagesize();
    
    // 打开文件，读写或者只读
    if (fd) close(fd);
    fd = open(fpath, rw ? O_RDWR : O_RDONLY);
    if (fd < 0) return errno;
    
    // 获取文件状态信息
    if (fstat(fd, &statInfo) != 0)
        return returnErr(errno, fd);

    // 获取文件大小，与文件的最大长度进行比较
    uint32_t length = pc_max * ps;
    if (statInfo.st_size > length)
        return returnErr(YD_EXCESSIVE, fd);
    msize = (uint32_t)statInfo.st_size;
    
    // 计算文件映射的最小值
    uint32_t msize_min = pc_min * ps;
    if (msize)
        length = ((msize + msize_min - 1) / msize_min) * msize_min;
    else
        length = pc_min * ps;
    
    // 文件可读写
    if (rw) {
        
        // 获取磁盘信息，根据CPU架构不同，文件目录也不同
        struct statfs diskInfo;
        if (statfs(STATFS_DIR, &diskInfo) < 0)
            return returnErr(errno, fd);
        
        // 判断剩余的磁盘空间>=reserved_size才可以读写文件
        // 由于磁盘空间大小会超过uint32的表示范围，所以只比较运输块的个数
        int64_t freeBlk = diskInfo.f_bavail - (rbc / (diskInfo.f_bsize / bs));
        if (freeBlk < (length + diskInfo.f_bsize - 1) / diskInfo.f_bsize)
            return returnErr(YD_NOSPACE, fd);
        
        // 拓展文件大小且以0填充，否则无法写入
        if (msize < length) {
            if (ftruncate(fd, length) != 0)
                return returnErr(errno, fd);
        }
        
        // 映射到虚拟内存中，可读写模式
        // 详解：https://blog.csdn.net/TuGeLe/article/details/84556314
        start_p = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fd, offset);
    }
    // 文件只读
    else {
        if (msize < 1) return YD_NOFILE;
            
        // 映射到虚拟内存，只读模式
        start_p = mmap(NULL, msize, PROT_READ, MAP_SHARED, fd, offset);
    }
    
    // 文件映射失败
    if (start_p == MAP_FAILED) {
        msize = 0;
        start_p = NULL;
        return returnErr(errno, fd);
    }
    
    // 文件映射成功
    current_p = rw ? ((uint8_t *)start_p + msize) : start_p;
    msize_file = length;
    msize_max = pc_max * ps;
    bits.setFlags(YD_OPENED_MASK);
    
    return 0;
}

int yd_logger::munmapFile(void *start, const uint32_t fsize)
{
    if (!hasOpened()) return YD_UNOPENED;
    if (start == NULL) return YD_NOSTART;
    
    // 关闭文件映射
    int errCode = 0;
    errCode = munmap(start, fsize);
    bits.clearFlags(YD_OPENED_MASK);
    
    uint32_t length_max = msize_file;
    msize = 0;
    msize_file = 0;
    msize_max = 0;
    
    // 读写模式下，需检查文件的真实大小，如果文件未写满，则使文件恢复为真实文件大小
    if (readWrite() && fpath != NULL && fsize < length_max) {
        
        start_p = NULL;
        current_p = NULL;
        fpath = NULL;
        
        if (!fd) return YD_INVALIDFD;
        
        // 更新文件大小
        if (ftruncate(fd, fsize) != 0)
            return returnErr(errno, fd);
//        if (fsync(fd) != 0)
//            return returnErr(errno, fd);
        
        close(fd);
        fd = 0;
    }
    else {
        start_p = NULL;
        current_p = NULL;
        fpath = NULL;
        if (fd) close(fd);
        fd = 0;
    }
    
    return errCode;
}

int yd_logger::increaseFileSize (uint32_t increasedSize)
{
    if (!fd) return YD_INVALIDFD;
    if (!hasOpened()) return YD_UNOPENED;
    
    // 获取dataBits中的数据
    uint32_t rbc = reservedBC();
    uint32_t bs = blockSize();
    uint32_t msize_min = pageCountMin() * getpagesize();
    
    // 计算增加后的文件大小，必须是内存页的整倍数
    uint32_t length = ((increasedSize + msize_min - 1) / msize_min) * msize_min;
    
    // 判断文件大小是否超出最大值
    if (length > msize_max) return YD_EXCESSIVE;

    // 获取磁盘信息，根据CPU架构不同，文件目录也不同
    struct statfs diskInfo;
    if (statfs(STATFS_DIR, &diskInfo) < 0)
        return errno;

    // 判断剩余的磁盘空间>=reserved_size才可以读写文件
    // 由于磁盘空间大小会超过uint32的表示范围，所以只比较运输块的个数
    int64_t freeBlk = diskInfo.f_bavail - (rbc / (diskInfo.f_bsize / bs));
    if (freeBlk < (length + diskInfo.f_bsize - 1) / diskInfo.f_bsize)
        return YD_NOSPACE;

    // 拓展文件大小且以0填充，否则无法写入
    if (ftruncate(fd, length) != 0)
        return errno;
    
    // 关闭之前的映射，因为映射的大小空间不足了
    munmap(start_p, msize_file);
    bits.clearFlags(YD_OPENED_MASK);
    
    // 重新开启新的映射
    void *new_sp, *old_sp;
    void *new_cp, *old_cp;
    new_sp = mmap(NULL, length, PROT_READ | PROT_WRITE, MAP_FILE | MAP_SHARED, fd, 0);
    if (new_sp == MAP_FAILED)
        return errno;
    
    // 原子性CAS操作
    do {
        old_sp = start_p;
//       atomic_compare_exchange_strong(old_sp, new_sp, &start_p);
    } while (YD_LIKELY(!OSAtomicCompareAndSwapPtrBarrier(old_sp, new_sp, &start_p)));
    do {
        old_cp = current_p;
        new_cp = (uint8_t *)start_p + msize;
    } while (YD_LIKELY(!OSAtomicCompareAndSwapPtrBarrier(old_cp, new_cp, &current_p)));
    
    msize_file = length;
    bits.setFlags(YD_OPENED_MASK);
    return 0;
}

int yd_logger::mRecorde(void *start, const void *data, const size_t length)
{
    if (YD_UNLIKELY(start == NULL)) return YD_NOSTART;
    
    // 检测文件是否有空余空间
    if (YD_UNLIKELY((uint8_t *)start_p + msize_file < (uint8_t *)start + length))
        return YD_NORAM;
    
    // 数据写入通过将数据复制到指定内存地址即可
    memcpy(start, data, length);
    
    return 0;
}

int yd_logger::mRecordeNext(const void *data, const size_t length)
{
    if (YD_UNLIKELY(current_p == NULL)) return YD_NOSTART;
    if (YD_UNLIKELY(msize_file < msize + length)) return YD_NORAM;
    
    memcpy(current_p, data, length);
    
    // CAS操作，保证标志位的线程安全
    void *oldf, *newf;
    uint32_t oldi, newi;
    
    // 先计算，再交换
    do {
        oldi = msize;
        newi = msize + (uint32_t)length;
    } while (YD_LIKELY(!OSAtomicCompareAndSwap32Barrier(oldi, newi, (volatile int32_t *)&msize)));
    do {
        oldf = current_p;
        newf = (uint8_t *)current_p + length;
    } while (YD_LIKELY(!OSAtomicCompareAndSwapPtrBarrier(oldf, newf, &current_p)));
//    atomic_compare_exchange_strong((volatile atomic_uint *)&oldf, (unsigned int *)&newf, (unsigned long )&current_p);
    
    return 0;
}

int yd_logger::syncData(void *start, const size_t length)
{
    if (start == NULL) return YD_NOSTART;
    if (length == 0) return 0;
    
    // 将虚拟内存中的数据，立即写回磁盘
    if (msync(start, length, MS_SYNC | MS_ASYNC) == 0) {
        return 0;
    }
    else {
        return errno;
    }
}

std::string yd_logger::errorDescription(const int err)
{
    std::string errDes;
    
    switch (err) {
        case EEXIST:
            errDes = "文件已存在,却使用了O_CREAT和O_EXCL旗标";
            break;
        case EACCES:
            errDes = "文件不符合所要求的权限";
            break;
        case EROFS:
            errDes = "欲测试写入权限的文件存在于只读文件系统内";
            break;
        case EINVAL:
            errDes = "一个或者多个参数无效";
            break;
        case EIO:
            errDes = "I/O存取错误";
            break;
        case EBADF:
            errDes = "文件描述词无效";
            break;
        case ENOENT:
            errDes = "路径名的部分组件不存在，或路径名是空字串";
            break;
        case ENOMEM:
            errDes = "核心内存不足";
            break;
        case EFAULT:
            errDes = "地址空间不可访问";
            break;
        case ELOOP:
            errDes = "遍历路径时遇到太多的符号连接";
            break;
        case ENAMETOOLONG:
            errDes = "文件路径名太长";
            break;
        case ENOTDIR:
            errDes = "路径名的部分组件不是目录";
            break;
        case EAGAIN:
            errDes = "文件已被锁定，或者太多的内存已被锁定";
            break;
        case ENFILE:
            errDes = "已达到系统对打开文件的限制";
            break;
        case ENODEV:
            errDes = "指定文件所在的文件系统不支持内存映射";
            break;
        case EPERM:
            errDes = "权能不足，操作不允许";
            break;
        case ETXTBSY:
            errDes = "已写的方式打开文件，同时指定MAP_DENYWRITE标志";
            break;
        case EBUSY:
            errDes = "已写的方式打开文件，同时指定MAP_DENYWRITE标志";
            break;
            
            /* 自定义errCode */
        case YD_NOPATH:
            errDes = "文件路径为NULL";
            break;
        case YD_NOSPACE:
            errDes = "磁盘空间不足，请先清理磁盘";
            break;
        case YD_EXCESSIVE:
            errDes = "文件过大";
            break;
        case YD_NOFILE:
            errDes = "文件无内容，无法打开";
            break;
        case YD_UNOPENED:
            errDes = "没有文件被映射";
            break;
        case YD_INVALIDFD:
            errDes = "无效的文件描述符";
            break;
        case YD_NOSTART:
            errDes = "无起始地址，写入数据失败";
            break;
        case YD_NORAM:
            errDes = "数据过大，无法写入";
            break;
        default:
            errDes = "未找到错误描述，请自行查阅文档";
            break;
    }
    
    return errDes;
}


#pragma mark - Private

static int returnErr (int err, int fd)
{
    close(fd);
    return err;
}

