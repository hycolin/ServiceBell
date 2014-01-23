//
//  YMLinkedList.h
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YMLinkedListNode.h"


@interface YMLinkedList : NSObject {
	YMLinkedListNode *head;
}

- (YMLinkedListNode *)first;
- (YMLinkedListNode *)last;

- (YMLinkedListNode *)addFirst:(YMLinkedListNode *)node;

- (YMLinkedListNode *)addLast:(YMLinkedListNode *)node;

- (void)clear;

@end
