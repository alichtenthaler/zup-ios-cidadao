//
//  ExploreViewController.m
//  Zup
//

#import "ExploreViewController.h"
#import "ListExploreViewController.h"
#import "PerfilDetailViewController.h"
#import "InfoWindow.h"
#import "AppDelegate.h"

int ZOOMLEVELDEFAULT = 16;

ServerOperations *serverOperationsReport;
ServerOperations *serverOperationsInventory;
ServerOperations *serverOperationsInventoryList;

GMSMarker *currentMarker;
CLLocationCoordinate2D currentCoord;

@interface ExploreViewController ()

@end

@implementation ExploreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self->initializing = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self->initializing = YES;
    
    [self initMap];
    
    NSString* imageName = [NSString stringWithFormat:@"explore_logo_%@", [Utilities getCurrentTenant]];
    UIImage* logoImage = [UIImage imageNamed:imageName];
    if(!logoImage)
        logoImage = [UIImage imageNamed:@"explore_logo"];
    
    // Calcular largura da imagem redimensionada
    float height = MIN(logoImage.size.height, 22.0f);
    int hwidth = (logoImage.size.width / logoImage.size.height) * height;

    viewLogo = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width/2 - hwidth/2, (44-height)/2/*14*/, hwidth, height)];
    UIImageView *image = [[UIImageView alloc]initWithImage:logoImage];
    image.frame = CGRectMake(0, 0, hwidth, 22);
    image.contentMode = UIViewContentModeScaleAspectFit;
    [viewLogo addSubview:image];
    [self.navigationController.navigationBar addSubview:viewLogo];
    
    /*UIView* viewHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, self.view.bounds.size.width/2 - 34, 44)];
    viewHeader.contentMode = UIViewContentModeScaleAspectFit;
    viewHeader.backgroundColor = [UIColor redColor];
    image = [[UIImageView alloc]initWithImage:[Utilities getTenantHeaderImage]];
    [viewHeader addSubview:image];
    [self.navigationController.navigationBar addSubview:viewHeader];*/
    
    viewHeader = [[UIImageView alloc]initWithImage:[Utilities getTenantHeaderImage]];
    // Calcular largura da imagem redimensionada
    int width = (viewHeader.image.size.width / viewHeader.image.size.height) * 34.0f;
    int realwidth = MIN(self.view.bounds.size.width/2 - 64, width);
    
    viewHeader.frame = CGRectMake(10, 5, realwidth, 44 - 10); // self.view.bounds.size.width/2 - 64
    viewHeader.contentMode = UIViewContentModeScaleAspectFit;
    [self.navigationController.navigationBar addSubview:viewHeader];
    
    [self.searchBar setBackgroundImage:[UIImage new]];
    [self.searchBar setDelegate:self];
    [self.mapView setDelegate:self];
    [self.mapView setMyLocationEnabled:YES];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    if (![Utilities isIOS7]) {
        [[UISearchBar appearance]setTintColor:[UIColor whiteColor]];
    }
    
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[Utilities fontOpensSansWithSize:15]];
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action:@selector(didPan:)];
    self.mapView.gestureRecognizers = @[panRecognizer];
    
}

- (void)initMap {
    self.isNoInventories = YES;
    
    self.arrFilterIDs = [[NSMutableArray alloc]init];
    self.arrFilterInventoryIDs = [[NSMutableArray alloc]init];
    self.arrMain = [[NSMutableArray alloc]init];
    self.arrMainInventory = [[NSMutableArray alloc]init];
    self.arrMarkers = [[NSMutableArray alloc]init];
    
    [self getCurrentLocation];

    if(initializing)
    {
        int zoom;
        if ([Utilities isIpad])
            zoom = ZOOMLEVELDEFAULT;
        else
            zoom = ZOOMLEVELDEFAULT;
        
        CLLocationCoordinate2D coordinate = [Utilities getTenantInitialLocation];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                                longitude:coordinate.longitude
                                                                     zoom:zoom];
        
        
        self.mapView.camera = camera;
        [self.mapView clear];
        
        
        [self requestWithNewPosition];
        
        initializing = NO;
    }
}

- (void)didPan:(UIPanGestureRecognizer*)pan {
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [self performSelector:@selector(requestWithNewPosition) withObject:nil afterDelay:0];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    [btFilter removeFromSuperview];
    [viewLogo setHidden:YES];
    [viewHeader setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
        
    btFilter = [[CustomButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 65, 5, 60, 35)];
    [btFilter setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_normal-1"] forState:UIControlStateNormal];
    [btFilter setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_active-1"] forState:UIControlStateHighlighted];
    [btFilter setFontSize:14];
    [btFilter setTitle:@"Filtrar" forState:UIControlStateNormal];
    [btFilter addTarget:self action:@selector(btFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:btFilter];
    
    [viewLogo setHidden:NO];
    [viewHeader setHidden:NO];
    
    if (isFromSolicit) {
        [self.arrMarkers removeAllObjects];
        [self requestWithNewPosition];
        isFromSolicit = NO;
    }
    
    if (self.isFromOtherTab) {
        self.isFromOtherTab = NO;
        [self.arrMarkers removeAllObjects];
       // [self requestWithNewPosition];
        [self createInventoryPoints];
        [self createPoints];
    }
    
    [self performSelector:@selector(tryToShowPendingReport) withObject:nil afterDelay:1.0f];
}

- (void)tryToShowPendingReport
{
    AppDelegate* delegate = (AppDelegate*) [UIApplication sharedApplication].delegate;
    if(delegate.pendingReport)
    {
        [self buildDetail:delegate.pendingReport];
        //[[NSNotificationCenter defaultCenter]postNotificationName:@"backToMap" object:nil userInfo:delegate.pendingReport];
        
        delegate.pendingReport = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btFilter:(id)sender {
    
    
    if (!filtrarVC) {
        filtrarVC = [[FiltrarViewController alloc]initWithNibName:@"FiltrarViewControllerNovo" bundle:nil];
    }
    filtrarVC.exploreView = self;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:filtrarVC];
    [nav.navigationBar setTranslucent:NO];
    
    if ([Utilities isIpad]) {
        [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    
    [self presentViewController:nav animated:YES completion:nil];
    
    if ([Utilities isIpad]) {
        nav.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
        [nav.view.superview setBackgroundColor:[UIColor clearColor]];
    }
    
    [filtrarVC viewWillAppear:YES];
    
    //[self viewWillAppear:YES];
}

#pragma mark - Core Location

- (void)getCurrentLocation {
    self.locationManager = [[CLLocationManager alloc] init];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    
    CLLocation *location = [self.locationManager location];
    currentCoordinate = [location coordinate];
    
//    #warning TESTE
//    currentCoordinate = CLLocationCoordinate2DMake(-23.557040, -46.638610);
    
    int zoom;
    if ([Utilities isIpad])
        zoom = ZOOMLEVELDEFAULT;
    else
        zoom = ZOOMLEVELDEFAULT;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:zoom];
    
    
    self.mapView.camera = camera;
    [self.mapView clear];
    
    
    [self requestWithNewPosition];
    
}

- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations {
    
    CLLocation *location = [self.locationManager location];
    currentCoordinate = [location coordinate];
    
    int zoom;
    if ([Utilities isIpad])
        zoom = ZOOMLEVELDEFAULT;
    else
        zoom = ZOOMLEVELDEFAULT;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:zoom];
    
    
    self.mapView.camera = camera;
    [self.mapView clear];
    
    
    [self requestWithNewPosition];
    
//    if (currentCoordinate.latitude == 0) {
//        [self getCurrentLocation];
//    } else {
        [self.locationManager stopUpdatingLocation];
//    }
}

- (void)setLocationWithClLocation:(CLLocationCoordinate2D)coordinate zoom:(int)newZoom{
    
    int zoom;
    if ([Utilities isIpad])
        zoom = ZOOMLEVELDEFAULT + 2;
    else
        zoom = ZOOMLEVELDEFAULT;
    
    if (newZoom != 0) {
        zoom = newZoom;
    }
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:zoom];
    
    
    self.mapView.camera = camera;
    
    currentCoordinate = coordinate;
    [self getPoints];
    
    [self.searchBar resignFirstResponder];
}

- (void)setIsFromOtherTab:(BOOL)isFromOtherTab
{
    
}

#pragma mark - Get Reports

- (void)getPoints {
    
    if ([Utilities isInternetActive]) {
        
        _isReportsLoading = YES;
        
        int radius = self.mapView.camera.zoom;
        radius = 21 - radius;
        
        if ([Utilities isIpad]) {
            radius = radius * 2000;
        } else {
            radius = radius * 1400;
        }
        
        GMSVisibleRegion visibleRegion = [[self.mapView projection] visibleRegion];
        double distance = [self getDistance:visibleRegion.nearRight p2:visibleRegion.nearLeft];
        
        [serverOperationsReport CancelRequest];
        serverOperationsReport = nil;
        
        serverOperationsReport = [[ServerOperations alloc]init];
        [serverOperationsReport setTarget:self];
        [serverOperationsReport setAction:@selector(didReceiveData:)];
        [serverOperationsReport setActionErro:@selector(didReceiveError:data:)];
        [serverOperationsReport getReportItemsForPosition:currentCoordinate.latitude longitude:currentCoordinate.longitude radius:distance zoom:self.mapView.camera.zoom];
    }
}

- (void)clearMap
{
    [self.arrMain removeAllObjects];
    
    for(GMSMarker* marker in self.arrMarkers)
    {
        marker.map = nil;
    }
    
    [self.arrMarkers removeAllObjects];
}

- (void)didReceiveData:(NSData*)data {
    
    _isReportsLoading = NO;
    
    if(self.isNoReports)
        return;
    
    [self clearMap];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *arr = [dict valueForKey:@"reports"];
    NSArray* arrClusters = [dict valueForKey:@"clusters"];
    
    for (NSDictionary *dict in arr) {
        if (![self.arrMain containsObject:dict]) {
            [self.arrMain addObject:dict];
        }
    }
    
    int maxCount = 0;
    if ([Utilities isIpad] || [Utilities isIphone4inch]) maxCount = maxMarkersCountiPhone5iPad;
    else maxCount = maxMarkersCountiPhone4;
    
    NSUInteger markersCount = [self.arrMain count];
    if (markersCount > maxCount) {
        unsigned long markersToRemove = self.arrMain.count - maxCount;
        
        for (int i = 0; i < markersToRemove; i ++) {
            
            NSDictionary *dict = [self.arrMain objectAtIndex:0];
            
            int markerId = [[dict valueForKey:@"id"]intValue];
            
            NSArray *arr = [NSArray arrayWithArray:self.arrMarkers];
            for (GMSMarker *tempMarker in arr) {
                int tempMarkerId = [[tempMarker.userData valueForKey:@"id"]intValue];
                if (tempMarkerId == markerId) {
                    tempMarker.map = nil;
                    [self.arrMarkers removeObject:tempMarker];
                }
            }
            
            [self.arrMain removeObjectAtIndex:0];
            
        }
        
    }
    
    [self createPoints];
    [self createPointsForClusters:arrClusters inventory:NO];
}

- (void)didReceiveError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
    _isReportsLoading = NO;
}

- (void)createPointsForClusters:(NSArray*)clusters inventory:(BOOL)inv
{
    for(NSDictionary* cluster in clusters)
    {
        float lat = [[[cluster valueForKeyPath:@"position"] objectAtIndex:0] floatValue];
        float lon = [[[cluster valueForKeyPath:@"position"] objectAtIndex:1] floatValue];
        
        GMSMarker* marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(lat, lon);
        marker.map = self.mapView;
        
        UIImage* img = [Utilities iconForCluster:cluster inventory:inv];
        img = [Utilities imageWithImage:img scaledToSize:CGSizeMake(img.size.width/2, img.size.height/2)];
        marker.icon = img;
        marker.userData = @{ @"isCluster": @YES };
        
        [self.arrMarkers addObject:marker];
    }
}

- (void)createPoints {
    
    for (NSDictionary *dict in self.arrMain) {
        
        if (self.arrFilterIDs.count > 0) {
            
            int intId = [[dict valueForKey:@"category_id"]intValue];
            NSNumber *numberId = [NSNumber numberWithInt:intId];
            
            int daysPassed = [Utilities calculateDaysPassed:[dict valueForKey:@"created_at"]];
            
            BOOL isDayFiltered = NO;
            
            if (self.isDayFilter) {
                if (self.dayFilter > daysPassed) {
                    isDayFiltered = YES;
                }
            } else {
                isDayFiltered = YES;
            }
            
            int statusId = [[dict  valueForKey:@"status_id"]intValue];
            
            if ([self.arrFilterIDs containsObject:numberId] && (statusId == self.statusToFilterId || self.statusToFilterId == 0) && isDayFiltered) {
                
                [self setLocationWithCoordinate:dict];
            }
            else
            {
                NSLog(@"Some condition");
            }
        } else {
            if (!self.isNoReports) {
                [self setLocationWithCoordinate:dict];
            }
        }
    }
    
    if (self.isGoToReportDetail) {
        
        for (GMSMarker *marker in self.arrMarkers) {
            NSDictionary *dict = marker.userData;
            if ([[dict valueForKey:@"id"]intValue] == self.idCreatedReport) {
                [self gotoDetail:marker];
            }
        }
        self.isGoToReportDetail = NO;
    }
    
}

#pragma mark - Get Inventory

- (double)mtorad:(double)x
{
    return x * M_PI / (double)180;
}

- (double)getDistance:(CLLocationCoordinate2D)p1 p2:(CLLocationCoordinate2D)p2
{
    double R = 6378137; // Earth’s mean radius in meter
    double dLat = [self mtorad:p2.latitude - p1.latitude];
    double dLong = [self mtorad:p2.longitude - p1.longitude];
    double a = sin(dLat / 2) * sin(dLat / 2) +
    cos([self mtorad:p1.latitude]) * cos([self mtorad:p1.longitude]) *
    sin(dLong / 2) * sin(dLong / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double d = R * c;
    
    return d; // returns the distance in meter
}

- (void)getIventoryPoints {
    if ([Utilities isInternetActive]) {
        
        CGPoint point = self.mapView.center;
        point.y -= 60;
        currentCoord = [self.mapView.projection coordinateForPoint:point];
        
        _isInventoryLoading = YES;
        
        int radius = self.mapView.camera.zoom;
        radius = 21 - radius;
        if ([Utilities isIpad]) {
            radius = radius * 2000;
        } else {
            radius = radius * 1400;
        }
        
        GMSVisibleRegion visibleRegion = [[self.mapView projection] visibleRegion];
        double distance = [self getDistance:visibleRegion.nearRight p2:visibleRegion.nearLeft];
        
        [serverOperationsInventory CancelRequest];
        serverOperationsInventory = nil;
        
        serverOperationsInventory = [[ServerOperations alloc]init];
        [serverOperationsInventory setTarget:self];
        [serverOperationsInventory setAction:@selector(didReceiveInventoryData:operation:)];
        [serverOperationsInventory setActionErro:@selector(didReceiveIventoryError:data:)];
        
        if (self.arrFilterInventoryIDs.count == 0) {
            [serverOperationsInventory getItemsForPosition:currentCoordinate.latitude longitude:currentCoordinate.longitude radius:distance zoom:self.mapView.camera.zoom];

        } else {
            [serverOperationsInventory getItemsForPosition:currentCoordinate.latitude longitude:currentCoordinate.longitude radius:distance zoom:self.mapView.camera.zoom categoryIds:self.arrFilterInventoryIDs];

        }
        
    }
}

- (void)didReceiveInventoryData:(NSData*)data operation:(TIRequestOperation*)operation {
    
    _isInventoryLoading = NO;
    
    if(self.isNoInventories)
        return;
    
    [self clearMap];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    NSArray *arr = [dict valueForKey:@"items"];
    
    for (NSDictionary *dict in arr) {
        if (![self.arrMainInventory containsObject:dict]) {
            [self.arrMainInventory addObject:dict];
        }
    }
    
    NSArray* clusters = [dict valueForKey:@"clusters"];
    
    
    [self createInventoryPoints];
    [self createPointsForClusters:clusters inventory:YES];
}

- (void)didReceiveIventoryError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
    _isInventoryLoading = NO;
}

- (void)createInventoryPoints {
    
    
    for (NSDictionary *dict in self.arrMainInventory) {
        
        if (self.arrFilterInventoryIDs.count > 0) {
            
            int intId = [[dict valueForKey:@"inventory_category_id"]intValue];
            NSNumber *numberId = [NSNumber numberWithInt:intId];
            
            
            if ([self.arrFilterInventoryIDs containsObject:numberId]) {
                [self setLocationWithCoordinate:dict];
            }
        }
        else if (!self.isFromFilter){
            if (!self.isNoInventories) {
                [self setLocationWithCoordinate:dict];
            }
        }
        
    }
    
}

- (void)getMarkersForLocation:(CLLocationCoordinate2D)location {
    currentCoordinate = location;
    
    [self getPoints];
    [self getIventoryPoints];
}

- (void)setMarkerInventoryWithCoordinate:(CLLocationCoordinate2D)coordinate
                                 snippet:(NSString*)snippet
                               draggable:(BOOL)draggable
                                    type:(int)type
                                userData:(NSDictionary*)dict{
    
    
    NSDictionary *catDict = [UserDefaults getInventoryCategory:[[dict valueForKey:@"inventory_category_id"]intValue]];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.title =  [catDict valueForKey:@"title"];
    //    marker.snippet = snippet;
    marker.draggable = draggable;
    marker.userData = dict;
    [marker setInfoWindowAnchor:CGPointMake(0.4, 0.1)];
    [marker setAppearAnimation:kGMSMarkerAnimationNone];
    
    UIImage *img;
    if([[catDict valueForKey:@"plot_format"] isEqualToString:@"marker"])
        img = [UIImage imageWithData:[catDict valueForKey:@"markerData"]];
    else
        img = [UIImage imageWithData:[catDict valueForKey:@"pinData"]];
    
    img = [Utilities imageWithImage:img scaledToSize:CGSizeMake(img.size.width/2, img.size.height/2)];
    marker.icon = img;
    
    int markerId = [[marker.userData valueForKey:@"id"]intValue];
    
    for (GMSMarker *tempMarker in self.arrMarkers) {
        int tempMarkerId = [[tempMarker.userData valueForKey:@"id"]intValue];
        if (tempMarkerId == markerId) {
            return;
        }
    }
    
    marker.Map = self.mapView;
    [self.arrMarkers addObject:marker];
}

#pragma mark - Get Inventory List


- (void)getInventoryListForId:(int)idCategory {
    
    
    if ([Utilities isInternetActive]) {
        
        [serverOperationsInventoryList CancelRequest];
        serverOperationsInventoryList = nil;
        
        serverOperationsInventoryList = [[ServerOperations alloc]init];
        [serverOperationsInventoryList setTarget:self];
        [serverOperationsInventoryList setAction:@selector(didReceiveData:)];
        [serverOperationsInventoryList setActionErro:@selector(didReceiveError:data:)];
        [serverOperationsInventoryList getInventoryForIdCategory:idCategory];
    }
}

- (void)didReceiveInventoryListData:(NSData*)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    self.arrMain = [[NSMutableArray alloc]initWithArray:[dict valueForKey:@"items"]];
    [self createInventoryPoints];
}

- (void)didReceiveInventoryListError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
}


#pragma mark - Map Handle

- (void)setLocationWithCoordinate:(NSDictionary*)dict{
    
    NSString *latStr = [dict valueForKeyPath:@"position.latitude"];
    
    NSString *lngStr = [dict valueForKeyPath:@"position.longitude"];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latStr.floatValue, lngStr.floatValue);
    
    if ([dict valueForKey:@"inventory_category_id"]) {
        [self setMarkerInventoryWithCoordinate:coord snippet:nil draggable:NO type:[[dict valueForKey:@"inventory_category_id"]intValue] userData:dict];
    } else {
        [self setMarkerWithCoordinate:coord snippet:nil draggable:NO type:[[dict valueForKey:@"category_id"]intValue] userData:dict];
        
    }
    
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    if([[[marker userData] valueForKey:@"isCluster"] boolValue])
        return nil;
    
    InfoWindow *view = [[InfoWindow alloc]initWithNibName:@"InfoWindow" bundle:nil];
    [view.view setFrame:CGRectMake(0, 0, 219, 57)];
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"map_popover_inteiro"]];
    [view.view addSubview:img];
    [view.view sendSubviewToBack:img];
    view.lbltitle.text = marker.title;
    
    return view.view;
}

- (void)setMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate
                        snippet:(NSString*)snippet
                      draggable:(BOOL)draggable
                           type:(int)type
                       userData:(NSDictionary*)dict{
    
    
    NSDictionary *catDict = [UserDefaults getCategory:[[dict valueForKey:@"category_id"]intValue]];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = coordinate;
    marker.title =  [catDict valueForKey:@"title"];
    //    marker.snippet = snippet;
    marker.draggable = draggable;
    marker.userData = dict;
    [marker setInfoWindowAnchor:CGPointMake(0.4, 0.1)];
    [marker setAppearAnimation:kGMSMarkerAnimationNone];
    
    UIImage *img = [UIImage imageWithData:[catDict valueForKey:@"markerData"]];
    img = [Utilities imageWithImage:img scaledToSize:CGSizeMake(img.size.width/2, img.size.height/2)];
    marker.icon = img;
    
    int markerId = [[marker.userData valueForKey:@"id"]intValue];
    
    for (GMSMarker *tempMarker in self.arrMarkers) {
        int tempMarkerId = [[tempMarker.userData valueForKey:@"id"]intValue];
        if (tempMarkerId == markerId) {
            return;
        }
    }
    marker.Map = self.mapView;
    [self.arrMarkers addObject:marker];
}


- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if([[[marker userData] valueForKey:@"isCluster"] boolValue])
    {
        GMSCameraPosition* camera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude
                                                                longitude:marker.position.longitude
                                                                     zoom:self.mapView.camera.zoom + 1];
        
        [self.mapView animateToCameraPosition:camera];
        [self mapView:mapView didChangeCameraPosition:camera];
        
        return NO;
    }
    
    isMoving = YES;
    
    return NO;
}


- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker {
    
    [self gotoDetail:marker];
    
}

- (void)gotoDetail:(GMSMarker*)marker {
    
    NSDictionary *dict = marker.userData;
    
    if (![dict valueForKey:@"inventory_category_id"]) {
        
        NSString *nibName = nil;
        if ([Utilities isIpad]) {
            nibName = @"PerfilDetailViewController_iPad";
        } else {
            nibName = @"PerfilDetailViewController";
        }
        
        PerfilDetailViewController *perfilDetailVC = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
        perfilDetailVC.isFromExplore = YES;
        perfilDetailVC.dictMain = marker.userData;
        
        BOOL animated;
        
        if (self.isGoToReportDetail) {
            animated = NO;
        } else
            animated = YES;
        
        [self.navigationController pushViewController:perfilDetailVC animated:YES];
    } else {
        ListExploreViewController *listVC = [[ListExploreViewController alloc]initWithNibName:@"ListExploreViewController" bundle:nil];
        listVC.isColeta = YES;
        listVC.strTitle = marker.title;
        listVC.dictMain = marker.userData;
        
        [self.navigationController pushViewController:listVC animated:YES];
    }
    
}

- (void)buildDetail:(NSDictionary*)dict {
    
    [btFilter setHidden:YES];
    
    if (![self.navigationController.visibleViewController isKindOfClass:[ExploreViewController class]]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    
    
    NSString *latStr = [dict valueForKeyPath:@"position.latitude"];
    NSString *lngStr = [dict valueForKeyPath:@"position.longitude"];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latStr.floatValue, lngStr.floatValue);
    
    currentCoordinate = coord;
    
    isFromSolicit = YES;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:currentCoordinate.latitude
                                                            longitude:currentCoordinate.longitude
                                                                 zoom:16];
    
    
    self.mapView.camera = camera;
        
    if (![dict valueForKey:@"inventory_category_id"]) {

        NSString *nibName = nil;
        if ([Utilities isIpad]) {
            nibName = @"PerfilDetailViewController_iPad";
        } else {
            nibName = @"PerfilDetailViewController";
        }
        
        PerfilDetailViewController *perfilDetailVC = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
        perfilDetailVC.isFromExplore = YES;
        perfilDetailVC.dictMain = dict;
        perfilDetailVC.exploreVC = self;
        
        BOOL animated;
        
        if (self.isGoToReportDetail) {
            animated = NO;
        } else
            animated = YES;
        
        perfilDetailVC.navCtrl = self.navigationController;
        [perfilDetailVC viewWillAppear:YES];

        [self.navigationController pushViewController:perfilDetailVC animated:YES];
    } else {
        ListExploreViewController *listVC = [[ListExploreViewController alloc]init];
        listVC.isColeta = YES;
        listVC.dictMain = dict;

        [self.navigationController pushViewController:listVC animated:YES];
    }
    

}

- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    
    currentMarker = marker;
    currentCoordinate = marker.position;
    
    
}

- (void)setPositionMarkerForSearch {
    
    CLLocationCoordinate2D location = currentCoordinate;
    location.latitude -= 0.001;
    markerSearch = [GMSMarker markerWithPosition:location];
    [markerSearch setTappable:NO];
    markerSearch.map = self.mapView;
}


- (void)requestWithNewPosition {
    
    if (!isFromSolicit) {
        CGPoint point = self.mapView.center;
        point.y -= 60;
        currentCoordinate = [self.mapView.projection coordinateForPoint:point];
    }
    
    isFromSolicit = NO;
    
    boundsCurrent = [[GMSCoordinateBounds alloc]
                                   initWithRegion: self.mapView.projection.visibleRegion];
    
    if (!_isInventoryLoading && !_isNoInventories)[self getIventoryPoints];
    if (!_isReportsLoading && !_isNoReports)[self getPoints];
 
}

- (void) mapView: (GMSMapView *) mapView didChangeCameraPosition: (GMSCameraPosition *) position {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapMovementEnd) object:nil];
    
    //[self mapMovementEnd];
        if (!isMoving) {
            [self performSelector:@selector(mapMovementEnd) withObject:nil afterDelay:0.15];
        }
    
}


- (void) mapMovementEnd {
    isMoving = NO;
    //    [self.mapView clear];
    
    [self getIventoryPoints];
    [self getPoints];
}



#pragma mark - Search Bar delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    if (!searchTable) {
        
        searchTable = [[SearchTableViewController alloc]initWithNibName:@"SearchTableViewController" bundle:nil];
        searchTable.explorerView = self;
        searchTable.isExplore = YES;
        
        if ([Utilities isIpad]) {
            [searchTable.view setFrame:CGRectMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y + self.searchBar.frame.size.height + 10, searchTable.view.frame.size.width, searchTable.view.frame.size.height)];
        } else {
            [searchTable.view setFrame:self.view.bounds];
            [searchTable.view setBackgroundColor:[Utilities colorGrayLight]];
            [searchTable.tableView setContentInset:UIEdgeInsetsMake(80, 0, 0, 0)];
            [searchTable.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(80, 0, 0, 0)];
            
        }
        
        [searchTable.view.layer setCornerRadius:5];
        [searchTable.view.layer setShadowOffset:CGSizeMake(0, 2)];
        [searchTable.view.layer setShadowColor:[[UIColor blackColor]CGColor]];
        [self.view addSubview:searchTable.view];
        
        [self.view bringSubviewToFront:self.imgSearchBox];
        [self.view bringSubviewToFront:self.searchBar];
    }
    
    if (![Utilities isIpad]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self moveSearchBarIsTop:YES];
    }
    
    [searchTable.view setHidden:NO];
    [searchTable.view setAlpha:0];
    [UIView animateWithDuration:0.7 animations:^{
        [searchTable.view setAlpha:1];
    }];
    
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    
    //[self.arrFilterIDs removeAllObjects];
    //[self.arrFilterInventoryIDs removeAllObjects];
    
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchTable.view setHidden:YES];
    
    if (![Utilities isIpad]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self moveSearchBarIsTop:NO];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    if (markerSearch) {
        markerSearch.map = nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(requestAddresses) withObject:nil afterDelay:0.3];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchTable getLocationWithString:searchBar.text andLocation:boundsCurrent];
}

- (void)requestAddresses {
    [searchTable getLocationWithString:self.searchBar.text andLocation:boundsCurrent];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
    [searchBar setText:@""];
    
    [searchTable clearTable];
    
    [searchTable.view setHidden:YES];
    
    if (![Utilities isIpad]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self moveSearchBarIsTop:NO];
    }
}


- (void)moveSearchBarIsTop:(BOOL)isTop {
    int positionBox = 7;
    int positionSearchBar = 10;
    
    if (isTop) {
        positionBox = 27;
        positionSearchBar = 30;
    }
    
    CGRect frameBox = self.imgSearchBox.frame;
    frameBox.origin.y = positionBox;
    
    CGRect frameSBar = self.searchBar.frame;
    frameSBar.origin.y = positionSearchBar;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.searchBar setFrame:frameSBar];
        [self.imgSearchBox setFrame:frameBox];
    }];
}


@end
