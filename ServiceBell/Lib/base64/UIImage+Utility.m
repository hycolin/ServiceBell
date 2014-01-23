//
//  UIImage+Utility.m
//  CardBump
//
//  Created by ZhouHui on 11-8-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIImage+Utility.h"
#import "NSData+Base64.h"

@implementation UIImage (Utility)

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSString *)base64String {
	NSData *pngData = UIImagePNGRepresentation(self);
	if (pngData) {
		return [pngData base64EncodedString];
	}
	NSData *jpegData = UIImageJPEGRepresentation(self, 1.0);
	if (jpegData) {
		return [jpegData base64EncodedString];
	}
	return nil;
}

#define MAX_IMAGEPIX 100.0

- (UIImage *)compressedImage:(CGSize)size {
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
	
	if (width <= size.width && height<= size.height) {
		// no need to compress.
		return self;
	}
	
	if (width == 0 || height == 0) {
		// void zero exception
		return self;
	}
	
    UIImage *newImage = nil;
//	CGFloat widthFactor = size.width / width;
//	CGFloat heightFactor = size.height / height;
//	CGFloat scaleFactor = 0.0;
//	if (widthFactor > heightFactor)
//		scaleFactor = heightFactor; // scale to fit height
//	else
//		scaleFactor = widthFactor; // scale to fit width
//	CGFloat scaledWidth  = width * scaleFactor;
//	CGFloat scaledHeight = height * scaleFactor;
	
    CGFloat scaledWidth  = size.width;
    CGFloat scaledHeight = size.height;
    
	CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
	
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)compressedImage {
	return [self compressedImage:CGSizeMake(MAX_IMAGEPIX, MAX_IMAGEPIX)];
}

- (NSData *)compressedData:(CGFloat)compressionQuality {
	assert(compressionQuality<=1.0 && compressionQuality >=0);
	return UIImageJPEGRepresentation(self, compressionQuality);
}

- (CGFloat)compressionQuality {
	NSData *data = UIImageJPEGRepresentation(self, 1.0);
	NSUInteger dataLength = [data length];
	if(dataLength>50000.0) {
		return 1.0-50000.0/dataLength;
	} else {
		return 1.0;
	}
}

- (NSData *)compressedData {
	CGFloat quality = [self compressionQuality];
	return [self compressedData:quality];
}

@end
