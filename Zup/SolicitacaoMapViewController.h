//
//  SolicitacaoMapViewController.h
//  Zup
//
//  Created by Renato Kuroe on 26/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SolicitacaoPhotoViewController.h"
#import "SearchTableViewController.h"

@interface SolicitacaoMapViewController : UIViewController<CLLocationManagerDelegate, UISearchBarDelegate, GMSMapViewDelegate, UITextFieldDelegate, UITextViewDelegate> {
    GMSMarker *userMarker;
    SolicitacaoPhotoViewController *photoView;
    SearchTableViewController *searchTable;
    UIImage *imageCurrentMarker;
    UIImage *imageInventoryMarker;
    NSString *strCurrentInventoryId;
    GMSMarker *currentInventoryMarker;
    GMSMarker *markerSearch;
    GMSCoordinateBounds *boundsCurrent;

    CustomButton * btFilter;
    
    float zoomCurrent;
    BOOL isEditingNumber;
    BOOL isGettingLocation;
    NSTimer *timerLoadingAddress;
    NSTimer *timerPlaceholder;
    
    BOOL isSearch;
}

@property (weak, nonatomic) IBOutlet UITextView *tvReferencia;
@property (strong, nonatomic) UIImageView *imageMarkerPositionCenter;
@property (weak, nonatomic) IBOutlet UITextField *tfNumber;
@property (weak, nonatomic) IBOutlet UIView *viewSearchBar;

@property (strong, nonatomic) NSString *catStr;
@property (strong, nonatomic) NSString *catID;
@property (nonatomic, retain) NSDictionary *dictMain;

@property (strong, nonatomic) UIImage *imgIcon;

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet CustomButton *btNext;

@property (nonatomic, strong) NSMutableArray *arrMainInventory;
@property (nonatomic, strong) NSMutableArray *arrMarkers;

- (IBAction)btNext:(id)sender;
- (void)setMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)setLocationWithCoordinate:(CLLocationCoordinate2D)coordinate zoom:(int)zoom;
- (void)moveSearchBarIsTop:(BOOL)isTop;
- (void)getIventoryPoints;
- (void)setPositionMarkerForSearch;
- (void)closeSearchTable;

@end

