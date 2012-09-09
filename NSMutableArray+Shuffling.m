//
//  
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArray+Shuffling.h"

@implementation NSMutableArray (Shuffling)

- (void)shuffle
{
    for (uint i = 0; i < self.count; ++i)
    {
        // Select a random element between i and end of array to swap with.
        int nElements = self.count - i;
        int n = arc4random_uniform(nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end