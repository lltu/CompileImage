//
//  UIImage+Rotate_Flip.h
//  CompileImage
//
//  Created by lvlin on 14/12/25.
//  Copyright (c) 2014年 融信信息. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    enSvCropClip,               // the image size will be equal to orignal image, some part of image may be cliped
    enSvCropExpand,             // the image size will expand to contain the whole image, remain area will be transparent
};
typedef NSInteger SvCropMode;

enum {
    enSvResizeScale,            // image scaled to fill
    enSvResizeAspectFit,        // image scaled to fit with fixed aspect. remainder is transparent
    enSvResizeAspectFill,       // image scaled to fill with fixed aspect. some portion of content may be cliped
};
typedef NSInteger SvResizeMode;

@interface UIImage(UIImage)

- (UIImage*)rotateImageWithRadian:(CGFloat)radian cropMode:(SvCropMode)cropMode;

/*
 * @brief resizeImage
 * @param newsize the dimensions（pixel） of the output image
 */
- (UIImage*)resizeImageToSize:(CGSize)newSize resizeMode:(SvResizeMode)resizeMode;

@end
