#import "Compatible.h"

double IPHONE_OS_MAIN_VERSION() {
	static double __iphone_os_main_version = 0.0;
	if(__iphone_os_main_version == 0.0) {
		NSString *sv = [[UIDevice currentDevice] systemVersion];
		NSScanner *sc = [[NSScanner alloc] initWithString:sv];
		if(![sc scanDouble:&__iphone_os_main_version])
			__iphone_os_main_version = -1.0;
		[sc release];
	}
	return __iphone_os_main_version;
}


BOOL IPHONE_OS_3() {
	return IPHONE_OS_MAIN_VERSION() >= 3.0;
}


BOOL IPHONE_OS_4() {
	return IPHONE_OS_MAIN_VERSION() >= 4.0;
}


BOOL IPHONE_OS_4_2() {
	return IPHONE_OS_MAIN_VERSION() >= 4.2;
}

BOOL IPHONE_OS_4_3() {
	return IPHONE_OS_MAIN_VERSION() >= 4.3;
}

BOOL IPHONE_OS_5() {
	return IPHONE_OS_MAIN_VERSION() >= 5.0;
}

BOOL IPHONE_OS_SUPPORTMULTITASK() {
	UIDevice *device = [UIDevice currentDevice];
	if ([device respondsToSelector:@selector(isMultitaskingSupported)] && [device isMultitaskingSupported]) {
		return YES;
	} else {
		return NO;
	}

}
