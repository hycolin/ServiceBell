//
//  YMLinkedListNode.h
//  YMLib
//
//  Created by Tu Yimin on 10-1-8.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YMLinkedListNode : NSObject {
	@public YMLinkedListNode *prev;
	@public YMLinkedListNode *next;
	
	id obj;
	
	@public time_t time;
}
@property (nonatomic, retain) id obj;

- (void)remove;

@end
