//
//  LYQRView.m
//  LYQRView
//
//  Created by luyu on 16/10/14.
//  Copyright © 2016年 luyu. All rights reserved.
//

#import "LYQRView.h"
#import <Photos/Photos.h>

@interface LYQRView ()
@property (weak, nonatomic)NSString *contentStr;
@property (assign, nonatomic)CGFloat size;
@property (assign, nonatomic)BOOL enablePress;
@end

@implementation LYQRView


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {

        // 1.创建过滤器
        CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        // 2.恢复默认
        [filter setDefaults];
        // 3.给过滤器添加数据
        NSString *dataString = _contentStr;
        NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
        [filter setValue:data forKeyPath:@"inputMessage"];
        ///设置二维码容错，默认中等
        //    [filter setValue:@"M" forKey:@"inputCorrectionLevel"];
        
        // 4.获取输出的二维码
        CIImage *outputImage = [filter outputImage];
        
        // 5.将CIImage转换成UIImage，并放大显示
        self.QRImageView = [[UIImageView alloc] init];
        self.QRImageView.userInteractionEnabled = _enablePress;
        self.QRImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.QRImageView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:_size];
        
        //长按手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreentShot:)];
        [self.QRImageView addGestureRecognizer:longPress];
        
        [self addSubview:_QRImageView];
        
    }
    
    return self;
}

- (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string enableLongPressSaveToAlbum:(BOOL)enable {
    
    _contentStr = string;
    _enablePress = enable;
    CGFloat height = CGRectGetHeight(frame);
    CGFloat width = CGRectGetWidth(frame);
    
    _size = height > width ? width : height;//以窄边作为二维码宽度和高度
    
    return [self initWithFrame:frame];
    
}

- (instancetype)initQRViewWithFrame:(CGRect)frame Content:(NSString *)string {
    
    return [self initQRViewWithFrame:frame Content:string enableLongPressSaveToAlbum:NO];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.QRImageView.frame = self.bounds;
}

/**
 * 根据CIImage生成指定大小的UIImage
 *
 * @param image CIImage
 * @param size 图片宽度
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
    
}

- (void)tapScreentShot:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSLog(@"截图");
        
        //保存到相册
        [self save];
        
    }
    
}

/**
 *  获得刚才添加到【相机胶卷】中的图片
 */
- (PHFetchResult<PHAsset *> *)createdAssets
{
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:_QRImageView.image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

/**
 *  获得【自定义相册】
 */
- (PHAssetCollection *)createdCollection
{
    // 获取软件的名字作为相册的标题
    NSString *title = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleNameKey];
    
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    
    // 代码执行到这里，说明还没有自定义相册
    
    __block NSString *createdCollectionId = nil;
    
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil) return nil;
    
    // 创建完毕后再取出相册
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
}

/**
 *  保存图片到相册
 */
- (void)saveImageIntoAlbum
{
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = self.createdAssets;
    
    // 获得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    
    if (createdAssets == nil || createdCollection == nil) {
        NSLog(@"保存失败！");
//        [SVProgressHUD showErrorWithStatus:@"保存失败！"];
        return;
    }
    
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
        NSLog(@"保存失败！您可以手动截图保存");
//        [SVProgressHUD showErrorWithStatus:@"保存失败！您可以手动截图保存"];
    } else {
        NSLog(@"二维码已保存到系统相册");
//        [SVProgressHUD showSuccessWithStatus:@"二维码已保存到系统相册"];
    }
}

- (void)save {
    /*
     requestAuthorization方法的功能
     1.如果用户还没有做过选择，这个方法就会弹框让用户做出选择
     1> 用户做出选择以后才会回调block
     
     2.如果用户之前已经做过选择，这个方法就不会再弹框，直接回调block，传递现在的授权状态给block
     */
    
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized: {
                    //  保存图片到相册
                    [self saveImageIntoAlbum];
                    break;
                }
                    
                case PHAuthorizationStatusDenied: {
                    if (oldStatus == PHAuthorizationStatusNotDetermined) return;
                    
                    NSLog(@"提醒用户打开相册的访问开关");
//                    [SVProgressHUD showErrorWithStatus:@"请前往系统设置打开允许访问照片"];
                    break;
                }
                    
                case PHAuthorizationStatusRestricted: {
                    NSLog(@"因系统原因，无法访问相册！");
//                    [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
                    break;
                }
                    
                default:
                    break;
            }
        });
    }];
    
    // PHAuthorizationStatusNotDetermined
    // 用户还没有对当前App授权过(用户从未点击过Don't Allow或者OK按钮)
    
    // PHAuthorizationStatusRestricted
    // 因为一些系统原因导致无法访问相册（比如家长控制）
    
    // PHAuthorizationStatusDenied
    // 用户已经明显拒绝过当前App访问相片数据（用户已经点击过Don't Allow按钮）
    
    // PHAuthorizationStatusAuthorized
    // 用户已经允许过当前App访问相片数据（用户已经点击过OK按钮）
    
    //    switch ([PHPhotoLibrary authorizationStatus]) {
    //        case PHAuthorizationStatusAuthorized: {
    //            [self saveImageIntoAlbum];
    //            break;
    //        }
    //
    //        case PHAuthorizationStatusDenied: {
    //            // 提醒用户打开访问开关
    //            break;
    //        }
    //
    //        case PHAuthorizationStatusRestricted: {
    //            [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
    //            break;
    //        }
    //
    //        case PHAuthorizationStatusNotDetermined: {
    //            // 弹框让用户做出选择
    //            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    //                // 用户刚才点击的是OK按钮
    //                if (status == PHAuthorizationStatusAuthorized) {
    //                    [self saveImageIntoAlbum];
    //                }
    //            }];
    //            break;
    //        }
    //    }
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
