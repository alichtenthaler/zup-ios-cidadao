//
//  ImageCache.h
//  zup
//
//  Created by Igor Lira on 11/26/14.
//  Copyright (c) 2014 ntxdev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageCache : NSObject
{
    NSMutableDictionary* images;
}

+ (ImageCache*)defaultCache;
- (UIImage*)imageWithId:(int)imageid;
- (void)addImage:(UIImage*)image withId:(int)imageid;

@end
