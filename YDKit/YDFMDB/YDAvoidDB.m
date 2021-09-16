//
//  YDAvoidDB.m
//  YDKitDemo
//
//  Created by wangyuandong on 2021/9/16.
//

#import "YDAvoidDB.h"

@interface YDAvoidDB ()

@property (nonatomic, copy) NSString *crashDBPath;

@end

@implementation YDAvoidDB

+ (YDAvoidDB *)shareInstance {
    static YDAvoidDB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YDAvoidDB alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {

        _crashDBPath = [PATH_OF_DOCUMENT stringByAppendingPathComponent:@"YDAvoidCrash.sqlite"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:_crashDBPath] == NO) {
            FMDatabase *db = [FMDatabase databaseWithPath:_crashDBPath];
            if ([db open]) {
                NSString *createSql = @"create table YDAvoidCrash (crashId INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL, errorInfoDic text, crashTime text)";
                [db executeUpdate:createSql];
            }
        }
        
    }
    return self;
}

- (void)insertWithCrashModel:(YDAvoidCrashModel *)model {
    FMDatabase *db = [FMDatabase databaseWithPath:self.crashDBPath];
    if ([db open]) {
        [db executeUpdate:@"insert into YDAvoidCrash (errorInfoDic, crashTime) values (?, ?)", model.errorInfoDic, model.crashTime];
        [db close];
    }
}

- (NSArray *)selectAllCrashModel {
    NSMutableArray *crashInfoArray = [NSMutableArray array];
    FMDatabase *db = [FMDatabase databaseWithPath:self.crashDBPath];
    if ([db open]) {
        FMResultSet *rs = [db executeQuery:@"select * from YDAvoidCrash order by crashId desc"];
        while ([rs next]) {
            YDAvoidCrashModel *model = [[YDAvoidCrashModel alloc] init];
            model.crashId = [rs intForColumn:@"crashId"];
            model.errorInfoDic = [rs stringForColumn:@"errorInfoDic"];
            model.crashTime = [rs stringForColumn:@"crashTime"];
            [crashInfoArray addObject:model];
        }
    }
    return crashInfoArray;
}

- (void)clearAllDB {
    FMDatabase *db = [FMDatabase databaseWithPath:self.crashDBPath];
    if ([db open]) {
        [db executeUpdate:@"delete from YDAvoidCrash"];
    }
}
@end
