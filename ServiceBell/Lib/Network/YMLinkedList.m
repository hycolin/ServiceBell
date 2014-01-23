//
//  YMLinkedList.m
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import "YMLinkedList.h"


@implementation YMLinkedList

- (id)init {
	if(self = [super init]) {
		head = [[YMLinkedListNode alloc] init];
		head->next = head->prev = head;
	}
	return self;
}

- (YMLinkedListNode *)first {
	YMLinkedListNode *node = head->next;
	if(node == head)
		return nil;
	return node;
}

- (YMLinkedListNode *)last {
	YMLinkedListNode *node = head->prev;
	if(node == head)
		return nil;
	return node;
}

- (YMLinkedListNode *)addFirst:(YMLinkedListNode *)node {
	node->next = head->next;
	node->prev = head;
	node->prev->next = node;
	node->next->prev = node;
	return node;
}

- (YMLinkedListNode *)addLast:(YMLinkedListNode *)node {
	node->next = head;
	node->prev = head->prev;
	node->prev->next = node;
	node->next->prev = node;
	return node;
}

- (void)clear {
	YMLinkedListNode *node = [self last];
	while (node != nil) {
		[node remove];
		node = [self last];
	}
	head->next = head->prev = head;
}

- (void)dealloc {
	[head release];
	[super dealloc];
}

@end
