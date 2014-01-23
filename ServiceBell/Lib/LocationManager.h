//
//  LocationManager.h
//  EDrivel
//
//  Created by chen wang on 11-12-21.
//  Copyright (c) 2011年 bonet365.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import <MapKit/MKReverseGeocoder.h>

// notification
#define LocationChanged		@"locationChanged"

@interface LocationManager : NSObject <CLLocationManagerDelegate, MKReverseGeocoderDelegate> {
	CLLocationManager *locationManager;
	CLLocationCoordinate2D _coord;  
	MKPlacemark *_mPlacemark;
	
	MKReverseGeocoder *_geoCoder;
    
	CLLocationCoordinate2D choosedCoord;
    BOOL isLocationOk;
    
    BOOL isShow;
}

@property (nonatomic, readonly) BOOL isLocationOk;
@property (nonatomic, readonly) CLLocationCoordinate2D coord;  
@property (nonatomic, readonly) BOOL locationFaked;

+ (LocationManager *)instance;
+ (BOOL)isLocationOk;
- (void)start;
- (void)stop;
- (double)latitude;
- (double)longitude;
- (NSString*)locationString;
- (NSString *)city;
- (void)setChoosedCoord:(CLLocationCoordinate2D)c;

- (double_t)distanceFrom:(CLLocationCoordinate2D)fromCoord;
- (NSString *)formatDistance:(double)distance;

@end
