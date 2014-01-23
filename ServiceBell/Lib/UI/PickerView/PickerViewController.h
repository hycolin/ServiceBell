#import <UIKit/UIKit.h>

@protocol PickerViewControllerDelegate <NSObject>

- (NSInteger)numberOfComponentsInPickerView;

- (NSInteger)numberOfRowsInComponent:(NSInteger)component;

- (CGFloat)rowHeightForComponent:(NSInteger)component;

- (CGFloat)widthForComponent:(NSInteger)component;

- (NSString *)titleForRow:(NSInteger)row forComponent:(NSInteger)component;

- (void)selectedRow:(NSInteger)row inComponent:(NSInteger)component;

@optional

- (void)didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end

@interface PickerViewController : UIViewController 
<UIPickerViewDelegate, UIPickerViewDataSource>
{

	UIPickerView *filterPicker;
	UIView *filterView;
	UIActionSheet* filterSheet;
	id delegate;
}

@property (nonatomic, retain) IBOutlet UIPickerView *filterPicker;
@property (nonatomic, retain) IBOutlet UIView *filterView;
@property (nonatomic, assign) id <PickerViewControllerDelegate> delegate;


- (IBAction)cancelPicker:(id)sender;
- (IBAction)confirmPicker:(id)sender;

- (void)showPicker:(UIView*)myView index:(NSInteger)first, ... ;
- (void)showPickerFromTab:(UITabBar*)bar index:(NSInteger)first, ...;

@end
