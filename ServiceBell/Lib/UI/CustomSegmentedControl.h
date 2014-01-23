//
//  CustomSegmentedControl.h
//
//  Created by chen wang on 11-8-3.

#import <UIKit/UIKit.h>

@class CustomSegmentedControl;
@protocol CustomSegmentedControlDelegate

- (void)valueChanged:(CustomSegmentedControl *)segmentedControl selectedSegmentIndex:(NSInteger)index;

@end

typedef enum {
    SCS_TEXT,
    SCS_IMAGE,
} SegmentedControlStyle;

@interface CustomSegmentedControl : UIView
{
    NSInteger selectedSegmentIndex;
    NSMutableArray *_buttonArray;
    
    NSMutableArray *_buttonImagesForNormal;
    NSMutableArray *_buttonImagesForSelected;
    
    NSMutableArray *_buttonBackImagesForNormal;
    NSMutableArray *_buttonBackImagesForSelected;
    
    NSMutableDictionary *_tags;
}
@property (nonatomic, assign) id<CustomSegmentedControlDelegate> delegate;
@property (nonatomic) NSInteger selectedSegmentIndex;
@property (nonatomic) NSUInteger numberOfSegments;
@property (nonatomic) BOOL enabled;
@property (nonatomic) SegmentedControlStyle style;
@property (nonatomic,copy) UIColor *selectedColor;
- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (void)setTag:(NSInteger)tag forSegmentAtIndex:(NSInteger)segment;
- (NSInteger)tagAtIndex:(NSInteger)segment;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state atIndex:(NSInteger)index;
- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment forState:(UIControlState)state;

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex shouldCallback:(BOOL)shouldCallBack;
- (UIButton*)buttonForIndex:(int)index;

-(void)setButtonFont:(UIFont *)font forSegmentAtIndex:(NSUInteger)segment;
@end
