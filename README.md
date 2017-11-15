# RemoteConsole
![](https://github.com/Arbalest313/gitRecord/blob/master/RemoteConsole/RemoteConsole.gif?raw=true)

1. Drag xcodeConsole.html into your broswer
2. Write your code as following:
```objc
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[RemoteConsole shared] startServer];
    NSLog(@"%@", NSStringFromSelector(_cmd));
}
```
3. Ready to go

Seeing your console log anywhere with formatting in colors

[如果你在天朝](http://hyyy.me/2017/01/16/RemoteConsole/)
