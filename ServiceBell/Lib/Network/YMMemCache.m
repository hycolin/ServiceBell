//
//  YMMemCache.m
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import "YMMemCache.h"


#define kFullUseage			1.0
#define kOkayUseage			0.85
#define kMaxSingleUseage	0.4


@interface YMVCont : NSObject
{
	id obj;
	@public size_t size;
	YMLinkedListNode *accessNode;
	YMLinkedListNode *ageNode;
	@public NSInteger hitCount;
}

@property (nonatomic, retain) id obj;
@property (nonatomic, retain) YMLinkedListNode *accessNode;
@property (nonatomic, retain) YMLinkedListNode *ageNode;

- (id)initWithObj:(id)o size:(size_t)s;

@end


@implementation YMVCont

@synthesize obj;
@synthesize accessNode;
@synthesize ageNode;

- (id)initWithObj:(id)o size:(size_t)s {
	if(self = [super init]) {
		obj = [o retain];
		size = s;
	}
	return self;
}

- (void)dealloc {
	[obj release];
	[accessNode release];
	[ageNode release];
	[super dealloc];
}

@end




@implementation YMMemCache

- (id)init {
	[self release];
	return nil;
}

- (id)initWithMaxSize:(size_t)ms maxLifetime:(time_t)ml {
	if(self = [super init]) {
		dict = [[NSMutableDictionary alloc] initWithCapacity:64];
		accessList = [[YMLinkedList alloc] init];
		ageList = [[YMLinkedList alloc] init];
		maxCacheSize = ms;
		maxLifetime = ml;
	}
	return self;
}

- (id)putObject:(id)obj forKey:(id)key {
	return [self putObject:obj forKey:key timestamp:time(0)];
}
- (id)putObject:(id)obj forKey:(id)key timestamp:(time_t)time {
	size_t valSize = [self sizeOf:obj];
	size_t oldSize = 0;
	if(maxCacheSize > 0 && valSize > maxCacheSize * kMaxSingleUseage) {
		// 如果对象尺寸过大（size>maxCacheSize*kMaxSingleUseage）则不存入memcache，并把memcache中原来的数据清除。
		// 这里代码永远不会调用（因为对象的size都是1）
		YMVCont *removed = [dict objectForKey:key];
		if(removed) {
			id obj = [removed.obj retain];
			[dict removeObjectForKey:key];
			return [obj autorelease];
		} else {
			return nil;
		}
	}
	YMVCont *vc = [[YMVCont alloc] initWithObj:obj size:valSize];
	YMVCont *removed = [[dict objectForKey:key] retain];
	id removedObj = nil;
	[dict setObject:vc forKey:key];
	[vc release];
	YMLinkedListNode *accessNode = nil;
	YMLinkedListNode *ageNode = nil;
	if(removed) {
		[removed.accessNode remove];
		accessNode = [removed.accessNode retain];
		removed.accessNode = nil;
		[removed.ageNode remove];
		ageNode = [removed.ageNode retain];
		removed.ageNode = nil;
		oldSize = removed->size;
		cacheSize -= oldSize;
		removedObj = [removed.obj retain];
		[removed release];
		removed = nil;
	}
	cacheSize += valSize;
	
	if(!accessNode)
		accessNode = [[YMLinkedListNode alloc] init];
	accessNode.obj = key;
	accessNode->time = time;
	[accessList addFirst:accessNode];
	vc.accessNode = accessNode;
	[accessNode release];
	
	if(!ageNode)
		ageNode = [[YMLinkedListNode alloc] init];
	ageNode.obj = key;
	ageNode->time = time;
	[ageList addFirst:ageNode];
	vc.ageNode = ageNode;
	[ageNode release];
	
	if(oldSize < valSize)
		[self cleanFull];
	
	return [removedObj autorelease];
}

- (id)objectForKey:(id)key {
	[self cleanExpired];
	YMVCont *vc = [dict objectForKey:key];
	if(!vc) {
		++cacheMisses;
		return nil;
	} else {
		++cacheHits;
		++(vc->hitCount);
		vc.accessNode->time = time(0);
		
		[vc.accessNode remove];
		[accessList addFirst:vc.accessNode];
		
		return vc.obj;
	}
}

- (id)removeObjectForKey:(id)key {
	YMVCont *vc = [dict objectForKey:key];
	if(!vc)
		return nil;
	
	[vc.accessNode remove];
	vc.accessNode = nil;
	[vc.ageNode remove];
	vc.ageNode = nil;
	cacheSize -= vc->size;
	
	id obj = [vc.obj retain];
	[dict removeObjectForKey:key];
	
	return [obj autorelease];
}

- (void)clear {
	[accessList clear];
	[ageList clear];
	[dict removeAllObjects];
	cacheSize = 0;
}


- (NSInteger)count {
	return cacheSize;
}

- (BOOL)isEmpty {
	return cacheSize == 0;
}


- (int32_t)cacheHits {
	return cacheHits;
}

- (int32_t)cacheMisses {
	return cacheMisses;
}


- (size_t)maxCacheSize {
	return maxCacheSize;
}

- (size_t)cacheSize {
	return cacheSize;
}

- (void)setCacheSize:(size_t)size {
	cacheSize = size;
	[self cleanFull];
}


- (time_t)maxLifetime {
	return maxLifetime;
}

- (void)setMaxLifetime:(time_t)lifetime {
	maxLifetime = lifetime;
	[self cleanExpired];
}


- (size_t)sizeOf:(id)obj {
	return 1;
}


- (void)cleanExpired {
	if(maxLifetime <= 0)
		return;
	
	time_t expireTime = time(0) - maxLifetime;
	YMLinkedListNode *node;
	while((node = [ageList last])) {
		if(expireTime > node->time) {
			[self removeObjectForKey:node.obj];
		} else {
			break;
		}
	}
}

- (void)cleanFull {
	if(maxCacheSize <= 0)
		return;
	
	if(cacheSize >= maxCacheSize * kFullUseage) {
		[self cleanExpired];
		size_t okaySize = (size_t)(maxCacheSize * kOkayUseage);
		while(cacheSize > okaySize) {
			[self removeObjectForKey:[accessList last].obj];
		}
	}
}

- (void)dealloc {
	[self clear];
	[accessList release];
	[ageList release];
	[dict release];
	[super dealloc];
}

@end
