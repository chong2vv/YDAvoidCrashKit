# YDAvoidCrashKit
## YDAvoidCrash 防崩溃库介绍
YDAvoidCrash 主要借鉴了[@chenfanfang](https://github.com/chenfanfang)大神开源的 [AvoidCrash](https://github.com/chenfanfang/AvoidCrash)。由于AvoidCrash不再维护更新，同时鉴于实际业务开发中所使用的类逐渐增加，因此YDAvoidCrash在原AvoidCrash上重新开发。毕竟，一个已经发布到AppStore上的App，最忌讳的就是崩溃问题，相信作为开发者对于所产出项目的崩溃率要求都极为严格，因此YDAvoidCrash库就是为此存在。

相较于原库，YDAvoidCrash新增了以下功能及优化：

- 新增了其他系统类的防崩溃，目前约支持17个系统类（逐步迭代更新）;
- 支持回调设置，方便应用上报；
- 新增YDLogger日志采集系统，用以捕捉崩溃等日志（如操作日志、错误日志、请求日志等），同时YDLogger自带YDLoggerUI可以方便可视化查询日志；
- 新增卡顿检测组件YDMonitor辅助优化项目;
- 新增安全线程及数据操作组件YDSafeThread;
- YDLogger日志是通过每次启动APP即可生成当前的日志文件，可以通过获取全部文件后进行压缩等形式上次服务端，同时可以下载后通过YDLoggerUI进行快速查看;
- 增加UI刷新防护，防止异步线程刷新UI导致的问题。


## 安装及使用方式
### 使用CocoaPods导入

```
pod 'YDAvoidCrashKit', '0.0.9'
```
### 使用方法

#### YDAvoidCrash 防崩溃库使用

使用时引入头文件：

```
#import "YDAvoidCrashKit.h"
```

之后在AppDelegate的didFinishLaunchingWithOptions方法中的最初始位置添加如下代码，让YDAvoidCrash生效

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //设置允许防崩溃类前缀
    [YDAvoidCrash setAvoidCrashEnableMethodPrefixList:@[@"NS",@"YD"]];
    
    //接收异常的回调处理，可以用来上报等
    [YDAvoidCrash setupBlock:^(NSException *exception, NSString *defaultToDo, BOOL upload) {
            
    }];
    //开启全部类拦截，同时开启日志收集（日志默认保存10天，可以在开启前通过[[YDLogService shared] clearLogWithDayTime:5]设置）
    [YDAvoidCrash becomeAllEffectiveWithLogger:YES];
    
    return YES;
}
```

#### YDLogger使用
如果想使用YDLogger日志收集系统，可在本地开启日志（YDAvoidCrash becomeAllEffectiveWithLogger:YES]）后使用：

```
/**
 日志记录宏，只记录到本地，使用方法和NSLog相同，引用当前文件后可直接使用
 根据日志level的不同，记录的日志不同
 当调用setLogLevel:设置需要记录的日志level为YDLogDebug时，那么YDLogDebug等级以下的等级（含YDLogDebug）都会被记录
 默认设置为YDLogDetail
 
 YDLogError()   记录错误信息，适用于线上/线下环境，格式：@"Erro timeStamp error"
 YDLogInfo()    记录极简信息，适用于线上/线下环境，格式：@"Info timeStamp info"
 YDLogDetail()  记录详细信息，适用于线上/线下环境，格式：@"Deta timeStamp [thread] func str"
 YDLogDebug()   记录开发信息，适用于Debug环境，格式：@"Dbug timeStamp str"
 YDLogVerbose() 记录复杂信息，适用于Debug环境，格式：@"Verb timeStamp [thread] func in file:line desc"
 详细使用可参考具体宏定义
 */
```
同时，为了方便快速查看日志，可以用YDLogger自带的YDLoggerUI：

```
 YDLogListViewController *vc = [[YDLogListViewController alloc] init];
 [self.navigationController pushViewController:vc animated:YES];
```

## 更新
#### v0.1.0

1. 新增卡顿检测组件YDMonitor辅助优化项目
2. 新增安全线程及数据操作组件YDSafeThread
3. 增加UIView主线程刷新UI防护

## 写在最后的话
一个人的精力是有限的，如果你发现了哪些常用的Foundation中的方法存在潜在崩溃的危险，而这个框架中没有进行处理，希望你能 issue, 我将添加到YDAvoidCrash中，同时在使用过程中发现BUG或者有更好的解决方法也同样欢迎你能issue，我将万分感谢！
