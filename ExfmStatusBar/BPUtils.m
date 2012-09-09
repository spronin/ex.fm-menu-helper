//
//  BPUtils.m
//  
//
//  Created by Sergey Pronin on 04/02/2012.
//  Copyright (c) 2012 Sergey Pronin. All rights reserved.
//

#import "BPUtils.h"

#define HOST @"http://ex.fm/api/v3/"

@implementation BPUtils

+(void)addOperationToSequentialBlock:(BPEmptyBlock)block {
    static dispatch_once_t once;
    static NSOperationQueue *queue = nil;
    dispatch_once(&once, ^{ 
        queue = [[NSOperationQueue alloc] init]; 
        [queue setMaxConcurrentOperationCount:1];
    });
    
    [queue addOperationWithBlock:block];
}

+(void)addAsyncTask:(BPEmptyBlock)block {
    static dispatch_once_t once;
    static NSOperationQueue *queue = nil;
    dispatch_once(&once, ^{ 
        queue = [[NSOperationQueue alloc] init]; 
        [queue setMaxConcurrentOperationCount:3];
    });
    
    [queue addOperationWithBlock:block];
}

+(void)GETWithParams:(NSString *)params toURL:(NSString *)srUrl withCallback:(BPCallback)callback {
    
   [BPUtils addAsyncTask:^{
        NSMutableString *strUrl = [NSMutableString stringWithFormat:@"%@%@", HOST, srUrl];
        
        if (params) {
            [strUrl appendFormat:@"?%@", params];
        }
        
        NSURLRequest* request= [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strUrl]] autorelease];
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        
        int code = 0;
       
        NSString *str = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"RESULT - %@", str);
        NSDictionary *dict = [str JSONValue];
        
        code = [[dict objectForKey:@"status_code"] intValue];
       
        switch (code) {
            case 200:
                NSLog(@"%s SUCCESS", __PRETTY_FUNCTION__);
                break;
            default:
                break;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(code==200, dict, code);
        });

    }];
}

+(void)POSTWithParams:(NSString *)params toURL:(NSString *)strUrl withCallback:(BPCallback)callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", HOST,strUrl]]];
        
        [request autorelease];
        [request setHTTPMethod:@"POST"];
        
        NSString *string = params;
        
        [request setValue:[NSString stringWithFormat:@"%d", [string length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
        
        
        NSURLResponse *response;
        NSError *err;
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
        NSString *str = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
        NSLog(@"RESULT - %@", str);
        NSDictionary *dictResult = [str JSONValue];
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
        int code  = [resp statusCode];
        switch (code) {
            case 200:
                NSLog(@"%s SUCCESS", __PRETTY_FUNCTION__);
                break;
                
            default:
                NSLog(@"%s %d", __PRETTY_FUNCTION__, code);
                break;
        }
        
        if (callback != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(code==200, dictResult, code);
            });
        }
    });
}

@end
