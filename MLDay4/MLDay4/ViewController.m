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
    
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    
    VNDetectFaceRectanglesRequest *request = [[VNDetectFaceRectanglesRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.restultLabel.text = [NSString stringWithFormat:@"找到了%zd张脸",request.results.count];
        
        
    }];
    
    [handler performRequests:@[request] error:nil];
}



@end
