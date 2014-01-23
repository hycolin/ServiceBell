//
//  UIImage+Utility.h
//  CardBump
//
//  Created by ZhouHui on 11-8-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

- (UIImage *)scaleToSize:(CGSize)size;
- (NSString *)base64String;

- (UIImage *)compressedImage;
- (UIImage *)compressedImage:(CGSize)size;
- (CGFloat)compressionQuality;
- (NSData *)compressedData;
- (NSData *)compressedData:(CGFloat)compressionQuality;

@end
