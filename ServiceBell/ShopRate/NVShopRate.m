//
//  NVShopRate.m
//  NVScope
//
//  Created by Hui Zhou on 10-8-17.
//  Copyright 2010 dianping.com. All rights reserved.
//

#import "NVShopRate.h"

#define kRateStarWidth	40.0
#define kRateStarHeight	40.0

@interface NVShopRate (Private)

- (void)showNormalStar;


@end


@implementation NVShopRate

@synthesize rate = _rate;


- (void)initial {
	self.userInteractionEnabled = YES;
	self.exclusiveTouch = NO;
	self.backgroundColor = [UIColor clearColor];
	
	CGRect starRect = CGRectMake(0.0, 0.0, kRateStarWidth, kRateStarHeight);
	star1 = [[UIImageView alloc] initWithFrame:starRect];
	star1.autoresizingMask = UIViewAutoresizingNone;
	[self addSubview:star1];
	
	starRect.origin.x += kRateStarWidth;
	star2 = [[UIImageView alloc] initWithFrame:starRect];
	star2.autoresizingMask = UIViewAutoresizingNone;
	[self addSubview:star2];
	
	starRect.origin.x += kRateStarWidth;
	star3 = [[UIImageView alloc] initWithFrame:starRect];
	star3.autoresizingMask = UIViewAutoresizingNone;
	[self addSubview:star3];
	
	starRect.origin.x += kRateStarWidth;
	star4 = [[UIImageView alloc] initWithFrame:starRect];
	star4.autoresizingMask = UIViewAutoresizingNone;
	[self addSubview:star4];
	
	starRect.origin.x += kRateStarWidth;
	star5 = [[UIImageView alloc] initWithFrame:starRect];
	star5.autoresizingMask = UIViewAutoresizingNone;
	[self addSubview:star5];
	
	_rate = 0;
    _lessRate = 0;
	[self showNormalStar];
}

- (void)setRateStarSize:(CGSize)size
{
    float factor = size.width / kRateStarWidth;
    CGRect starRect = star1.frame;
    starRect.size = size;
    starRect.origin.x *= factor;
    star1.frame = starRect;
    
    starRect = star2.frame;
    starRect.size = size;
    starRect.origin.x *= factor;
    star2.frame = starRect;
    
    starRect = star3.frame;
    starRect.size = size;
    starRect.origin.x *= factor;
    star3.frame = starRect;
    
    starRect = star4.frame;
    starRect.size = size;
    starRect.origin.x *= factor;
    star4.frame = starRect;
    
    starRect = star5.frame;
    starRect.size = size;
    starRect.origin.x *= factor;
    star5.frame = starRect;
}

- (void)setRate:(NSUInteger)aRate {
	_rate = aRate;
	[self showNormalStar];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self initial];
    }
    return self;
}

- (void)awakeFromNib {
	[self initial];
}

- (void)handleTouch:(CGPoint)touchPoint {
	NSUInteger touchStar = 0;
	if (touchPoint.x > CGRectGetMinX(star5.frame)) {
		touchStar = 50;
	} else if (touchPoint.x > CGRectGetMinX(star4.frame)) {
		touchStar = 40;
	} else if (touchPoint.x > CGRectGetMinX(star3.frame)) {
		touchStar = 30;
	} else if (touchPoint.x > CGRectGetMinX(star2.frame)) {
		touchStar = 20;
	} else if (touchPoint.x > CGRectGetMinX(star1.frame)) {
		touchStar = 10;
	} else touchStar = _lessRate;
	
	if (_touchRate == touchStar) {
		return;
	}
	
	_touchRate = touchStar;
	
	UIImage *shineStar = [UIImage imageNamed:@"Star_1_Pressed.png"];
	UIImage *gloomyStar = [UIImage imageNamed:@"Star_0_Pressed.png"];
	if (touchStar > 0)
		star1.image = shineStar;
	else
		star1.image = gloomyStar;
	
	if (touchStar > 10)
		star2.image = shineStar;
	else
		star2.image = gloomyStar;

	if (touchStar > 20)
		star3.image = shineStar;
	else
		star3.image = gloomyStar;
	
	if (touchStar > 30)
		star4.image = shineStar;
	else
		star4.image = gloomyStar;
	
	if (touchStar > 40)
		star5.image = shineStar;
	else
		star5.image = gloomyStar;
}

- (void)showNormalStar {
	UIImage *shineStar = [UIImage imageNamed:@"Star_1_Normal.png"];
	UIImage *gloomyStar = [UIImage imageNamed:@"Star_0_Normal.png"];

	if (_rate > 0)
		star1.image = shineStar;
	else
		star1.image = gloomyStar;
	
	if (_rate > 10)
		star2.image = shineStar;
	else
		star2.image = gloomyStar;
	
	if (_rate > 20)
		star3.image = shineStar;
	else
		star3.image = gloomyStar;
	
	if (_rate > 30)
		star4.image = shineStar;
	else
		star4.image = gloomyStar;
	
	if (_rate > 40)
		star5.image = shineStar;
	else
		star5.image = gloomyStar;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch * touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	_touchRate = NSUIntegerMax;
	[self handleTouch:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint point = [touch locationInView:self];
	[self handleTouch:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    if (_rate == _touchRate)
	_rate = _touchRate;
	[self showNormalStar];
    [_onToucheEndDelegate shopRateTouchEndFinished];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
}

- (void)setTouchEndDelegate:(id <NVShopRateTouchEndDelegate>) delegate {
    _onToucheEndDelegate = delegate;
}

- (void)setStarRate:(NSInteger) starRate {
    UIImage *shineStar = [UIImage imageNamed:@"Star_1_Normal.png"];
	UIImage *gloomyStar = [UIImage imageNamed:@"Star_0_Normal.png"];
    _rate = starRate;
    
	if (_rate > 0)
		star1.image = shineStar;
	else
		star1.image = gloomyStar;
	
	if (_rate > 10)
		star2.image = shineStar;
	else
		star2.image = gloomyStar;
	
	if (_rate > 20)
		star3.image = shineStar;
	else
		star3.image = gloomyStar;
	
	if (_rate > 30)
		star4.image = shineStar;
	else
		star4.image = gloomyStar;
	
	if (_rate > 40)
		star5.image = shineStar;
	else
		star5.image = gloomyStar;
}

@end
