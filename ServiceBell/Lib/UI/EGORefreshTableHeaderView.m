//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#define  RefreshViewHight 65
#define  RefreshViewHightForPullUp 130.0f

#import "EGORefreshTableHeaderView.h"

//#import "YMAppDelegate.h"

#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


@interface EGORefreshTableHeaderView (Private)
- (void)setState:(EGOPullRefreshState)aState;
@end

@implementation EGORefreshTableHeaderView

@synthesize delegate=_delegate;
@synthesize statusText;
@synthesize style = _style;

- (id)initWithFrame:(CGRect)frame withStyle:(EGOStyle)style {
    self = [super initWithFrame: frame];
    if (self) {
		_style = style;
        
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor]; // [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];

		UILabel *label = [[UILabel alloc] init];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		[label release];
		
		label = [[UILabel alloc] init];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:13.0f];
		label.textColor = TEXT_COLOR;
		label.shadowColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		[label release];
		
		CALayer *layer = [CALayer layer];
		
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"tableview_pulltorefresh_arrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:view];
		_activityView = view;
		[view release];
		
		
        if (_style == EGOPullDown) {
            _statusLabel.frame = CGRectMake(0.0f, self.frame.size.height - 38, self.frame.size.width, 20.0f);
            _activityView.frame = CGRectMake(35.0f, self.frame.size.height - 38.0f, 20.0f, 20.0f);
            _arrowImage.frame = CGRectMake(35.0f, self.frame.size.height - RefreshViewHight + 5.0f, 30.0f, 60.0f);
        } else {
            _lastUpdatedLabel.frame = CGRectMake(0.0f, RefreshViewHight - 50.0f, self.frame.size.width, 20.0f);
            _statusLabel.frame = CGRectMake(0.0f, RefreshViewHight - 68.0f, self.frame.size.width, 20.0f);
            _activityView.frame = CGRectMake(25.0f, RefreshViewHight - 58.0f, 20.0f, 20.0f);
            _arrowImage.frame = CGRectMake(15.0f, 10.0f, 30.0f, 60.0f);
        }
        
        self.statusText = @"刷新";
        
        _state = EGOOPullRefreshNormal;
		[self setState:EGOOPullRefreshNormal];
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)refreshLastUpdatedText {
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		NSString *updateText = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
		_lastUpdatedLabel.text = [NSString stringWithFormat:@"%@", updateText];
	} else {
		_lastUpdatedLabel.text = nil;
	}

}

- (void)setState:(EGOPullRefreshState)aState{
	
	switch (aState) {
		case EGOOPullRefreshPulling:
			_statusLabel.text = [NSString stringWithFormat:@"松开即可%@", self.statusText];
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullRefreshNormal:
			if (_state == EGOOPullRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			if (_style == EGOPullDown) {
                _statusLabel.text = [NSString stringWithFormat:@"下拉%@", self.statusText];
            } else {
                _statusLabel.text = [NSString stringWithFormat:@"上拉%@", self.statusText];
            }
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];			
			break;
		case EGOOPullRefreshLoading:
			_statusLabel.text = NSLocalizedString(@"加载中...", @"加载中...");
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
//    if (_state != aState) {
//        if (aState == EGOOPullRefreshPulling) {
//            [[YMAppDelegate instance] playPullAudio];
//        } else if (aState == EGOOPullRefreshNormal) {
//            [[YMAppDelegate instance] playReleaseAudio];
//        }
//    }
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

//手指屏幕上不断拖动调用此方法
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView {	
	
//	if (_state == EGOOPullRefreshLoading) {
//		
//		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//		offset = MIN(offset, 60);
//		scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0f, RefreshViewHight, 0.0f);
//		
//	} else 
    if (scrollView.isDragging) {
		BOOL _loading = NO;
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
			_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
		}
		if (_style == EGOPullUp) {
            if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y + (scrollView.frame.size.height) < scrollView.contentSize.height + RefreshViewHightForPullUp && scrollView.contentOffset.y > 0.0f && !_loading) {
                [self setState:EGOOPullRefreshNormal];
            } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHightForPullUp  && !_loading) {
                [self setState:EGOOPullRefreshPulling];
            }
        } else {
            if (_state == EGOOPullRefreshPulling && scrollView.contentOffset.y > -RefreshViewHight && scrollView.contentOffset.y < 0.0f && !_loading) {
                [self setState:EGOOPullRefreshNormal];
            } else if (_state == EGOOPullRefreshNormal && scrollView.contentOffset.y < -RefreshViewHight  && !_loading) {
                [self setState:EGOOPullRefreshPulling];
            }
        }
		
		if (scrollView.contentInset.bottom != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

//当用户停止拖动，并且手指从屏幕中拿开的的时候调用此方法
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceIsLoading:)]) {
		_loading = [_delegate egoRefreshTableHeaderDataSourceIsLoading:self];
	}
	
	if (((_style == EGOPullUp && (scrollView.contentOffset.y + (scrollView.frame.size.height) > scrollView.contentSize.height + RefreshViewHightForPullUp)) || (_style == EGOPullDown && scrollView.contentOffset.y < -RefreshViewHight))
        && !_loading) {
		
		if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
			[_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:EGOOPullRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
        if (_style == EGOPullUp) {
        		scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, RefreshViewHight, 0.0f);
        } else {
            	scrollView.contentInset = UIEdgeInsetsMake(RefreshViewHight, 0.0f, 0.0f, 0.0f);
        }
		[UIView commitAnimations];
		
	}
	
}

//当开发者页面页面刷新完毕调用此方法，[delegate egoRefreshScrollViewDataSourceDidFinishedLoading: scrollView];
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:EGOOPullRefreshNormal];

}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	
	_delegate=nil;
	_activityView = nil;
	_statusLabel = nil;
	_arrowImage = nil;
	_lastUpdatedLabel = nil;
    [super dealloc];
}


@end
