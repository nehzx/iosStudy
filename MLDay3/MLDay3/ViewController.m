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
 <#Description#>
 */
@property (nonatomic, strong)AVCaptureSession * captureSession;
/**
 <#Description#>
 */
@property (nonatomic, strong)AVCapturePhotoOutput * captureOutput;
/**
 <#Description#>
 */
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * previewLayer;
/**
 将要处理的图片
 */
@property (nonatomic, strong)UIImage * imageToAnalyze;
/**
 <#Description#>
 */
@property (nonatomic, strong)AVSpeechSynthesizer * synthe;
/**
 <#Description#>
 */
@property (nonatomic, strong)AVSpeechUtterance * utterance;
/**
 之前的预测
 */
@property (nonatomic, copy)NSString *previousPrediction;


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
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    if (![self.captureSession canAddInput:input]) return;
        [self.captureSession addInput:input];
    if (![self.captureSession canAddOutput:self.captureOutput]) return;
        [self.captureSession addOutput:self.captureOutput];
    
    self.previewLayer.frame = self.photoView.frame;
    [self.photoView.layer addSublayer:self.previewLayer];
    
//    if (![self.captureSession isRunning]) return;
    [self.captureSession startRunning];

}


- (void)handleAI {
    
    AVCapturePhotoSettings *photoSetting = [[AVCapturePhotoSettings alloc] init];
    
    photoSetting.previewPhotoFormat = @{(id)kCVPixelBufferPixelFormatTypeKey:photoSetting.availablePreviewPhotoPixelFormatTypes.firstObject,
                                        (id)kCVPixelBufferWidthKey:@(160),
                                        (id)kCVPixelBufferHeightKey:@(160)};
    [self.captureOutput capturePhotoWithSettings:photoSetting delegate:self];
}


#pragma mark --------- AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error {
    if (!error) {
        [self predictResultWithImage:[UIImage imageWithData:photo.fileDataRepresentation]];
    }
}

- (void)predictResultWithImage:(UIImage *)image {
    
    NSData *data = UIImagePNGRepresentation(image);
    NSURL *imageUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/image.png"]];
    [data writeToURL:imageUrl atomically:YES];
    
    VNCoreMLModel *model = [VNCoreMLModel modelForMLModel:[[VGG16 alloc]init].model error:nil];
    
    VNCoreMLRequest *request = [[VNCoreMLRequest alloc]initWithModel:model completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSString *bestPrediction = @"";
        float confidence = 0;
        
        for (VNClassificationObservation *observation in request.results) {
            if (observation.confidence > confidence) {
                
                confidence = observation.confidence;
                bestPrediction = observation.identifier;
            }
        }
        
        [self.restult setTitle:bestPrediction forState:UIControlStateNormal];
        NSLog(@"%@",bestPrediction);
    }];
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc]initWithURL:imageUrl options:@{}];
    
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
