//
//  ViewController.m
//  MLStudy2
//
//  Created by 徐振 on 2017/11/29.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>
#import "Flowers.h"
#import "Inceptionv3.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    NSURL *imageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"puppy2" ofType:@"jpg"]];
    
    Inceptionv3 *model = [[Inceptionv3 alloc]init];
    VNCoreMLModel *flowersModel = [VNCoreMLModel modelForMLModel:model.model error:nil];
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc]initWithURL:imageURL options:@{}];
    
    VNCoreMLRequest *requests = [[VNCoreMLRequest alloc]initWithModel:flowersModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSString *result = nil;
        float bestConfidence  = 0.0;
        if (request.results.count > 0) {
            for (VNClassificationObservation *classification  in request.results) {
                if (bestConfidence < classification.confidence) {
                    result = classification.identifier;
                    bestConfidence = classification.confidence;
                }
            }
            NSLog(@"2预测的结果是%@----可信度是多少呢%f",result,bestConfidence);
        }
    }];
    
    [handler performRequests:@[requests] error:nil];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)myResultsMethodWithReques:(VNRequest *)reques error:(NSError *)error {
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
