//
//  ViewController.m
//  RemoteConsole
//
//  Created by huangyuan on 17/01/2017.
//  Copyright © 2017 hYDev. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy)NSArray * dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView * tableV = [[UITableView alloc] initWithFrame:self.view.bounds];
    
    tableV.dataSource = self;
    tableV.delegate = self;
    [tableV registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    _dataSource = [@[@"第1行",@"第2行",@"第3行",@"第4行 -- Warning",@"第5行",@"第6行 -- Error",@"第7行",@"第8行  -- Response",@"第9行",@"第10行",@"第11行",@"第12行"] mutableCopy];
    [self.view addSubview:tableV];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier"];
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath index:%@ info:%@",indexPath, self.dataSource[indexPath.row]);
}



@end
