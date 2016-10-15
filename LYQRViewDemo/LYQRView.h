//
//  LYQRView.h
//  LYQRView
//
//  Created by luyu on 16/10/14.
//  Copyright © 2016年 luyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYQRView : UIView

@property (strong, nonatomic)UIImageView *QRImageView;

/**
  传入内容返回生成的二维码

 @param frame  frame
 @param string 二维码内容
 @param enable 是否允许长按二维码，保存至一个以项目名称命名的新建相册（iOS10以上需要正确配置info.plist文件，添加描述以允许访问相册）

 @return 包含二维码的View
 */
- (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string enableLongPressSaveToAlbum:(BOOL)enable;

- (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string;


@end
