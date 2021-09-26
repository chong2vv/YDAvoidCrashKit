//
//  YDThreadSafeMutableSet.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/26.
//

#import "YDThreadSafeMutableSet.h"

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_set) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;

#define LOCK(...) dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(self->_lock);

@implementation YDThreadSafeMutableSet{
    NSMutableSet *_set;  //Subclass a class cluster...
    dispatch_semaphore_t _lock;
}

- (instancetype)init {
    INIT(_set = [[NSMutableSet alloc] init]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_set = [[NSMutableSet alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    INIT(_set = [[NSMutableSet alloc] initWithArray:array]);
}

- (instancetype)initWithSet:(NSSet *)set {
    INIT(_set = [[NSMutableSet alloc] initWithSet:set]);
}

- (instancetype)initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
    INIT(_set = [[NSMutableSet alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    INIT(_set = [[NSMutableSet alloc] initWithCoder:coder]);
}

- (instancetype)initWithObjects:(id)firstObj, ... {
    INIT(_set = [[NSMutableSet alloc] initWithObjects:firstObj, nil]);
}

- (void)addObject:(id)object {
    LOCK([_set addObject:object]);
}

- (void)removeObject:(id)object {
    LOCK([_set removeObject:object]);
}

- (void)removeAllObjects {
    LOCK([_set removeAllObjects]);
}

- (void)addObjectsFromArray:(NSArray *)array {
    LOCK([_set addObjectsFromArray:array]);
}

- (void)intersectSet:(NSSet *)otherSet {
    LOCK([_set intersectSet:otherSet]);
}

- (void)minusSet:(NSSet *)otherSet {
    LOCK([_set minusSet:otherSet]);
}

- (void)setSet:(NSSet *)otherSet {
    LOCK([_set setSet:otherSet]);
}

@end
