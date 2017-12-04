//
//  ViewController.m
//  MLDay5
//
//  Created by 徐振 on 2017/12/3.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"16-101819_2092" ofType:@"jpg"];
    UIImageView *imageview = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:path]];
    [self.view addSubview:imageview];
    
    
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    
    VNImageRequestHandler *headler = [[VNImageRequestHandler alloc]initWithURL:url options:@{}];
    
    VNDetectTextRectanglesRequest *request = [[VNDetectTextRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        if (request.results) {
            
            for (VNTextObservation *observation in request.results) {
                CGFloat width = observation.boundingBox.size.width * imageview.bounds.size.width;
                CGFloat height = observation.boundingBox.size.height * imageview.bounds.size.height;
                CGFloat x = observation.boundingBox.origin.x * imageview.frame.size.width;
                CGFloat y = fabs((observation.boundingBox.origin.y * imageview.bounds.size.height) - imageview.bounds.size.height) - height;
                
                CAShapeLayer *layer = [[CAShapeLayer alloc]init];
                layer.frame = CGRectMake(x, y, width, height);
                NSLog(@"%@",NSStringFromCGPoint(layer.frame.origin));
                layer.borderColor = [UIColor redColor].CGColor;
                layer.borderWidth = 2;
                [imageview.layer addSublayer:layer];
                
                for (VNRectangleObservation *obs in observation.characterBoxes) {
//                    NSLog(@"topLeft%@",NSStringFromCGPoint(obs.topLeft));
//                    NSLog(@"topRight%@",NSStringFromCGPoint(obs.topRight));
//                    NSLog(@"bottomLeft%@",NSStringFromCGPoint(obs.bottomLeft));
//                    NSLog(@"bottomRight%@",NSStringFromCGPoint(obs.bottomRight));
//
//                    NSLog(@"%@",NSStringFromCGRect(obs.boundingBox));
//                    NSLog(@"----------------------,%zd",observation.characterBoxes.count);
                }
                
            }
        }
    }];
    
    request.reportCharacterBoxes = YES;
    [headler performRequests:@[request] error:nil];
}

- (CGPoint)observationWithPoint:(CGPoint)observationPoint ViewBound:(CGRect)viewBound {
    CGFloat x = observationPoint.x * viewBound.size.width;
    
    CGFloat y = fabs((observationPoint.y * viewBound.size.height) - viewBound.size.height);
    return CGPointMake(x, y);
    
}



@end
