//
//  EDRequest.m
//  EDrivel
//
//  Created by chen wang on 11-11-20.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "YMRequest.h"
#import "YMDecodingProtocol.h"
#import "JSON.h"
#import "StatusMessage.h"

static YMImageCache *globalImageCache;

@implementation YMRequest

@synthesize result = _result;
@synthesize requestDelegate = _requestDelegate;
@synthesize decodeingFactory = _decodeingFactory;

+ (void)initialize {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    globalImageCache = [[YMImageCache alloc] initWithFile:[path stringByAppendingPathComponent:@"photo.db"] maxCount:0xFF];
}

+ (YMImageCache *)imageCache {
    return globalImageCache;
}

- (void)setRequestDelegate:(id<YMRequestDelegate>)requestDelegate {
    [_requestDelegate autorelease];
    _requestDelegate = [requestDelegate retain];
    self.delegate = self;
}

- (void)requestFinished:(ASIHTTPRequest *)aRequest {
    dlog(@"url:%@", aRequest.url);
    NSString *responseString = aRequest.responseString; 
    
    id jsonValue = [responseString JSONValue];
    if (jsonValue) {
        NSDictionary *dataDict = jsonValue;
        if ([dataDict objectForKey:@"success"] != nil && [dataDict objectForKey:@"errorcode"] != nil) {
            self.result = [[[StatusMessage alloc] initWithData:dataDict] autorelease]; 
            [_requestDelegate requestFailed:self];
        } else {
            if (_decodeingFactory) {
                id<YMDecodingProtocol> decodingData = [[_decodeingFactory createInstance] initWithData:dataDict];
                self.result = decodingData;  
            } else {
                self.result = dataDict;
            }
        }
        [_requestDelegate requestFinished:self];        
    } else {
        self.result = [[[StatusMessage alloc] initWithErrorcode:1000 errorInfo:@"服务不可用"] autorelease];
        [_requestDelegate requestFailed:self];                    
    }
    if (jsonValue) {
        dlog(@"result:%@", self.result);
    } else {
        dlog(@"result:%@", responseString);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)aRequest {
    dlog(@"url:%@", aRequest.url);
    dlog(@"url:%@ \nrequestFailed:%@",aRequest.url, aRequest.error);
    [_requestDelegate requestFailed:self];
}

- (void)dealloc {
    [self cancel];
    self.delegate = nil;
    
    [_result release];
    [_requestDelegate release];
    [_decodeingFactory release];
    
    [super dealloc];
}

@end
