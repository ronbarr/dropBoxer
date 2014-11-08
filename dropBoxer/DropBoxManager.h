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

+(instancetype) sharedDropBoxManager;

-(void) authorizeUserInViewController:(UIViewController *) viewController;

-(NSArray *) fileListAtPath:(DBPath *) path ;

-(UIImage *) imageInFile:(DBFile *) file thumbOK:(BOOL) thumbOK ;

@end
