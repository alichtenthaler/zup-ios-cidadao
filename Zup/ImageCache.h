//
//  ImageCache.h
//  zup
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
