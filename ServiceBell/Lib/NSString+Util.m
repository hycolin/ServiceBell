//
//  NSString+Util.m
//  EDrivel
//
//  Created by chen wang on 11-12-12.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "NSString+Util.h"
#import "base64.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Escape)

- (NSString *)stringByAddingPercentEscapesUsingEncodingExt:(NSStringEncoding)enc {
	
	NSString * newString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																			   NULL,
																			   (CFStringRef)self,
																			   NULL,
																			   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																			   CFStringConvertNSStringEncodingToEncoding(enc));
	return [newString autorelease];
}

@end

@implementation NSString (NSString_Utility)
- (NSData *)base64Data {
	Byte inputData[[self lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];//prepare a Byte[]
	[[self dataUsingEncoding:NSUTF8StringEncoding] getBytes:inputData];//get the pointer of the data
	size_t inputDataSize = (size_t)[self length];
	size_t outputDataSize = EstimateBas64DecodedDataSize(inputDataSize);//calculate the decoded data size
	Byte outputData[outputDataSize];//prepare a Byte[] for the decoded data
	Base64DecodeData(inputData, inputDataSize, outputData, &outputDataSize);//decode the data
	return [[[NSData alloc] initWithBytes:outputData length:outputDataSize] autorelease];//create a NSData object from the decoded data
}
@end


@implementation NSString (NSString_MD5)

- (NSString *)md5 {
    unsigned char digest[16];
    NSData *data = [self dataUsingEncoding:NSASCIIStringEncoding];
    CC_MD5([data bytes], [data length], digest);
    
    return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
              digest[0], digest[1], 
              digest[2], digest[3],
              digest[4], digest[5],
              digest[6], digest[7],
              digest[8], digest[9],
              digest[10], digest[11],
              digest[12], digest[13],
              digest[14], digest[15]];
}

@end