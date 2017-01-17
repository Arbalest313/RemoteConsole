//
//  RemoteConsole.h
//  RemoteConsole
//
//  Created by huangyuan on 17/01/2017.
//  Copyright © 2017 hYDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteConsole : NSObject
+ (nonnull instancetype)shared;
- (void)startServer;
- (void)stopServer;
@end
