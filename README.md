# YDKit
## YDAvoidCrash 防崩溃库介绍
YDAvoidCrash 是根据[@chenfanfang](https://github.com/chenfanfang)开源的 [AvoidCrash](https://github.com/chenfanfang/AvoidCrash)库进行二次开发的，相较于原库新增了其他系统类的防崩溃，同时支持异常信息回调，以方便捕捉后本地存储或上报服务端。

## 安装及使用方式
### 使用CocoaPods导入

```
pod 'YDAvoidCrashKit', '0.0.3'
```
### 使用方法

使用时引入头文件：

```
#import "YDKit.h"
```

之后在AppDelegate的didFinishLaunchingWithOptions方法中的最初始位置添加如下代码，让YDAvoidCrash生效

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //接收异常的回调处理
    [YDAvoidCrash setupBlock:^(NSException *exception, NSString *defaultToDo, BOOL upload) {
            
    }];
    //开启全部异常拦截（建议）
    [YDAvoidCrash becomeAllEffective];
    return YES;
}
```

或者使用：

```
+ (void)becomeEffective:(NSArray<NSString *> *)openavoidcrash
```
进行动态配置拦截。
