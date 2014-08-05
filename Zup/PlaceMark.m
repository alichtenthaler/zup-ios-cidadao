//
//  PlaceMark.m
//  Zup
//
//  Created by Renato Kuroe on 27/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "PlaceMark.h"

@implementation PlaceMark

@synthesize coordinate;
@synthesize markTitle, markSubTitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate andMarkTitle:(NSString *)theMarkTitle andMarkSubTitle:(NSString *)theMarkSubTitle {
	coordinate = theCoordinate;
    markTitle = theMarkTitle;
    markSubTitle = theMarkSubTitle;
    
	return self;
}

- (NSString *)title {
    return markTitle;
}

- (NSString *)subtitle {
    return markSubTitle;
}


@end
