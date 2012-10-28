//
//  Apple.h
//  CDParse
//
//  Created by Connor Duggan on 2012-10-28.
//  Copyright (c) 2012 Connor Duggan. All rights reserved.
//

#import <Parse/Parse.h>
#import "Banana.h"

@interface Apple : PFObject

@property (nonatomic, strong) Banana * banana;

@end
