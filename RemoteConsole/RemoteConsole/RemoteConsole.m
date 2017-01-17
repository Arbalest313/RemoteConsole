//
//  RemoteConsole.m
//  RemoteConsole
//
//  Created by huangyuan on 17/01/2017.
//  Copyright © 2017 hYDev. All rights reserved.
//

#import "RemoteConsole.h"
#import "PSWebSocketServer.h"

@interface RemoteConsole () <PSWebSocketServerDelegate>

@property (nonatomic, strong) PSWebSocketServer *server;//tiny webSocketServer
@property (nonatomic, strong, nullable)PSWebSocket * webSocket;//the webSocket

@property (nonatomic,assign) int originalStdHandle;//original file descriptor

@property (nonatomic,strong) dispatch_source_t sourt_t;//file descriptor mointor

@end

@implementation RemoteConsole
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static RemoteConsole *shared;
    dispatch_once(&onceToken, ^{
        shared = [RemoteConsole new];
    });
    return shared;
}


- (instancetype)init {
    if (self = [super init]) {
        _server = [PSWebSocketServer serverWithHost:nil port:8080];
        _server.delegate = self;
    }
    return self;
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    NSLog(@"Server did start…");
    if (_sourt_t) {
        dispatch_cancel(_sourt_t);
    }
    _sourt_t = [self startCapturingLogFrom:STDERR_FILENO];
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    NSLog(@"Server did stop…");
    dispatch_cancel(_sourt_t);
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
    NSLog(@"Server should accept request: %@", request);
    return YES;
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Server websocket did receive message: %@", message);
}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    NSLog(@"Server websocket did open");
    self.webSocket = webSocket;
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}
- (void)server:(PSWebSocketServer *)server didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}

- (void)startServer{
    [_server start];
    
}
- (void)stopServer {
    [_server stop];
}

- (dispatch_source_t)startCapturingLogFrom:(int)fd  {
    int origianlFD = fd;
    int originalStdHandle = dup(fd);//save the original for reset proporse
    int fildes[2];
    pipe(fildes);  // [0] is read end of pipe while [1] is write end
    dup2(fildes[1], fd);  // Duplicate write end of pipe "onto" fd (this closes fd)
    close(fildes[1]);  // Close original write end of pipe
    fd = fildes[0];  // We can now monitor the read end of the pipe
    
    NSMutableData* data = [[NSMutableData alloc] init];
    fcntl(fd, F_SETFL, O_NONBLOCK);// set the reading of this file descriptor without delay
    __weak typeof(self) wkSelf = self;
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, fd, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    
    int writeEnd = fildes[1];
    dispatch_source_set_cancel_handler(source, ^{
        close(writeEnd);
        dup2(originalStdHandle, origianlFD);//reset the original file descriptor
    });
    
    dispatch_source_set_event_handler(source, ^{
        @autoreleasepool {
            char buffer[1024 * 10];
            ssize_t size = read(fd, (void*)buffer, (size_t)(sizeof(buffer)));
            [data setLength:0];
            [data appendBytes:buffer length:size];
            NSString *aString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [wkSelf.webSocket send:aString];
            printf("\n%s\n",[aString UTF8String]); //print on STDOUT_FILENO，so that the log can still print on xcode console
        }
    });
    dispatch_resume(source);
    return source;
}

@end
