//
//  ExploreViewController.h
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MapKit/MapKit.h>
#import "FiltrarViewController.h"
#import "SearchTableViewController.h"


@interface ExploreViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate> {
    CustomButton *btFilter;
    UIView *viewLogo;
    SearchTableViewController *searchTable;
    CLLocationCoordinate2D currentCoordinate;
    GMSMarker *markerSearch;
    BOOL isMoving;
    GMSCoordinateBounds *boundsCurrent;
    FiltrarViewController *filtrarVC;
    BOOL isFromSolicit;
    BOOL initializing;
}

@property (nonatomic) BOOL isFromOtherTab;
@property (nonatomic) BOOL isInventoryLoading;
@property (nonatomic) BOOL isReportsLoading;
@property (nonatomic) BOOL isNoReports;
@property (nonatomic) BOOL isNoInventories;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *arrMain;
@property (nonatomic, strong) NSMutableArray *arrMainInventory;
@property (nonatomic, strong) NSMutableArray *arrMarkers;
@property (nonatomic, strong) NSMutableArray *arrFilterIDs;
@property (nonatomic, strong) NSMutableArray *arrFilterInventoryIDs;
@property (retain, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearchBox;
@property (nonatomic)  int statusToFilterId;
@property (nonatomic)  BOOL isFromFilter;
@property (nonatomic)  BOOL isDayFilter;
@property (nonatomic)  BOOL isGoToReportDetail;
@property (nonatomic)  int dayFilter;
@property (nonatomic)  int idCreatedReport;
@property (retain, nonatomic) NSString *currentInventoryId;

- (void)createPoints;
- (void)createInventoryPoints;
- (void)requestWithNewPosition;
- (void)initMap;

- (void)setLocationWithClLocation:(CLLocationCoordinate2D)coordinate zoom:(int)newZoom;
- (void)moveSearchBarIsTop:(BOOL)isTop;
- (void)getInventoryListForId:(int)idCategory;
- (void)getMarkersForLocation:(CLLocationCoordinate2D)location;
- (void)setPositionMarkerForSearch;
- (void)buildDetail:(NSDictionary*)dict;

@end