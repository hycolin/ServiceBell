//
//  ECommon.h
//  ECommon
//
//  Created by chen wang on 11-11-16.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#ifndef _ECOMMON_H_
#define _ECOMMON_H_

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "MBProgressHUD.h"
#import "NSString+Util.h"

#import "YMViewController.h"
#import "YMTableViewController.h"

#import "StatusMessage.h"
#import "YMDecodingFactory.h"
#import "YMDecodingProtocol.h"

#import "Compatible.h"

#ifdef DEBUG
#define dlog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define dlog(format, ...)
#endif

#define RELEASE_SAFELY(__POINTER) {[__POINTER release];__POINTER = nil;}

#define REMOVESUBVIEW_SAFELY(__SUBVIEW) \
{ \
[__SUBVIEW removeFromSuperview]; \
[__SUBVIEW release]; __SUBVIEW = nil; \
}
#define REQUEST_RELEASE_SAFELY(__REQUEST) \
{  \
[__REQUEST cancel]; \
__REQUEST.delegate = nil; \
__REQUEST = nil; \
}


#endif