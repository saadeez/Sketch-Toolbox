//
//  Plugin.m
//  Sketch Toolbox
//
//  Created by Shahruz Shaukat on 5/19/14.
//  Copyright (c) 2014 Shahruz Shaukat. All rights reserved.
//

#import "Plugin.h"
#import "SSZipArchive.h"

@implementation Plugin

@dynamic desc;
@dynamic installed;
@dynamic name;
@dynamic owner;
@dynamic stars;
@dynamic downloadPath;

-(BOOL)isInstalled {
    return self.installed > [NSDate dateWithTimeIntervalSince1970:978307200];
}

-(NSString*)displayName {
    return [[self.name stringByReplacingOccurrencesOfString:@"-" withString:@" "] capitalizedString];
}

-(NSURL*)repoURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"https://github.com/%@/%@", self.owner, self.name]];
}

-(void)delete {
    if (!self.isInstalled) return;
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:self.downloadPath error:nil];
    self.installed = [NSDate dateWithTimeIntervalSince1970:978307200];
    self.downloadPath = @"";
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];    
}

-(void)download {
    if (self.isInstalled) return;
    NSLog(@"Downloading %@", self.name);
    NSURL *url = [NSURL URLWithString:
                  [NSString stringWithFormat:
                   @"%@/archive/master.zip", self.repoURL]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSString *tmpPath = [@"/tmp/" stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@-%@.zip", self.owner, self.name]];
        NSString *tmpOutputPath = @"/tmp/";
        NSString *tmpContentsPath = [tmpOutputPath stringByAppendingPathComponent:
                                     [NSString stringWithFormat:@"%@-master", self.name]];
        [data writeToFile:tmpPath atomically:YES];
        [SSZipArchive unzipFileAtPath:tmpPath toDestination:tmpOutputPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:tmpPath error:nil];
        NSString *outputPath = [[NSString stringWithFormat:@"~/Library/Containers/com.bohemiancoding.sketch3/Data/Library/Application Support/com.bohemiancoding.sketch3/Plugins/%@", self.displayName]  stringByExpandingTildeInPath];
        [fm moveItemAtPath:tmpContentsPath toPath:outputPath error:nil];
        self.installed = [NSDate date];
        self.downloadPath = outputPath;
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"pluginStatusUpdated" object:nil];
    }];

}

@end
