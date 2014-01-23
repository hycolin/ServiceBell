#import "PickerViewController.h"


@implementation PickerViewController

@synthesize filterPicker;
@synthesize filterView;
@synthesize delegate;

- (id)init {
    if ((self = [super initWithNibName:@"PickerView" bundle:nil])) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	self.filterPicker = nil;
	self.filterView = nil;
}


#pragma mark Picker view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	NSInteger num = [self.delegate numberOfComponentsInPickerView];
	return num;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	NSInteger num = [self.delegate numberOfRowsInComponent:component];
	return num;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	CGFloat num = [self.delegate rowHeightForComponent:component];
	return num;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	CGFloat num = [self.delegate widthForComponent:component];
	return num;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	NSString *title = [self.delegate titleForRow:row forComponent:component];
	return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectRow:inComponent:)]) {
        [self.delegate didSelectRow:row inComponent:component];
    }
}

- (void)showPicker:(UIView*)myView index:(NSInteger)first, ... {
	[self view];
	[filterPicker reloadAllComponents];
	if(!filterSheet) {
		filterSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		[filterSheet insertSubview:filterView atIndex:0];
	}
	[filterSheet showInView:myView];
    
    //resize the view to fit the size of sheet
    filterView.frame = filterSheet.bounds;
    //@2011-05-03 by Johnson
	
	[filterPicker selectRow:first inComponent:0 animated:NO];
	va_list ap;
	va_start(ap, first);
	NSInteger s;
	NSInteger i = 1;
	while((s = va_arg(ap, NSInteger)) && (s != -1)) {
		[filterPicker selectRow:s inComponent:i animated:NO];
		i++;
	}
	va_end(ap);

}

- (void)showPickerFromTab:(UITabBar*)bar index:(NSInteger)first, ...  {
    [self view];
	[filterPicker reloadAllComponents];
	if(!filterSheet) {
		filterSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
		[filterSheet insertSubview:filterView atIndex:0];
	}
	[filterSheet showFromTabBar:bar];
	[filterPicker selectRow:first inComponent:0 animated:NO];
    
    //resize the view to fit the size of sheet
    filterView.frame = filterSheet.bounds;
    //@2011-05-04 by Johnson
	
	va_list ap;
	va_start(ap, first);
	NSInteger s;
	NSInteger i = 1;
	while((s = va_arg(ap, NSInteger)) && (s != -1)) {
		[filterPicker selectRow:s inComponent:i animated:NO];
		i++;
	}
	va_end(ap);
}

- (IBAction)cancelPicker:(id)sender {
	[filterSheet dismissWithClickedButtonIndex:[filterSheet cancelButtonIndex] animated:YES];
}

- (IBAction)confirmPicker:(id)sender {
	
	for (int i = 0; i < filterPicker.numberOfComponents; i++) {
		[self.delegate selectedRow:[filterPicker selectedRowInComponent:i] inComponent:i];
	}
}

- (void)dealloc {
	[self viewDidUnload];
    [filterSheet release];
    filterSheet = nil;
    [super dealloc];
}
@end
