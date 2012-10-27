//
//  PFObject+More.m
//  CDParse
//
//  Created by Connor Duggan on 12-08-05.
//  Copyright (c) 2012 Connor Duggan. All rights reserved.
//

#import "PFObject+More.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation PFObject (More)

+(void)load
{
    Method parseMethod = class_getInstanceMethod(PFObject.class, @selector(saveInBackgroundWithBlock:));
    class_addMethod(PFObject.class, @selector(_saveInBackgroundWithBlock:), method_getImplementation(parseMethod), method_getTypeEncoding(parseMethod));
    method_setImplementation(parseMethod, (IMP)savingIMP);
}

static char savingKey;

static void savingIMP(id self, SEL _cmd, ...)
{    
    objc_setAssociatedObject(self, &savingKey, @(YES), OBJC_ASSOCIATION_RETAIN);
    
    PFBooleanResultBlock block;
    
    va_list vl;
    va_start(vl, _cmd);
    
    block = va_arg(vl, PFBooleanResultBlock);
    
    void (*objc_msgSendTyped)(id self, SEL _cmd, PFBooleanResultBlock block) = (void*)objc_msgSend;
    
    objc_msgSendTyped(self, @selector(_saveInBackgroundWithBlock:), ^(BOOL succeeded, NSError *error)
                      {
                          objc_setAssociatedObject(self, &savingKey, @(NO), OBJC_ASSOCIATION_RETAIN);
                          
                          if(block)
                          {
                              block(succeeded, error);
                          }
                      });
}

-(BOOL)saving
{    
    return [(NSNumber *)objc_getAssociatedObject(self, &savingKey) boolValue];
}
