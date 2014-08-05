//
//  CustomMap.h
//  Zup
//
//  Created by Renato Kuroe on 26/01/14.
//  Copyright (c) 2014 Renato Kuroe. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface CustomMap : GMSMapView

- (void)setPositionWithLocation:(CLLocationCoordinate2D)coordinate andCategory:(int)idCategory isReport:(BOOL)isReport;

@end
