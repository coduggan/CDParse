//
//  PFObject+More.h
//  CDParse
//
//  Created by Connor Duggan on 12-08-05.
//  Copyright (c) Connor Duggan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFObject (CDParse)

-(id)initWithObject:(PFObject*)object;
-(PFObject*)object;

-(BOOL)saving;

@end
