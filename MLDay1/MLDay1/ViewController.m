//
//  ViewController.m
//  MLDay1
//
//  Created by 徐振 on 2017/11/28.
//  Copyright © 2017年 xuzhen. All rights reserved.
//

#import "ViewController.h"
#import "Resnet50.h"
@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;

/**
 模型
 */
@property (nonatomic, strong)Resnet50 * resnet;

/**
 结果
 */
@property (nonatomic, strong)ARHitTestResult * hitTestResult;

/**
 分析结果
 */
@property (nonatomic, strong)NSMutableArray <VNRequest*> * visionRequests;
@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the view's delegate
    self.sceneView.delegate = self;
    
    // Show statistics such as fps and timing information
    self.sceneView.showsStatistics = YES;
    
    // Set the scene to the view
    self.sceneView.scene = [[SCNScene alloc] init];
    
    
    [self regiterGestureRecognizers];
    //创建一个手势
}

- (void)regiterGestureRecognizers {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesWith:)];
    [self.view addGestureRecognizer:tap];
}

- (void)tapGesWith:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = self.sceneView.center;
    //获取图片
    ARFrame *currentFrame = self.sceneView.session.currentFrame;
    //识别物体
    NSArray *hitTestResults = [self.sceneView hitTest:touchPoint types:ARHitTestResultTypeFeaturePoint];
    if (hitTestResults.count) {
        self.hitTestResult = hitTestResults.firstObject;
    }
    [self perfomVisionRequestWithPixelBuffer:currentFrame.capturedImage];
}

- (void)displayPredictionsWithText:(NSString *)text {
    SCNNode *node = [self createTextWith:text];
    
    
    node.position = SCNVector3Make(self.hitTestResult.worldTransform.columns[3].x,
                                   self.hitTestResult.worldTransform.columns[3].y,
                                self.hitTestResult.worldTransform.columns[3].z);
    [self.sceneView.scene.rootNode addChildNode:node];
}

- (SCNNode *)createTextWith:(NSString *)text {
    
    SCNNode *parentNode = [[SCNNode alloc]init];
    //创建一个球
    SCNSphere *sphere = [SCNSphere sphereWithRadius:0.1];
    SCNMaterial *sphereMaterial = [[SCNMaterial alloc]init];
    sphereMaterial.diffuse.contents = [UIColor yellowColor];
    sphere.firstMaterial = sphereMaterial;
    SCNNode *sphereNode = [SCNNode nodeWithGeometry:sphere];
    // 创建一个文字
    SCNText *textGeo = [SCNText textWithString:text extrusionDepth:0];
    textGeo.alignmentMode = kCAAlignmentCenter;
    textGeo.firstMaterial.diffuse.contents = [UIColor yellowColor];
    textGeo.firstMaterial.specular.contents = [UIColor whiteColor];
    textGeo.firstMaterial.doubleSided = YES;
    textGeo.font = [UIFont systemFontOfSize:0.15];
    SCNNode *textNode = [SCNNode nodeWithGeometry:textGeo];
    textNode.scale = SCNVector3Make(0.2, 0.2, - 0.2);
    //添加到这个几点中
    [parentNode addChildNode:sphereNode];
    [parentNode addChildNode:textNode];
    return parentNode;
}


- (void)perfomVisionRequestWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    //加载 model
    NSError *error;
    VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:self.resnet.model error:&error];
    VNCoreMLRequest *request = [[VNCoreMLRequest alloc]initWithModel:visionModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        if (request.results.count > 0) {
            VNClassificationObservation *obrervations = request.results.firstObject;
            
            
            
            NSLog(@"打印结果%@--几率%f",obrervations.identifier, obrervations.confidence);
            dispatch_sync(dispatch_get_main_queue(), ^{
                [ self displayPredictionsWithText:obrervations.identifier];
            });
        }
    }];
    
    
    request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
    [self.visionRequests addObject:request];
    
    
    //翻转结果
    VNImageRequestHandler * requesetHandler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:pixelBuffer orientation:kCGImagePropertyOrientationUpMirrored options:@{}];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //处理结果
        [requesetHandler performRequests:self.visionRequests error:nil];
    });

    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

    // Run the view's session
    [self.sceneView.session runWithConfiguration:configuration];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

- (Resnet50 *)resnet {
    if (!_resnet) {
        _resnet = [[Resnet50 alloc]init];
    }
    return _resnet;
}


- (NSMutableArray<VNRequest *> *)visionRequests {
    if (!_visionRequests) {
        _visionRequests = [NSMutableArray array];
    }
    return _visionRequests;
}

@end
