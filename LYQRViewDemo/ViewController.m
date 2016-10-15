//
//  ViewController.m
//  LYQRViewDemo
//
//  Created by LY on 2016/10/15.
//  Copyright © 2016年 luyu. All rights reserved.
//

#import "ViewController.h"
#import "ShowQRViewController.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)createQRView:(id)sender {
    ShowQRViewController *sVC = [[ShowQRViewController alloc] init];
    sVC.contentString = _contentTextField.text;
    [self showViewController:sVC sender:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
