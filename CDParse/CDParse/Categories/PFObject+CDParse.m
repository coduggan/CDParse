//
//  PFObject+More.m
//  CDParse
//
//  Created by Connor Duggan on 12-08-05.
//  Copyright (c) 2012 Connor Duggan. All rights reserved.
//

#import "PFObject+CDParse.h"

#import <objc/runtime.h>
#import <objc/message.h>


@implementation PFObject (CDParse)


+(void)load
{
    Method parseMethod = class_getInstanceMethod(PFObject.class, @selector(saveInBackgroundWithBlock:));
    class_addMethod(PFObject.class, @selector(_saveInBackgroundWithBlock:), method_getImplementation(parseMethod), method_getTypeEncoding(parseMethod));
    method_setImplementation(parseMethod, (IMP)savingIMP);
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSString *sel = NSStringFromSelector(selector);
    if ([sel rangeOfString:@"set"].location == 0)
    {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    else
    {
        return [NSMethodSignature signatureWithObjCTypes:"@@:"];
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    NSString * key = NSStringFromSelector([invocation selector]);
    
    if ([key rangeOfString:@"set"].location == 0)
    {
        key = [[key substringWithRange:NSMakeRange(3, [key length]-4)] lowercaseString];
        NSString *obj;
        [invocation getArgument:&obj atIndex:2];
        
        [self setObject:obj forKey:key];
    }
    else
    {
        NSString * obj = [self objectForKey:key];
        [invocation setReturnValue:&obj];
    }
}

-(id)init
{
    if([self.class isSubclassOfClass:PFObject.class])
    {
        return [self initWithClassName:NSStringFromClass(self.class)];
    }
    
    return [super init];
}

static char objectKey;

-(id)initWithObject:(PFObject*)object
{
    if((self = [self initWithClassName:object.className]))
    {        
        objc_setAssociatedObject(self, &objectKey, object, OBJC_ASSOCIATION_RETAIN);
                
        for(id key in object.allKeys)
        {
            id subObject = [object objectForKey:key];
            
            Class subObjectClass = NSClassFromString([subObject className]);
            
            if([subObjectClass isSubclassOfClass:PFObject.class])
            {
                subObject = [[subObjectClass alloc] initWithObject:subObject];
            }
            
            [self setObject:subObject forKey:key];
        }
    

        [self setValue:object.objectId forKey:@"objectId"];
        
        [self setValue:object.createdAt forKey:@"createdAt"];
        [self setValue:object.updatedAt forKey:@"updatedAt"];
        [self setValue:object.className forKey:@"className"];
    }
    
    return self;
}

-(PFObject*)object
{
    if([self isMemberOfClass:PFObject.class])
    {
        return self;
    }
    
    return objc_getAssociatedObject(self, &objectKey);
}


static char savingKey;

static void savingIMP(id self, SEL _cmd, ...)
{    
    objc_setAssociatedObject(self, &savingKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
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

+(PFQuery*)query
{
    if([self.class isSubclassOfClass:PFObject.class])
    {
        return [PFQuery queryWithClassName:NSStringFromClass(self.class)];
    }
    
    return nil;
}

@end