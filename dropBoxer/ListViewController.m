//
//  FirstViewController.m
//  dropBoxer
//
//  Created by Ron Barr on 11/7/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "ListViewController.h"
#import "DropBoxManager.h"

@interface ListViewController ()

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DropBoxManager sharedDropBoxManager] authorizeUserInViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
