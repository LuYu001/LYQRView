# LYQRView
* 一行代码输出二维码
* 长按二维码可以保存到相册--以项目名称命名创建一个相册,将二维码图片保存至该相册

## 使用方法
`ShowQRViewController.m`
```objc 
LYQRView *QRView = [[LYQRView alloc] initQRViewWithFrame:frame Content:_contentString enableLongPressSaveToAlbum:YES]; 
[self.view addSubview:QRView]; 
```

##  `LYQRView.h`
``` objc
/**
  传入内容返回生成的二维码

 @param frame  frame
 @param string 二维码内容
 @param enable 是否允许长按二维码，保存至一个以项目名称命名的新建相册（iOS10以上需要正确配置info.plist文件，添加描述以允许访问相册）

 @return 包含二维码的View
 */ 
 - (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string enableLongPressSaveToAlbum:(BOOL)enable; 
 - (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string; 
```

## iOS10访问相册
需要在info.plist添加
```
Privacy - Photo Library Usage Description   是否允许该应用访问您的图库
```

## 展示二维码页面亮度调节
详见 `ShowQRViewController.m`
```
[[UIScreen mainScreen] setBrightness:0.6f];
```

## 源码地址
[https://github.com/LuYu001/LYQRView](https://github.com/LuYu001/LYQRView)
