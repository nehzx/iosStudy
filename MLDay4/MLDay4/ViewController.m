//
//  ViewController.m
//  MLDay4
//
//  Created by 徐振 on 2017/12/2.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <Vision/Vision.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *restultLabel;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (IBAction)selectImage:(UIButton *)sender {

    [self choosePhoto];
}
- (void)choosePhoto {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark --------- UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//    self.button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self.button setBackgroundImage:image forState:UIControlStateNormal];
    [self processImage:image];
    
}


- (void)processImage:(UIImage *)image {
//    VNCoreMLModel *model = [VNCoreMLModel modelForMLModel:<#(nonnull MLModel *)#> error:<#(NSError * _Nullable __autoreleasing * _Nullable)#>]
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];

    
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.restultLabel.text = [NSString stringWithFormat:@"找到了%zd张脸",request.results.count];
        for (VNFaceObservation *observasion in request.results) {
            [self addFaceContour:observasion view:self.button];
        }
        
    }];
    
    [handler performRequests:@[request] error:nil];
}


- (void)addFaceContour:(VNFaceObservation *)observasion view:(UIView *)view {
    
    [view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    
    CGRect faceBox = observasion.boundingBox;
    CGRect viewBox = view.frame;
    
    CGFloat width = faceBox.size.width * viewBox.size.width;
    CGFloat height = faceBox.size.height * viewBox.size.height;
    CGFloat x = faceBox.origin.x *viewBox.size.width;
    CGFloat y = fabs((faceBox.origin.y *viewBox.size.height) - viewBox.size.height) - height;
    UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
    subView.layer.masksToBounds = YES;
    subView.layer.borderColor = [UIColor yellowColor].CGColor;
    subView.layer.borderWidth = 3;
    subView.layer.cornerRadius = 5;
    subView.tag = 100;
    [view addSubview:subView];
    
    
    
    
    
    
}



@end
