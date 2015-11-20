//
//  UIImage+Rotate_Flip.m
//  CompileImage
//
//  Created by lvlin on 14/12/25.
//  Copyright (c) 2014年 融信信息. All rights reserved.
//

#import "UIImage+Rotate_Flip.h"


@implementation UIImage(UIImage)

/*
 * @brief rotate image with radian
 */
- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode
{
    CGSize imgSize = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
    CGSize outputSize = imgSize;
    if (cropMode == enSvCropExpand) {
        CGRect rect = CGRectMake(0, 0, imgSize.width, imgSize.height);
        rect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeRotation(radian));
        outputSize = CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect));
    }
    
    UIGraphicsBeginImageContext(outputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, outputSize.width / 2, outputSize.height / 2);
    CGContextRotateCTM(context, radian);
    CGContextTranslateCTM(context, -imgSize.width / 2, -imgSize.height / 2);
    
    [self drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 */
- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode
{
    CGRect drawRect = [self caculateDrawRect:newSize resizeMode:resizeMode];
    
    UIGraphicsBeginImageContext(newSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, newSize.width, newSize.height));
    
    CGContextSetInterpolationQuality(context, 0.8);
    
    [self drawInRect:drawRect blendMode:kCGBlendModeNormal alpha:1];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// caculate drawrect respect to specific resize mode
- (CGRect)caculateDrawRect:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode
{
    CGRect drawRect = CGRectMake(0, 0, newSize.width, newSize.height);
    
    CGFloat imageRatio = self.size.width / self.size.height;
    CGFloat newSizeRatio = newSize.width / newSize.height;
    
    switch (resizeMode) {
        case enSvResizeScale:
        {
            // scale to fill
            break;
        }
        case enSvResizeAspectFit:                    // any remain area is white
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {        // max height is newSize.height
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            else {
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            
            break;
        }
        case enSvResizeAspectFill:
        {
            CGFloat newHeight = 0;
            CGFloat newWidth = 0;
            if (newSizeRatio >= imageRatio) {        // max height is newSize.height
                newWidth = newSize.width;
                newHeight = newWidth / imageRatio;
            }
            else {
                newHeight = newSize.height;
                newWidth = newHeight * imageRatio;
            }
            
            drawRect.size.width = newWidth;
            drawRect.size.height = newHeight;
            
            drawRect.origin.x = newSize.width / 2 - newWidth / 2;
            drawRect.origin.y = newSize.height / 2 - newHeight / 2;
            
            break;
        }
        default:
            break;
    }
    
    return drawRect;
}

@end
