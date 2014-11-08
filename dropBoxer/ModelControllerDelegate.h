//
//  ModelControllerDelegate.h
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

@protocol ModelControllerDelegate <NSObject>

-(void) reloadTableView;

-(void) showDetailOfItem:(DBPath *) path;

@end