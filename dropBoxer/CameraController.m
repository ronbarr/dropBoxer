//
//  CameraManager.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "CameraController.h"
#import "DropBoxManager.h"
#import "CurrentLocationManager.h"

@interface CameraController ()
@property (strong, nonatomic) CurrentLocationManager * locationManager;
@end

@implementation CameraController

-(void) viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [CurrentLocationManager defaultLocationServicesManager];
 }

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //Load the camera picker
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker
                           animated:YES
                         completion:nil];
    }
}

-(void) exitToPhotos {
   [self.tabBarController setSelectedIndex:0];
}

#pragma mark - Camera picker delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [[DropBoxManager sharedDropBoxManager] saveImageIntoDefaultDirectory:chosenImage];
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    [self exitToPhotos];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES
                               completion:nil];
    [self exitToPhotos];
    
}

#pragma mark - hide the status bar
-(BOOL) prefersStatusBarHidden {
    return YES;
}
@end
