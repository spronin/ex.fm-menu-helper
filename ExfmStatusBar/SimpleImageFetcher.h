//
//  SimpleImageFetcher.h
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDWebImageManager.h"

typedef void(^ImageBlock)(NSImage *image);

@interface SimpleImageFetcher : NSObject <SDWebImageManagerDelegate> {
    ImageBlock callback;
}

@property (nonatomic, copy) ImageBlock callback;

+(id)fetcher;

-(void)fetchImageWithURL:(NSURL *)url callback:(ImageBlock)block;

@end
