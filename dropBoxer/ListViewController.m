//
//  FirstViewController.m
//  dropBoxer
//
//  Created by Ron Barr on 11/7/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "ListViewController.h"
#import "DropBoxManager.h"
#import "ModelController.h"
#import "Keys.h"
#import "DetailController.h"

@interface ListViewController ()

@property (strong, nonatomic) ModelController * modelController;

@property (strong, nonatomic) DBPath * detailImagePath;

@property (strong, nonatomic) DropBoxManager * dropBoxManager;

@end

@implementation ListViewController

#pragma mark - init
- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelController = [[ModelController alloc] init];
    self.modelController.tableDelegate = self;
    self.tableView.delegate = self.modelController;
    self.tableView.dataSource = self.modelController;
    self.dropBoxManager = [DropBoxManager sharedDropBoxManager];
}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.dropBoxManager.isAuthorized) {
         [self.dropBoxManager authorizeUserInViewController:self];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - navigation
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kDetail ]) {
        DetailController * transferController = segue.destinationViewController;
        transferController.photoPath = self.detailImagePath;
    }
}

#pragma mark - model view delegate methods
-(void) reloadTableView {
    [self.tableView reloadData];
}

-(void) showDetailOfItem:(DBPath *)path {
    self.detailImagePath= path;
    
    [self performSegueWithIdentifier:kDetail
                              sender:self];
}

#pragma mark - hide the status bar
-(BOOL) prefersStatusBarHidden {
    return YES;
}
@end
