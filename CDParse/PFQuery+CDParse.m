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

+(void)load
{
    Method parseFindObjectsInBackgroundWithBlockMethod = class_getInstanceMethod(PFQuery.class, @selector(findObjectsInBackgroundWithBlock:));
        
    class_addMethod(PFQuery.class, @selector(_findObjectsInBackgroundWithBlock:), method_getImplementation(parseFindObjectsInBackgroundWithBlockMethod), method_getTypeEncoding(parseFindObjectsInBackgroundWithBlockMethod));
    method_setImplementation(parseFindObjectsInBackgroundWithBlockMethod, (IMP)findObjectsInBackgroundWithBlockIMP);
}

static void findObjectsInBackgroundWithBlockIMP(id self, SEL _cmd, ...)
{
    PFArrayResultBlock block;
    
    va_list vl;
    va_start(vl, _cmd);
    
    block = va_arg(vl, PFArrayResultBlock);
    
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

    
}


@end
