//
//  ImageCache.m
//  zup
//
//  Created by Igor Lira on 11/26/14.
//  Copyright (c) 2014 ntxdev. All rights reserved.
//

#import "ImageCache.h"

@implementation ImageCache

static ImageCache* _defaultCache = nil;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self->images = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (ImageCache*)defaultCache
{
    if (!_defaultCache)
        _defaultCache = [[ImageCache alloc] init];
    
    return _defaultCache;
}

- (UIImage*)imageWithId:(int)imageid
{
    NSString* key = [[NSNumber numberWithInt:imageid] stringValue];
    return [self->images valueForKey:key];
}
- (void)addImage:(UIImage*)image withId:(int)imageid
{
    NSString* key = [[NSNumber numberWithInt:imageid] stringValue];
    [self->images setValue:image forKey:key];
}

@end
