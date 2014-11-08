//
//  ModelController.m
//  dropBoxer
//
//  Created by Ron Barr on 11/8/14.
//  Copyright (c) 2014 Ron Barr. All rights reserved.
//

#import "ModelController.h"
#import "DropBoxManager.h"
#import "Keys.h"
#import "defaultCell.h"

@interface ModelController ()

@property (strong, nonatomic) NSArray * photoList;
@property (strong, nonatomic) NSMutableArray * pictureArray;

@end

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(filesChanged)
                                                     name:kFilesChanged
                                                   object:nil];
    }
    return self;
}

#pragma mark - Look for changes in file list
-(void) filesChanged {
    self.photoList = [[DropBoxManager sharedDropBoxManager] photoList];
    
    if ([self.tableDelegate respondsToSelector:@selector(reloadTableView)]) {
        [self.tableDelegate reloadTableView];
    }
}

#pragma mark utility
-(NSDateFormatter *) dateFormatter {
    static NSDateFormatter * formatter;
    if (!formatter) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return formatter;
}

#pragma mark - Tableview DataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.photoList.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCell];
    if (indexPath.row < self.photoList.count) {
        DBFileInfo * info = self.photoList[indexPath.row];
        DefaultCell * defaultCell = (DefaultCell *) cell;
     
        [[DropBoxManager sharedDropBoxManager] fetchImageAtPath:info.path
                                                        thumbOK:YES
                                                    destination:defaultCell.imageView];
        defaultCell.name.text = info.path.name;
        
        
        defaultCell.dateModified.text = [[self dateFormatter] stringFromDate:info.modifiedTime ];
    }
    return cell;
}

#pragma mark Tableview delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DBFileInfo * info = self.photoList[indexPath.row];
    if ([self.tableDelegate respondsToSelector:@selector(showDetailOfItem:)]) {
        [self.tableDelegate showDetailOfItem:info.path];
    }
   }
@end
