//
//  YMLinkedListNode.m
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import "YMLinkedListNode.h"


@implementation YMLinkedListNode

@synthesize obj;

- (void)remove {
	prev->next = next;
	next->prev = prev;
}

- (void)dealloc {
	[obj release];
	[super dealloc];
}

@end
