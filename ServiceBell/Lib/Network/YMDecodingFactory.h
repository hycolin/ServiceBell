//
//  EDDecodingFactory.h
//  EDrivel
//
//  Created by chen wang on 11-11-20.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMDecodingProtocol.h"

@interface YMDecodingFactory : NSObject {
    Class _class;
}
- (id)initWithClass:(Class)class;
- (id<YMDecodingProtocol>)createInstance;

@end
