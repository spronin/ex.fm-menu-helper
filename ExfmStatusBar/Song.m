//
//  Song.m
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Song.h"

@implementation Song
@synthesize artist=artist_, title=title_, loved=loved_, url=url_, songID=songID_, imageURLSmall=imageURLSmall_, imageURLBig=imageURLBig_;

-(void)dealloc {
    self.imageURLBig = nil;
    self.imageURLSmall = nil;
    self.songID = nil;
    self.url = nil;
    self.artist = nil;
    self.title = nil;
    [super dealloc];
}

-(NSString *)name {
    return [NSString stringWithFormat:@"%@ - %@", artist_, title_];
}

+(id)song {
    return [[[Song alloc] init] autorelease];
}

@end
