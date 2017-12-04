//
//  ViewController.m
//  MLDay4
//
//  Created by 徐振 on 2017/12/2.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import <Vision/Vision.h>
#import <CoreML/CoreML.h>
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
    VNSequenceRequestHandler *handlers = [[VNSequenceRequestHandler alloc]init];
    
    
    VNDetectFaceLandmarksRequest *request = [[VNDetectFaceLandmarksRequest alloc]initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        self.restultLabel.text = [NSString stringWithFormat:@"找到了%zd张脸",request.results.count];
        for (VNFaceObservation *observasion in request.results) {

            UIImage * newImage = [self drawOnImageWithSource:image boundingRect:observasion.boundingBox faceLandmarkRegions:[self addFaceFeatureWithObservision:observasion view:self.button]];
            
            
            [self.button setBackgroundImage:newImage forState:UIControlStateNormal];
        }
        
        
    
    }];
    
    [handlers performRequests:@[request] onCGImage:image.CGImage error:nil];
//    [handler performRequests:@[request] error:nil];
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
//    subView.layer.borderColor = [UIColor yellowColor].CGColor;
    subView.layer.borderWidth = 3;
    subView.layer.cornerRadius = 5;
    subView.tag = 100;
    [view addSubview:subView];
}

- (NSArray *)addFaceFeatureWithObservision:(VNFaceObservation *)observasion view:(UIView *)view {
    NSMutableArray *faceFeatures = [NSMutableArray array];
    VNFaceLandmarks2D * faceLandmark = observasion.landmarks;
    
    [faceFeatures addObject:faceLandmark.faceContour];
    [faceFeatures addObject:faceLandmark.leftEye];
    [faceFeatures addObject:faceLandmark.rightEye];
    [faceFeatures addObject:faceLandmark.leftEyebrow];
    [faceFeatures addObject:faceLandmark.rightEyebrow];
    [faceFeatures addObject:faceLandmark.nose];
    [faceFeatures addObject:faceLandmark.noseCrest];
    [faceFeatures addObject:faceLandmark.outerLips];
    [faceFeatures addObject:faceLandmark.innerLips];
    
    return faceFeatures;
}

- (UIImage *)drawOnImageWithSource:(UIImage *)source boundingRect:(CGRect)boundingRect faceLandmarkRegions:(NSArray <VNFaceLandmarkRegion2D *> *)faceLandmarkRegions {
    UIGraphicsBeginImageContextWithOptions(source.size, NO, 1);
    
    CGContextRef content =  UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(content, 0, source.size.height);
    CGContextScaleCTM(content, 1.0, - 1.0);
    CGContextSetBlendMode(content, kCGBlendModeColorBurn);
    CGContextSetLineJoin(content, kCGLineJoinRound);
    CGContextSetLineCap(content, kCGLineCapRound);
    CGContextSetShouldAntialias(content, true);
    CGContextSetAllowsAntialiasing(content, true);
    
    CGFloat reatWidth = source.size.width * boundingRect.size.width;
    CGFloat reatHeigth = source.size.height * boundingRect.size.height;
    
    CGRect reat = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(content, reat, source.CGImage);
    
    UIColor * fillColor = [UIColor redColor];
    
    [fillColor setFill];
    CGContextAddRect(content, CGRectMake(boundingRect.origin.x * source.size.width, boundingRect.origin.y * source.size.height, reatWidth, reatHeigth));
    
    CGContextDrawPath(content, kCGPathStroke);
    

    [fillColor setStroke];
    
    CGContextSetLineWidth(content, 10.0);
    
    for (VNFaceLandmarkRegion2D *region in faceLandmarkRegions) {

        CGPoint points[region.pointCount];
        for (int i = 0; i < region.pointCount; i ++) {
            CGPoint point = region.normalizedPoints[i];
            
            CGFloat x = boundingRect.origin.x * source.size.width + point.x * reatWidth;
            CGFloat y = boundingRect.origin.y * source.size.height + point.y * reatHeigth;
            points[i] = CGPointMake(x, y);
            
        }
        CGContextAddLines(content, points, region.pointCount);
        
        CGContextDrawPath(content, kCGPathStroke);
        
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
