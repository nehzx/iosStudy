//
//  ViewController.m
//  MLDay3
//
//  Created by 徐振 on 2017/12/1.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <Vision/Vision.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "VGG16.h"
@interface ViewController ()<AVCapturePhotoCaptureDelegate>

/**
 
 */
@property (nonatomic, strong)AVCaptureSession * captureSession;
/**
 输出
 */
@property (nonatomic, strong)AVCapturePhotoOutput * captureOutput;
/**
 显示图层
 */
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * previewLayer;
/**
 相机 view
 */
@property (nonatomic, strong)UIView * photoView;

/**
 显示识别结果
 */
@property (nonatomic, strong) UIButton * restult;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.restult];
    
    [self setCaptuer];
    
}

- (void)setCaptuer {
    //初始化
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //添加输入输出
    if (![self.captureSession canAddInput:input]) return;
        [self.captureSession addInput:input];
    if (![self.captureSession canAddOutput:self.captureOutput]) return;
        [self.captureSession addOutput:self.captureOutput];
    //添加显示图层
    self.previewLayer.frame = self.photoView.frame;
    [self.photoView.layer addSublayer:self.previewLayer];
    //判断是否在运行中
    if ([self.captureSession isRunning]) return;
    [self.captureSession startRunning];

}

//设置输出图片格式
- (void)handleAI {
    
    AVCapturePhotoSettings *photoSetting = [[AVCapturePhotoSettings alloc] init];
    
    photoSetting.previewPhotoFormat = @{(id)kCVPixelBufferPixelFormatTypeKey:photoSetting.availablePreviewPhotoPixelFormatTypes.firstObject,
                                        (id)kCVPixelBufferWidthKey:@(160),
                                        (id)kCVPixelBufferHeightKey:@(160)};
    //调用输出
    [self.captureOutput capturePhotoWithSettings:photoSetting delegate:self];
}


#pragma mark --------- AVCapturePhotoCaptureDelegate
//完成处理的图片
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (!error) {
        [self predictResultWithImage:[UIImage imageWithData:photo.fileDataRepresentation]];
    }
}

/**
 开始预测

 @param image <#image description#>
 */
- (void)predictResultWithImage:(UIImage *)image {
    
    NSData *data = UIImagePNGRepresentation(image);
    //拿到图片先进行保存到本地
    NSURL *imageUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/image.png"]];
    [data writeToURL:imageUrl atomically:YES];
    //初始化模型
    VNCoreMLModel *model = [VNCoreMLModel modelForMLModel:[[VGG16 alloc]init].model error:nil];
    //创建请求 在闭包里面回调结果 输出预测结果
    VNCoreMLRequest *request = [[VNCoreMLRequest alloc]initWithModel:model completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSString *bestPrediction = @"";
        float confidence = 0;
        
        for (VNClassificationObservation *observation in request.results) {
            //获取准确度最高的哪一个数据进行最后的输出
            if (observation.confidence > confidence) {
                
                confidence = observation.confidence;
                bestPrediction = observation.identifier;
            }
        }
        
        [self.restult setTitle:bestPrediction forState:UIControlStateNormal];
        NSLog(@"%@",bestPrediction);
    }];
    
    //这里的执行先去那到要处理的数据 可以是图片路径可以是缓冲区 可以是二进制数据流  也可以是处理过的数据 cgimag ciimage dengdeng
    //opetons 当你要处理一些复杂的数据 相机矩阵 或者是 ciimag 这些需要上下文的时候可以来设置  或者系统默认设置来帮你完成更多的操作
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc]initWithURL:imageUrl options:@{}];
    //执行这个请求 异步处理
    [handler performRequests:@[request] error:nil];
    
    
}


#pragma mark --------- 懒加载

- (AVCaptureVideoPreviewLayer *)previewLayer {
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (AVCapturePhotoOutput *)captureOutput {
    if (!_captureOutput) {
        _captureOutput = [[AVCapturePhotoOutput alloc]init];
    }
    return _captureOutput;
}

- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        _captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    return _captureSession;
}

- (UIView *)photoView {
    if (!_photoView) {
        _photoView = [[UIView alloc] init];
        _photoView.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 60);
    }
    return _photoView;
}

- (UIButton *)restult {
    if (!_restult) {
        _restult = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_restult setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_restult setTitle:@"点击" forState:UIControlStateNormal];
        [_restult addTarget:self action:@selector(handleAI) forControlEvents:UIControlEventTouchUpInside];
        
        _restult.titleLabel.font = [UIFont systemFontOfSize:15];
        _restult.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - 60, [[UIScreen mainScreen] bounds].size.width,60);
    }
    return _restult;
}

@end
