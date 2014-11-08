//
//  DetailController.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "DetailController.h"
#import "DropBoxManager.h"

@interface DetailController ()

@property (weak, nonatomic) IBOutlet UIImageView *image;

- (IBAction)tapped:(id)sender;
@end

@implementation DetailController

-(void) viewDidLoad {
    [super viewDidLoad];
    [[DropBoxManager sharedDropBoxManager] fetchImageAtPath:self.photoPath
                                                    thumbOK:NO
                                                destination:self.image];
}

- (IBAction)tapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
