//
//  UIImage+AddGPS.h
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface UIImage (AddGPS)

-(NSMutableData *)getDataWithLocation:(CLLocation *) location;

@end
