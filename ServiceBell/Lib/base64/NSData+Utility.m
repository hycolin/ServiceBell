//
//  NSData+Utility.m
//  CardBump
//
//  Created by ZhouHui on 11-9-7.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSData+Utility.h"
#import "base64.h"

@implementation NSData (NSData_Utility)

- (NSString *)base64String {
	size_t outputDataSize = EstimateBas64EncodedDataSize([self length]);
	char outputData[outputDataSize];
	Base64EncodeData([self bytes], [self length], outputData, &outputDataSize, NO);
	return [NSString stringWithUTF8String:outputData];
}

@end
