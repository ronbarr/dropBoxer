//
//  DropBoxManager.h
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Dropbox/Dropbox.h>

@interface DropBoxManager : NSObject

@property BOOL isAuthorized;

+(instancetype) sharedDropBoxManager;

-(void) authorizeUserInViewController:(UIViewController *) viewController;

-(void) fetchImageAtPath:(DBPath *) path thumbOK:(BOOL) thumbOK destination:(UIImageView *) photo ;

-(void) saveImageIntoDefaultDirectory:(UIImage *)image ;

-(NSArray *) photoList;

@end
