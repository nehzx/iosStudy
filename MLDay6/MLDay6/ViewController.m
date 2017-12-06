//
//  ViewController.m
//  MLDay6
//
//  Created by 徐振 on 2017/12/4.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <Vision/Vision.h>
#import <CoreML/CoreML.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 <#Description#>
 */
@property (nonatomic, strong)AVCaptureSession * capSession;

/**
 <#Description#>
 */
@property (nonatomic, strong)AVCaptureVideoDataOutput * capOutput;

/**
 <#Description#>
 */
@property (nonatomic, strong)AVCaptureVideoPreviewLayer * videoLayer;

/**
 <#Description#>
 */
@property (nonatomic, strong)dispatch_queue_t  queue;
/**
 <#Description#>
 */
@property (nonatomic, strong)UIView  * videoView;


@property (nonatomic, copy)NSURL *movieFileUrl;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.videoView];
    [self setCapure];
}


#pragma mark --------- AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CVPixelBufferRef buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc]initWithCVPixelBuffer:buffer options:@{}];
    
    VNDetectRectanglesRequest *request = [[VNDetectRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSLog(@"0-------%@",request.results);
    }];
    [handler performRequests:@[request] error:nil];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"输出缓冲区");
    
    
    
}


- (void)detectObjectWithPixelBuffer:(CVPixelBufferRef)buffer {
    
    
}


- (CVPixelBufferRef) rotateBufferWithSampleBuffer:(CMSampleBufferRef)buffer {
    
    return nil;
}


- (void)setCapure {
    
    AVCaptureDevice *video = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:video error:nil];
    if (![self.capSession canAddInput:videoInput]) return;
    [self.capSession addInput:videoInput];
    
    AVCaptureDevice *audion = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audion error:nil];
    if (![self.capSession canAddInput:audioInput]) return;
    [self.capSession addInput:audioInput];
    if (![self.capSession canAddOutput:self.capOutput])return;
    [self.capSession addOutput:self.capOutput];
    
    self.videoLayer.frame = self.view.frame;
    [self.videoView.layer addSublayer:self.videoLayer];
    
    if (![self.capSession isRunning]) {
        [self.capSession startRunning];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    [self videoSetting];
}


- (void)videoSetting {
    
    
    [self.capOutput setSampleBufferDelegate:self queue:self.queue];
    
}

- (NSURL *)movieFileUrl {
    if (!_movieFileUrl) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
        NSString *dateStr = [formatter stringFromDate:[NSDate date]];
        NSString *path = [NSString stringWithFormat:@"%@/Documents/%@-azhen.mp3",NSHomeDirectory(),dateStr];
        _movieFileUrl = [NSURL fileURLWithPath:path];
    }
    return _movieFileUrl;
}

-(AVCaptureSession *)capSession {
    if (!_capSession) {
        _capSession = [[AVCaptureSession alloc]init];
        _capSession.sessionPreset = AVCaptureSessionPresetMedium;
    }
    return _capSession;
}

- (AVCaptureVideoDataOutput *)capOutput {
    if (!_capOutput) {
        _capOutput = [[AVCaptureVideoDataOutput alloc]init];
        
    }
    return _capOutput;
}

-(UIView *)videoView {
    if (!_videoView) {
        _videoView = [[UIView alloc]init];
        _videoView.frame = self.view.frame;
    }
    return _videoView;
}

- (AVCaptureVideoPreviewLayer *)videoLayer {
    if (!_videoLayer) {
        _videoLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.capSession];
        _videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _videoLayer;
}

-(dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("azhen_queue", NULL);
    }
    return _queue;
}

@end
