//
//  DropBoxManager.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "DropBoxManager.h"
#import "Keys.h"
#import "UIImage+AddGPS.h"
#import "CurrentLocationManager.h"

#define DROPBOXKEY     @"byj17hr5jnpgsww"
#define DROPBOXSECRET  @"p2c9pkaobhevxlr"
#define DIRECTORY      @"Photos"
#define IMAGENAME      @"image"
#define SUFFIX         @".jpg"

@interface DropBoxManager ()

@property (strong, nonatomic) DBAccountManager * accountManager;
@property (strong, nonatomic) DBFilesystem * fileSystem;
@property (strong, nonatomic) NSMutableArray * fileList;

@end

@implementation DropBoxManager

+ (instancetype)sharedDropBoxManager {
    static DropBoxManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[DropBoxManager alloc] init];
    }
                  );
    return sharedManager;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        
        //Initialize DropBox Manager
        self.accountManager = [[DBAccountManager alloc]
                               initWithAppKey:DROPBOXKEY
                               secret:DROPBOXSECRET];
        
        [DBAccountManager setSharedManager:self.accountManager];
        
        // Watch for completion of account setup
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(authorized)
                                                     name:kAccountLinked
                                                   object:nil];
        self.fileList = nil;
        self.isAuthorized = NO;
    }
    return self;
}

-(void) authorizeUserInViewController:(UIViewController *) viewController {
    
    [[DBAccountManager sharedManager] linkFromController:viewController];
}

-(void) authorized {
    /** Successfully authorized - get the files and set up the observer to look for changes
     
     We'll do this in the background */
    
    DropBoxManager * manager = self; //Can't cause a retain cycle
    self.isAuthorized = YES;
    
    //This observer is not getting triggered. There is some unresolved discussion on stack overflow.
    //http://stackoverflow.com/questions/21924983/dropbox-ios-sync-api-add-observer-not-called-appropriately
    [self.fileSystem addObserver:self
           forPathAndDescendants:[DBPath root] block:^{
               [manager notifyFilesChanged];
           }];
    
    self.fileSystem = [[DBFilesystem alloc] initWithAccount:self.accountManager.linkedAccount];
    
    __block NSArray * fileList = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        fileList = [manager listOfFiles:[DBPath root]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [manager notifyFilesChanged];
        });
    });
}

-(void) notifyFilesChanged {
    self.fileList = [self listOfFiles:[DBPath root]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFilesChanged
                                                        object:nil];
}

-(NSMutableArray *) listOfFiles:(DBPath *) path {
    /** Recursively iterates through DropBox looking for photos. Returns list of all accessible folders */
    DBError * error = nil;
    NSArray * fileList = [self.fileSystem listFolder:path
                                               error:&error];
    NSMutableArray * photos = [NSMutableArray array];
    
    for (DBFileInfo * info in fileList) {
        
        if (info.isFolder) {
            NSArray * files = [self listOfFiles:info.path];
            if (files.count) {
                [photos addObjectsFromArray:files];
            }
        }
        else
            [photos addObject:info];
    };
    return photos;
}

-(void) fetchImageAtPath:(DBPath *) path thumbOK:(BOOL) thumbOK destination:(UIImageView *) photo {
    
    __block UIImage * returnedPhoto;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        DBFile * photoFile = nil;
        DBError * error = nil;
        
        
        if (thumbOK) {
            photoFile = [self.fileSystem openThumbnail:path
                                                ofSize:DBThumbSizeM
                                              inFormat:DBThumbFormatPNG
                                                 error:&error];
        }
        else {
            photoFile = [self.fileSystem openFile:path
                                            error:&error];
        }
        
        if (!error) {
            returnedPhoto = [UIImage imageWithData:[photoFile readData:&error]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            photo.image = returnedPhoto;
        });
    });
    
    
}

-(NSArray *) photoList {
    return [self.fileList copy];
}

#pragma mark - saving
-(void) saveImageIntoDefaultDirectory:(UIImage *)image {
    /* saves image asynchronously to dropbox in default directory.
    1. attempt to create folder. If error is it exists, that's good!
    2. Use the same technique to incrementally create a unique file name (ripe for optimization)
    3. Save it. 
     */
    
    DBFilesystem * fileSystem = self.fileSystem;
    DropBoxManager * manager = self;
    
    NSBlockOperation * saveBlock = [NSBlockOperation blockOperationWithBlock:^{
        DBPath * path = [[DBPath alloc] initWithString:DIRECTORY];
        NSLog(@"path %@", path);
        DBError * error = nil;
        BOOL folderOK = NO;
        if ([fileSystem createFolder:path error:&error]) { //create our folder
            folderOK = YES; //It was created
        }
        else {
            if (error.code == DBErrorExists) { //Did it fail because it exists?
                folderOK = YES;
            }
        }
        
        error = nil;
        BOOL success = NO;
        NSInteger iterator = 0;
        DBFile * photoFile = nil;
        
        while (!success ) {
            iterator++;
            NSString * filePath = [NSString stringWithFormat:@"%@/%@%i%@", DIRECTORY, IMAGENAME, iterator, SUFFIX];
            path = [[DBPath alloc] initWithString:filePath];
            
            photoFile = [self.fileSystem createFile:path error:&error];
            
            success = error == nil || error.code != DBErrorExists;
            error = nil;
        }
        
        if (!error) {
            CLLocation * currentLocation = [[CurrentLocationManager defaultLocationServicesManager] lastKnownLocation];
            NSData * data = [image getDataWithLocation:currentLocation] ;
            success = [photoFile writeData:data error:&error];
            [photoFile close];
            [manager notifyFilesChanged];
        }
    }];
    
    [saveBlock start];
}

@end
