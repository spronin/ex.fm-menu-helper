//
//  Song.h
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Song : NSObject {
    NSString *artist_;
    NSString *title_;
    NSString *url_;
    BOOL loved_;
    NSString *songID_;
    NSString *imageURLSmall_;
    NSString *imageURLBig_;
}

@property (nonatomic, retain) NSString *imageURLBig;
@property (nonatomic, retain) NSString *imageURLSmall;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *songID;
@property (nonatomic) BOOL loved;

-(NSString *)name;

+(id)song;

@end
