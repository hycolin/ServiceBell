//
//  YMMemCache.h
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLinkedList.h"


@interface YMMemCache : NSObject {
	NSMutableDictionary *dict;
	YMLinkedList *accessList;
	YMLinkedList *ageList;
	
	size_t maxCacheSize;
	size_t cacheSize;
	
	time_t maxLifetime;
	
	volatile int32_t cacheHits;
	volatile int32_t cacheMisses;
}

- (id)initWithMaxSize:(size_t)ms maxLifetime:(time_t)ml;

- (id)putObject:(id)obj forKey:(id)key;
- (id)putObject:(id)obj forKey:(id)key timestamp:(time_t)time;
- (id)objectForKey:(id)key;
- (id)removeObjectForKey:(id)key;
- (void)clear;

- (NSInteger)count;
- (BOOL)isEmpty;

- (int32_t)cacheHits;
- (int32_t)cacheMisses;

- (size_t)maxCacheSize;
- (size_t)cacheSize;
- (void)setCacheSize:(size_t)size;

- (time_t)maxLifetime;
- (void)setMaxLifetime:(time_t)lifetime;

- (size_t)sizeOf:(id)obj;

- (void)cleanExpired;
- (void)cleanFull;

@end
