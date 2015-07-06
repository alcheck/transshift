//
//  NSObject+DataObject.m
//  TransmissionRPCClient
//
//  Created by Alexey Chechetkin on 03.07.15.
//  Copyright (c) 2015 Alexey Chechetkin. All rights reserved.
//

#import "NSObject+DataObject.h"
#import <objc/runtime.h>

@implementation NSObject(AssosiatedObject)

@dynamic dataObject;

- (id)dataObject
{
    return objc_getAssociatedObject(self, @selector(dataObject));
}

- (void)setDataObject:(id)dataObject
{
    objc_setAssociatedObject(self, @selector(dataObject), dataObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
