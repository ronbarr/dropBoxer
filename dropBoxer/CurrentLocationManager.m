//
//  CurrentLocation.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "CurrentLocationManager.h"

@interface CurrentLocationManager ()

@property (strong, nonatomic) CLLocation * lastLocation;
@property (strong, nonatomic) NSDate * lastUpdateTime;
@property BOOL checkingLocation;
@property NSTimer * locationCheckingTimer;

@end

@implementation CurrentLocationManager

-(instancetype) init {
    self = [super init];
    return self;
}

+(CurrentLocationManager *) defaultLocationServicesManager
{
    /**
     Initialize the locations singleton and fire up location services if not already done
     */
    static CurrentLocationManager *defaultLocationServicesManager = nil;
    
    if (!defaultLocationServicesManager) {
        CLAuthorizationStatus status = [CurrentLocationManager authorizationStatus];
        
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                defaultLocationServicesManager = [[CurrentLocationManager alloc] init];
                defaultLocationServicesManager.delegate = defaultLocationServicesManager;
                [defaultLocationServicesManager requestWhenInUseAuthorization];
                
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                defaultLocationServicesManager = [[CurrentLocationManager alloc] init];
                defaultLocationServicesManager.delegate = defaultLocationServicesManager;
                [defaultLocationServicesManager startLocationServices];
                break;
                
                
            default: {
                UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Location Services are disabled." message:@"Please enable them in settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorAlert show];
            }
                break;
        }
    }
    
    return defaultLocationServicesManager;
}

-(void) startLocationServices {
    
    self.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.distanceFilter = kCLDistanceFilterNone;
    
    [self startUpdatingLocation];
}

-(CLLocation *) lastKnownLocation {
    return self.lastLocation;
}

#pragma mark -- Core Location Delegates
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    /**
     Handle incoming locations
     */
     if (locations && locations.count > 0 ) {
        self.lastLocation = [locations lastObject];
        self.lastUpdateTime = self.lastLocation.timestamp;
        }
        
    //Turn off location checking
    [self stopUpdatingLocation];
    
}


-(void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways ||
        status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self startLocationServices];
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    UIAlertView *errorAlert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"There was an error retrieving your location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [errorAlert show];
    NSLog(@"Error: %@",error.description);
}

@end
