//
//  Plugin.h
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Plugin : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSDate * installed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * owner;
@property (nonatomic, retain) NSString * downloadPath;
@property (nonatomic) UInt32 stars;

-(void)download;
-(void)delete;
-(BOOL)isInstalled;
-(NSString*)displayName;
-(NSURL*)repoURL;


@end
