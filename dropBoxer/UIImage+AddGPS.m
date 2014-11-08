//
//  UIImage+AddGPS.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "UIImage+AddGPS.h"
#import "CurrentLocationManager.h"
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>
#import <ImageIO/CGImageDestination.h>


@implementation UIImage (AddGPS)

-(NSMutableData *)getDataWithLocation:(CLLocation *) location;
{
    NSData* jpgData =  UIImageJPEGRepresentation(self,0);
    
    double currentLatitude = location.coordinate.latitude;
    double currentLongitude = location.coordinate.longitude;
    
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)jpgData, NULL);
    NSDictionary *metadata = (NSDictionary *) CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source, 0, NULL));
    
    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
    
    //For GPS Dictionary
    NSMutableDictionary *GPSDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary]mutableCopy];
    if(!GPSDictionary)
        GPSDictionary = [NSMutableDictionary dictionary];
    
    [GPSDictionary setValue:[NSNumber numberWithDouble:currentLatitude] forKey:(NSString*)kCGImagePropertyGPSLatitude];
    [GPSDictionary setValue:[NSNumber numberWithDouble:currentLongitude] forKey:(NSString*)kCGImagePropertyGPSLongitude];
    
    NSString* ref;
    if (currentLatitude <0.0)
        ref = @"S";
    else
        ref =@"N";
    [GPSDictionary setValue:ref forKey:(NSString*)kCGImagePropertyGPSLatitudeRef];
    
    if (currentLongitude <0.0)
        ref = @"W";
    else
        ref =@"E";
    [GPSDictionary setValue:ref forKey:(NSString*)kCGImagePropertyGPSLongitudeRef];
    
    [GPSDictionary setValue:[NSNumber numberWithFloat:location.altitude] forKey:(NSString*)kCGImagePropertyGPSAltitude];
    
    //For EXIF Dictionary
    NSMutableDictionary *EXIFDictionary = [[metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary]mutableCopy];
    if(!EXIFDictionary)
        EXIFDictionary = [NSMutableDictionary dictionary];
    
    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeOriginal];
    [EXIFDictionary setObject:[NSDate date] forKey:(NSString*)kCGImagePropertyExifDateTimeDigitized];
    
    //add our modified EXIF data back into the image’s metadata
    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(source);
    
    NSMutableData *dest_data = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)dest_data, UTI, 1, NULL);
    
    if(!destination)
        dest_data = [jpgData mutableCopy] ;
    else
    {
        CGImageDestinationAddImageFromSource(destination, source, 0, (CFDictionaryRef) metadataAsMutable);
        BOOL success = CGImageDestinationFinalize(destination);
        if(!success)
            dest_data = [jpgData mutableCopy];
    }
    
    return dest_data;
}


@end