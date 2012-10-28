//
//  PFQuery+More.m
//  CDParse
//
//  Created by Connor Duggan on 2012-10-26.
//  Copyright (c) 2012 Connor Duggan. All rights reserved.
//

#import <Parse/Parse.h>

#import "PFQuery+CDParse.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation PFQuery (CDParse)

+(void)replaceMethodWithSelector:(SEL)selector withBlock:(id)block
{
    Method method = class_getInstanceMethod(self.class, selector);
    class_addMethod(PFQuery.class, NSSelectorFromString([@"_" stringByAppendingString:NSStringFromSelector(selector)]), method_getImplementation(method), method_getTypeEncoding(method));
    
    method_setImplementation(method, imp_implementationWithBlock(block));
}


+(void)load
{
    [self replaceMethodWithSelector:@selector(findObjectsInBackgroundWithBlock:)
                          withBlock:
     ^(id self, PFArrayResultBlock block)
    {
        void (*objc_msgSendTyped)(id self, SEL _cmd, PFArrayResultBlock block) = (void*)objc_msgSend;
        
        objc_msgSendTyped(self, @selector(_findObjectsInBackgroundWithBlock:), ^(NSArray *objects, NSError *error)
                          {
                              NSMutableArray * subclassObjects = [NSMutableArray arrayWithCapacity:objects.count];
                              
                              if(block)
                              {
                                  for(PFObject * object in objects)
                                  {
                                      Class ObjectClass = NSClassFromString(object.className);
                                      
                                      if([ObjectClass isSubclassOfClass:PFObject.class])
                                      {
                                          id subclassObject = [[ObjectClass alloc] initWithObject:object];
                                          
                                          [subclassObjects addObject:subclassObject];
                                      }
                                      else
                                      {
                                          [subclassObjects addObject:object];
                                      }
                                  }
                                  
                                  block([subclassObjects copy], error);
                              }
                          });
    }];
}




@end
