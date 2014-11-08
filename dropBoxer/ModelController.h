//
//  ModelController.h
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelControllerDelegate.h"

@class ListViewController;

@interface ModelController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id <ModelControllerDelegate> tableDelegate;

@end
