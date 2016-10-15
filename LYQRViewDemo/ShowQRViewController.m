//
//  ShowQRViewController.m
//  LYQRViewDemo
//
//  Created by LY on 2016/10/15.
//  Copyright © 2016年 luyu. All rights reserved.
//

#import "ShowQRViewController.h"
#import "LYQRView.h"
@interface ShowQRViewController ()

@property (assign, nonatomic)CGFloat oldBrightness;

@end

@implementation ShowQRViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _oldBrightness = [[UIScreen mainScreen] brightness];
    
    if (_oldBrightness < 0.5) {
        [[UIScreen mainScreen] setBrightness:0.6f];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[UIScreen mainScreen] setBrightness:_oldBrightness];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    CGFloat x = CGRectGetMidX(self.view.frame)-100;
    CGFloat y = CGRectGetMidY(self.view.frame)-100;
    
    CGRect frame = CGRectMake(x, y, 200, 200);
    
    LYQRView *QRView = [[LYQRView alloc] initQRViewWithFrame:frame Content:_contentString enableLongPressSaveToAlbum:YES];
    [self.view addSubview:QRView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
