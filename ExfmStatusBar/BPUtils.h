//
//  BPUtils.h
//  
//
//  Created by Sergey Pronin on 04/02/2012.
//  Copyright (c) 2012 Sergey Pronin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"


typedef void(^BPCallback)(BOOL success, NSDictionary *result, int code);
typedef void(^BPEmptyBlock)();

@interface BPUtils : NSObject

+(void)POSTWithParams:(NSString *)params toURL:(NSString *)strUrl withCallback:(BPCallback)callback;
+(void)GETWithParams:(NSString *)params toURL:(NSString *)strUrl withCallback:(BPCallback)callback;

+(void)addOperationToSequentialBlock:(BPEmptyBlock)block;
+(void)addAsyncTask:(BPEmptyBlock)block;

@end