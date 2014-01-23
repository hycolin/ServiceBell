//
//  YMSegmentedControl.m
//
//  Created by chen wang on 11-8-3.
//

#import "CustomSegmentedControl.h"

@interface CustomSegmentedControl(Private)

- (void)setButtonBackgroundImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected;
- (void)setButtonImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected;

@end

@implementation CustomSegmentedControl

@synthesize selectedSegmentIndex;
@synthesize numberOfSegments;
@synthesize delegate;
@synthesize enabled;
@synthesize style;
@synthesize selectedColor = _heightLight;

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)awakeFromNib {
    self.exclusiveTouch = YES;
    self.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [_buttonImagesForNormal release];
    [_buttonImagesForSelected release];

    [_buttonBackImagesForNormal release];
    [_buttonBackImagesForSelected release];
    [_buttonArray release];
    [_tags release];
    self.selectedColor = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    int segmentWidth = (self.frame.size.width / [_buttonArray count]);
    float offset = self.frame.size.width - segmentWidth * [_buttonArray count];
    float segmentStartX = 0;
    for (int i = 0; i < [_buttonArray count]; i++) {
        UIButton *button = [_buttonArray objectAtIndex:i];
        if (i == [_buttonArray count] - 1) {
            button.frame = CGRectMake(segmentStartX, 0, segmentWidth + offset, self.frame.size.height);
        } else if (i > 0 && i < [_buttonArray count] - 2) {
            button.frame = CGRectMake(segmentStartX, 0, segmentWidth+1, self.frame.size.height);
        } else {
            button.frame = CGRectMake(segmentStartX, 0, segmentWidth+1, self.frame.size.height);
        }
        segmentStartX += segmentWidth;
    }
}

- (UIButton*) buttonForIndex:(int)index
{
    if(_buttonArray!=nil && _buttonArray.count>index)
    {
        return [_buttonArray objectAtIndex:index];
    }
    return nil;
}
- (void)setEnabled:(BOOL)aEnabled {
    for (int i = 0; i < [_buttonArray count]; i++) {
        UIButton *button = [_buttonArray objectAtIndex:i];
        [button setEnabled:aEnabled];
    }
}
- (void) setSelectedColor:(UIColor *)heightLight
{
    if(_heightLight != heightLight)
    {
        [_heightLight release];
        _heightLight = [heightLight copy];
    }
    if(_heightLight != nil)
    {
        if(_buttonArray!=nil)
        {
            for (UIButton* btn in _buttonArray) {
                [btn  setTitleColor:(UIColor *)self.selectedColor forState:(UIControlState)UIControlStateSelected];
                
            }
        }
    }
    
}
- (void)setNumberOfSegments:(NSUInteger)aNumberOfSegments {
    if ([_buttonArray count] > 0) {
        for (UIButton *button in _buttonArray) {
            [button removeFromSuperview];
        }
        [_buttonArray removeAllObjects];
        [_buttonArray release];        
    }
    numberOfSegments = aNumberOfSegments;
    _buttonArray = [[NSMutableArray arrayWithCapacity:numberOfSegments]retain];
    for (int i=0; i <numberOfSegments; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.exclusiveTouch = YES;
        if (numberOfSegments == 1) {
            UIImage *image = [UIImage imageNamed:@"shop_tab_line.png"];
            [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:15 topCapHeight:21] forState:UIControlStateNormal];    
            [button setBackgroundImage:[image stretchableImageWithLeftCapWidth:15 topCapHeight:21]  forState:UIControlStateHighlighted];    
            [button titleLabel].font = [UIFont boldSystemFontOfSize:15];
            [button setTitleColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1] forState:UIControlStateNormal];
            button.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
            button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        } else {
            if (i == 0) {
                [self setButtonBackgroundImage:button buttonIndex:i selected:YES];
            } else {
                [self setButtonBackgroundImage:button buttonIndex:i selected:NO];
            }
        }
        [button setTag:i];
        [button addTarget:self action:@selector(actionTouch:) forControlEvents:UIControlEventAllTouchEvents];
        [button addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchDown];
        if(self.selectedColor)
        {
               [button  setTitleColor:(UIColor *)self.selectedColor forState:(UIControlState)UIControlStateSelected];
        }
        [button titleLabel].font = [UIFont boldSystemFontOfSize:14];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonArray addObject:button];
        [self addSubview:button];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)aSelectedSegmentIndex shouldCallback:(BOOL)shouldCallBack {
    if (numberOfSegments > 1) {
        UIButton *preButton = nil;
        if (selectedSegmentIndex < [_buttonArray count]) {
            preButton = [_buttonArray objectAtIndex:selectedSegmentIndex];    
        }
        
        if (style == SCS_IMAGE) {
            [self setButtonImage:preButton buttonIndex:selectedSegmentIndex selected:NO];
        } else {
            [self setButtonBackgroundImage:preButton buttonIndex:selectedSegmentIndex selected:NO];
        }
        preButton.selected = NO;
        selectedSegmentIndex = aSelectedSegmentIndex;
        UIButton *button = [_buttonArray objectAtIndex:selectedSegmentIndex];
        
        if (style == SCS_IMAGE) {
            [self setButtonImage:button buttonIndex:selectedSegmentIndex selected:YES];
        } else {
            [self setButtonBackgroundImage:button buttonIndex:selectedSegmentIndex selected:YES];
        }
        button.selected = YES;
        
    } else {
        selectedSegmentIndex = aSelectedSegmentIndex;
    }
    if (shouldCallBack) {
        [delegate valueChanged:self selectedSegmentIndex:selectedSegmentIndex];
    }
}

- (void)setSelectedSegmentIndex:(NSInteger)aSelectedSegmentIndex {
    [self setSelectedSegmentIndex:aSelectedSegmentIndex shouldCallback:YES];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state atIndex:(NSInteger)index {
    if (_buttonBackImagesForNormal == nil) {
        _buttonBackImagesForNormal = [[NSMutableArray alloc] init];
        _buttonBackImagesForSelected = [[NSMutableArray alloc] init];
    }
    if (state == UIControlStateNormal) {
        [_buttonBackImagesForNormal addObject:image];
    } else {
        [_buttonBackImagesForSelected addObject:image];
    }
        
}


- (void)setButtonBackgroundImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected {
    if ([_buttonBackImagesForSelected count] == 0 || [_buttonBackImagesForNormal count] == 0) {
        return;
    }
    if (buttonIndex == 0) { //左按钮
        if (selected) {
           [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:0] forState:UIControlStateNormal]; 
        } else {
            [button setBackgroundImage:[_buttonBackImagesForNormal objectAtIndex:0] forState:UIControlStateNormal];
            [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:0] forState:UIControlStateHighlighted];
        }
    } else if (buttonIndex == numberOfSegments - 1) { //右按钮
        if (selected) {
            [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:2] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:[_buttonBackImagesForNormal objectAtIndex:2] forState:UIControlStateNormal]; 
            [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:2] forState:UIControlStateHighlighted];
        }
    } else { //中间按钮
        if (selected) {
            [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:1] forState:UIControlStateNormal];
        } else {
            [button setBackgroundImage:[_buttonBackImagesForNormal objectAtIndex:1] forState:UIControlStateNormal];
            [button setBackgroundImage:[_buttonBackImagesForSelected objectAtIndex:1] forState:UIControlStateHighlighted];
        }
    }
    if (selected) {
        [button titleLabel].font = [UIFont boldSystemFontOfSize:15];
//        [button setTitleColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [button.titleLabel setShadowColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1]];
//        [button.titleLabel setShadowOffset:CGSizeMake(0, -1)];
    } else {
        [button titleLabel].font = [UIFont boldSystemFontOfSize:14];
//        [button setTitleColor:[UIColor colorWithRed:109/255.f green:109/255.f blue:109/255.f alpha:1] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)setButtonImage:(UIButton *)button buttonIndex:(NSInteger)buttonIndex selected:(BOOL)selected {
    if (selected) {
        [button setImage:[_buttonImagesForSelected objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    } else {
        [button setImage:[_buttonImagesForNormal objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        [button setImage:[_buttonImagesForSelected objectAtIndex:buttonIndex] forState:UIControlStateHighlighted];
    }
}

- (void)setStyle:(SegmentedControlStyle)aStyle {
    style = aStyle;
    if (aStyle == SCS_IMAGE) {
        [_buttonImagesForNormal release];
        [_buttonImagesForSelected release];
        _buttonImagesForNormal = [[NSMutableArray alloc] init];
        _buttonImagesForSelected = [[NSMutableArray alloc] init];
    }
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment forState:(UIControlState)state {
    if (style == SCS_IMAGE) {
        UIButton *button = [_buttonArray objectAtIndex:segment];        
        if (state == UIControlStateNormal) {
            [_buttonImagesForNormal addObject:image]; 
            [button setImage:image forState:UIControlStateNormal];
        } else {
            [_buttonImagesForSelected addObject:image];
            [button setImage:image forState:UIControlStateHighlighted];
        }
    }
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
    UIButton *button = [_buttonArray objectAtIndex:segment];
    [button setTitle:title forState:UIControlStateNormal];
}

-(void)setButtonFont:(UIFont *)font forSegmentAtIndex:(NSUInteger)segment{
    
    UIButton *button = [_buttonArray objectAtIndex:segment];
    button.titleLabel.font=font;
    
}

- (void)setTag:(NSInteger)tag forSegmentAtIndex:(NSInteger)segment {
    if (_tags == nil) {
        _tags = [[NSMutableDictionary alloc] init];
    }
    [_tags setObject:[NSNumber numberWithInt:tag] forKey:[NSNumber numberWithInt:segment]];
}

- (NSInteger)tagAtIndex:(NSInteger)segment {
    return [[_tags objectForKey:[NSNumber numberWithInt:segment]] integerValue];
}

- (void)actionTouch:(id)sender {
    UIButton *button = (UIButton *)sender;
    [button setHighlighted:NO];
    button.selected = YES;
}

- (void)action:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == selectedSegmentIndex) {
        return;
    }
    [self setSelectedSegmentIndex:button.tag];
}

@end
