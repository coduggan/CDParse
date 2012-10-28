//
//  Apple.m
//  CDParse
//
//  Created by Connor Duggan on 2012-10-28.
//  Copyright (c) 2012 Connor Duggan. All rights reserved.
//

#import "Apple.h"


@implementation Apple

@dynamic  banana;

-(void)dealloc
{
    NSLog(@"apple dealloc %p", self);
}

@end
