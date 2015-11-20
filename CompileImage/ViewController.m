//
//  ViewController.m
//  CompileImage
//
//  Created by lvlin on 14/12/23.
//  Copyright (c) 2014年 融信信息. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Rotate_Flip.h"

#define IMAGEWIDTH  240.f
#define IMAGEHEIGHT 240.f

#define HDResolution 640.f

#define M_PI     3.14159265358979323846264338327950288

@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIButton *openButton;
@property (nonatomic, strong) IBOutlet UIButton *endButton;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UIImageView *clickImageView;

@property (nonatomic, assign) CGRect displayImageRect;
@property (nonatomic, assign) BOOL isFinish;
@property (nonatomic, assign) CGAffineTransform affineTransform;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.frame = CGRectMake(0, 42, IMAGEWIDTH, IMAGEHEIGHT);
    self.scrollView.contentSize = CGSizeMake(1000, IMAGEHEIGHT);
    
    [self showClickImageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showClickImageView
{
    self.clickImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = [UIColor colorWithRed:93/255.0f green:158/255.0f blue:236/255.0f alpha:1].CGColor;
    layer.fillColor = nil;
    layer.lineDashPattern = @[@4, @4];
    layer.path = [UIBezierPath bezierPathWithRect:self.clickImageView.bounds].CGPath;
    layer.frame = self.clickImageView.bounds;
    [self.clickImageView.layer addSublayer:layer];
    self.clickImageView.userInteractionEnabled = YES;
    [self.scrollView addSubview:self.clickImageView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoClick:)];
    [self.clickImageView addGestureRecognizer:tapGestureRecognizer];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.clickImageView addGestureRecognizer:panGestureRecognizer];
    
    UIPinchGestureRecognizer *pinGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [self.clickImageView addGestureRecognizer:pinGestureRecognizer];
    
    UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
    [self.clickImageView addGestureRecognizer:rotationGestureRecognizer];
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.clickImageView];
    
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x, recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)handlePinch:(UIPinchGestureRecognizer *)recognizer {
    
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
    self.affineTransform = recognizer.view.transform;
}

- (IBAction)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    recognizer.view.transform = CGAffineTransformRotate(recognizer.view.transform, recognizer.rotation);
    recognizer.rotation = 0;
    self.affineTransform = recognizer.view.transform;
}


- (IBAction)openPhotoClick:(id)sender
{
    UIActionSheet *myActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles: @"拍照", @"从相册选择",nil];
    
    [myActionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        NSLog(@"取消");
        return;
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
            
        case 1:  //打开本地相册
            [self selectPhoto];
            break;
    }
}


- (IBAction)sureButtonClick:(id)sender
{
    UIImage *okimage = [self combineImage:self.clickImageView.image];
    
    CGRect imageRect = self.imageView.frame;
    imageRect.size = self.displayImageRect.size;
    self.imageView.frame = imageRect;
    self.imageView.image = okimage;
    
    self.clickImageView.image = nil;
    self.clickImageView.transform = CGAffineTransformIdentity;
    
    CGRect clickImageRect = self.clickImageView.frame;
    clickImageRect.origin.x = self.clickImageView.frame.origin.x + self.clickImageView.frame.size.width;
    clickImageRect.origin.y = self.imageView.frame.origin.y;
    self.clickImageView.frame = clickImageRect;
    
    self.isFinish = YES;
}

- (IBAction)endButtonClick:(id)sender
{
    if (self.imageView.image == nil) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还未选择图片" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if (!self.isFinish) {
        [self sureButtonClick:nil];
    }
    
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil,nil,nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"图片已保存到相册" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)cleanButtonClick:(id)sender
{
    self.imageView.image = nil;
    self.imageView.frame = CGRectMake(0, 42, IMAGEWIDTH, IMAGEHEIGHT);
    self.clickImageView.transform = CGAffineTransformIdentity;
    self.clickImageView.frame = self.imageView.frame;
    self.clickImageView.image = nil;
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
}

#pragma mark - 照片处理 -

- (BOOL)shouldAutorotate {
    return YES;
}

//开始拍照
-(void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.modalPresentationStyle = UIModalPresentationCurrentContext;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if ([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
            [picker setShowsCameraControls:YES];
            [self presentViewController:picker animated:YES completion:^{
                [picker setShowsCameraControls:YES];
            }];
        } else {
            [picker setShowsCameraControls:YES];
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }else
    {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)selectPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

//当选择一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.isFinish = NO;
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        
        NSData *tempData = UIImagePNGRepresentation(image);
        
        UIImage *initialImage = [UIImage imageWithCGImage:[UIImage imageWithData:tempData].CGImage
                                                    scale:image.scale
                                              orientation:image.imageOrientation];
        
        NSData *data;
        if (UIImagePNGRepresentation(initialImage) == nil)
        {
            data = UIImageJPEGRepresentation(initialImage, 0.2);
        }
        else
        {
            data = UIImagePNGRepresentation(initialImage);
        }
        
//        UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil);
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES
                                   completion:^{
                                       
                                       [self displayImage:image];
                                   }];
        //上传图片 发送请求 data
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   
                               }];
}

- (void)displayImage:(UIImage *)image
{
    self.clickImageView.image = image;
    self.clickImageView.alpha = 0.7;
}


- (UIImage *)combineImage :(UIImage*)rightImage {
    
    CGFloat degree = [(NSNumber *)[self.clickImageView valueForKeyPath:@"layer.transform.rotation.z"] floatValue];
    CGFloat scale = [[self.clickImageView valueForKeyPath:@"layer.transform.scale"] floatValue];
    
    CGSize originSize = rightImage.size;
    rightImage = [rightImage rotateImageWithRadian:degree cropMode:enSvCropExpand];
    
    CGSize rotateSize = CGSizeZero;
    if (scale >= 1) {
        rotateSize = rightImage.size;
    } else {
        rotateSize = CGSizeMake(originSize.width, originSize.height);
    }
    rightImage = [rightImage resizeImageToSize:rotateSize resizeMode:enSvResizeScale];
    
    CGFloat displayWidth = 0;
    CGFloat HDWidth = 0;
    
    if (self.imageView.image == nil) {
        displayWidth = IMAGEWIDTH;
        HDWidth = HDResolution;
    }else{
        displayWidth = self.clickImageView.frame.origin.x + self.clickImageView.frame.size.width;
        HDWidth = displayWidth * (HDResolution / IMAGEWIDTH);
    }
    
    CGSize scrollViewContentSize = CGSizeMake(displayWidth + IMAGEWIDTH, IMAGEHEIGHT);
    self.scrollView.contentSize = scrollViewContentSize;
    
    self.displayImageRect = CGRectMake(self.clickImageView.frame.origin.x, self.clickImageView.frame.origin.y - 42, displayWidth, IMAGEHEIGHT);
    
    CGSize offScreenSize = CGSizeMake(HDWidth, HDResolution);
    UIGraphicsBeginImageContext(offScreenSize);
    
    CGRect rect = CGRectMake(0, 0, self.imageView.image.size.width, HDResolution);
    [self.imageView.image drawInRect:rect];
    
    rect.origin.x = self.clickImageView.frame.origin.x * (HDResolution / IMAGEWIDTH);
    rect.origin.y = (self.clickImageView.frame.origin.y - 42) * (HDResolution / IMAGEWIDTH);
    rect.size.width = rotateSize.width;
    rect.size.height = rotateSize.height;
    
    [rightImage drawInRect:rect];

    
    UIImage *imagez = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imagez;
}

@end
