//
//  ModelController.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "ModelController.h"
#import "DropBoxManager.h"

@implementation ModelController

+ (instancetype)sharedModelController {
    static ModelController *modelController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        modelController = [[ModelController alloc] init];
    }
                  );
    return modelController;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        //List controller should be assigned prior to Model creation

    }
    return self;
}
@end
