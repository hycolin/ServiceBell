//
//  LocationManager.m
//  EDrivel
//
//  Created by chen wang on 11-12-21.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import "LocationManager.h"

static LocationManager *gLocationManager = nil;

@implementation LocationManager
@synthesize isLocationOk;
@synthesize coord = _coord;
@synthesize locationFaked;

+ (LocationManager *)instance {
	if (gLocationManager == nil) {
		gLocationManager = [[LocationManager alloc] init];
	}
	return gLocationManager;
}

+ (BOOL)isLocationOk {
	return [[LocationManager instance] isLocationOk];
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		_mPlacemark = nil;
		isLocationOk = NO;
        isShow=NO;
		locationManager = [[CLLocationManager alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    
    return self;
}

- (void)start {
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	locationManager.distanceFilter = 1;
#if TARGET_IPHONE_SIMULATOR
	// zhongshan park
	_coord.longitude = 121.419096;
	_coord.latitude = 31.215866;
    isLocationOk = YES;
//    [[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
    [self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
#else
	[locationManager startUpdatingLocation];
#endif
}

- (void)stop {
	[locationManager stopUpdatingLocation];
}

- (void)applicationWillResignActive {
	[self stop];
}

- (void)applicationDidBecomeActive {
	locationFaked = NO;
	[self start];
}

- (void)startGeoCoder {
	if (_geoCoder) {
		_geoCoder.delegate = nil;
		[_geoCoder cancel];
		[_geoCoder release];
	}
	
	_geoCoder = [[MKReverseGeocoder alloc] initWithCoordinate:_coord];
	_geoCoder.delegate=self;
	[_geoCoder start];
}

- (void)setChoosedCoord:(CLLocationCoordinate2D)c {
	[self stop];
	_coord = c;
	isLocationOk = YES;
	locationFaked = YES;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[_mPlacemark release];
	_mPlacemark = nil;
	[self startGeoCoder];
}

#pragma mark -
#pragma mark CLLocationManager delegate
- (void) locationManager: (CLLocationManager *) manager 
	 didUpdateToLocation: (CLLocation *) newLocation
			fromLocation: (CLLocation *) oldLocation{
	[locationManager stopUpdatingLocation];
	_coord.longitude = newLocation.coordinate.longitude;
	_coord.latitude = newLocation.coordinate.latitude;
	dlog(@"loction: (%.6f, %.6f)", _coord.longitude, _coord.latitude);
    isLocationOk = YES;
	
//	// 需要尽量少的调用google geocoder，否则可能会导致解析失败。
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0];
	
//	[[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
}

- (void) locationManager: (CLLocationManager *) manager didFailWithError: (NSError *) error {
    dlog(@"locationManager error : %@",error);
	if ([error code] == kCLErrorDenied) {
        if(!isShow){
           isShow=YES;
		   UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误" message:@"GPS未打开，请在设置中打开GPS设置" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确认", nil];
		   [av show];
		   [av release];
        }
	}
	
	isLocationOk = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
}

-(double)latitude{
	return _coord.latitude;
}

-(double)longitude{
	return _coord.longitude;	
}

- (NSString *)city {
    return _mPlacemark.locality;
}

#pragma mark -
#pragma mark MKReverseGeocoderDelegate methods

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	dlog(@"reverse finished...");
    dlog(@"country:%@",placemark.country);
	dlog(@"countryCode:%@",placemark.countryCode);
	dlog(@"locality:%@",placemark.locality);
	dlog(@"subLocality:%@",placemark.subLocality);
	dlog(@"postalCode:%@",placemark.postalCode);
	dlog(@"subThoroughfare:%@",placemark.subThoroughfare);
	dlog(@"thoroughfare:%@",placemark.thoroughfare);
	dlog(@"administrativeArea:%@",placemark.administrativeArea);
	[_mPlacemark release];
    _mPlacemark = [placemark retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	dlog(@"error %@" , error);
	geocoder.delegate = nil;

	[_mPlacemark release];
	_mPlacemark = nil;
//	[[NSNotificationCenter defaultCenter] postNotificationName:LocationChanged object:nil];
    [self performSelector:@selector(startGeoCoder) withObject:nil afterDelay:1.0]; //3秒后重试
}

-(NSString*)locationString{
    if (_mPlacemark && [_mPlacemark isKindOfClass:[MKPlacemark class]]) {
        return [NSString stringWithFormat:@"%@%@%@%@"
                ,[_mPlacemark.locality isKindOfClass:[NSString class]] ? _mPlacemark.locality : @""
                ,[_mPlacemark.subLocality isKindOfClass:[NSString class]] ? _mPlacemark.subLocality : @""
                ,[_mPlacemark.thoroughfare isKindOfClass:[NSString class]] ? _mPlacemark.thoroughfare : @""
                ,[_mPlacemark.subThoroughfare isKindOfClass:[NSString class]] ? _mPlacemark.subThoroughfare : @""];
    } else {
        return @"获取当前位置失败";
    }
//    return [NSString stringWithFormat:@"%.6f %.6f",[self latitude],[self longitude]];
}

- (double_t)distanceFrom:(CLLocationCoordinate2D)fromCoord {
    double_t lat1 = fromCoord.latitude / 180.0 * M_PI;
    double_t lon1 = fromCoord.longitude / 180.0 * M_PI;
    double_t lat2 = _coord.latitude / 180.0 * M_PI;
    double_t lon2 = _coord.longitude / 180.0 * M_PI;
    double_t dlat = lat2 - lat1;
    double_t dlon = lon2 - lon1;
    
    double_t a = sin(dlat / 2.0) * sin(dlat / 2.0)
    + cos(lat1) * cos(lat2) * sin(dlon / 2.0) * sin(dlon / 2.0);
    double_t c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
    return 6371000 * c;
}

- (NSString *)formatDistance:(double)distance {
	if (distance > 0) {
		int i = ((int)round(distance / 10.0)) * 10;
		if (i < 100) {
			return @"100m";
		} else if (i < 1000) {
			return [NSString stringWithFormat:@"%dm", i];
		} else if (i <10000) {
			double d = (double)i / 1000.0;
			return [NSString stringWithFormat:@"%.1fkm", d];
		} else if (i < 100000){
			int j = i/1000;
			return [NSString stringWithFormat:@"%dkm", j];
		} else {
			return @"约100km";
		}
	} else {
		return nil;
	}
}


- (void)dealloc {
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self stop];
	if (locationManager != nil){
		[locationManager release];
		locationManager = nil;
	}

	if (_geoCoder) {
		_geoCoder.delegate = nil;
		[_geoCoder cancel];
		[_geoCoder release];
		_geoCoder = nil;
	}
	
	[_mPlacemark release];
	[super dealloc];
}

@end
