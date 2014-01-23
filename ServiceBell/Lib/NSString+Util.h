//
//  NSString+Util.h
//  EDrivel
//
//  Created by chen wang on 11-12-12.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (Escape) 
- (NSString *)stringByAddingPercentEscapesUsingEncodingExt:(NSStringEncoding)enc;
@end

@interface NSString (NSString_Utility)
- (NSData *)base64Data;
@end

@interface NSString (NSString_MD5)
- (NSString *)md5;

@end