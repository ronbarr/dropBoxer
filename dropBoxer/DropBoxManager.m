//
//  DropBoxManager.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "DropBoxManager.h"
#import "Keys.h"

#define DROPBOXKEY     @"byj17hr5jnpgsww"
#define DROPBOXSECRET  @"p2c9pkaobhevxlr"

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
    }
    return self;
}

-(void) authorizeUserInViewController:(UIViewController *) viewController {
    
    [[DBAccountManager sharedManager] linkFromController:viewController];
}
         
-(void) authorized {
    /** Successfully authorized - get the files and set up the observer to look for changes
     
        We'll do this in the background */
    
    [self.fileSystem addObserver:self
           forPathAndDescendants:[DBPath root] block:^{
               [DropBoxManager notifyFilesChanged];
           }];

    self.fileSystem = [[DBFilesystem alloc] initWithAccount:self.accountManager.linkedAccount];
    __block NSArray * fileList = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        fileList = [self listOfFiles:[DBPath root]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (fileList.count) {
                [DropBoxManager notifyFilesChanged];
            }
            self.fileList = [fileList mutableCopy];
        });
    });
   }

+(void) notifyFilesChanged {
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

-(NSArray *) fileListAtPath:(DBPath *) path {
    NSArray * photos = nil;
    return photos;
}

-(UIImage *) imageInFile:(DBFile *) file thumbOK:(BOOL) thumbOK {
    
    return nil;
}




@end
