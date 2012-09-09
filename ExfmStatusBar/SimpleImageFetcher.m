//
//  SimpleImageFetcher.m
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SimpleImageFetcher.h"

@implementation SimpleImageFetcher
@synthesize callback;

-(void)dealloc {
    self.callback = nil;
    [super dealloc];
}

+(id)fetcher {
    return [[[SimpleImageFetcher alloc] init] autorelease];
}

- (void)fetchImageWithURL:(NSURL *)url callback:(ImageBlock)block {
    self.callback = block;
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager cancelForDelegate:self];
    
    if (url)
    {
        [manager downloadWithURL:url delegate:self options:0];
    }
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(NSImage *)image
{
    self.callback(image);
}

@end
