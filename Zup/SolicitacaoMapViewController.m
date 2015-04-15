//
//  SolicitacaoMapViewController.m
//  Zup
//
//  Created by Renato Kuroe on 26/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "SolicitacaoMapViewController.h"
#import "PlaceMark.h"
#import "TIRequestOperation.h"

GMSMarker *currentMarker;
CLLocationCoordinate2D currentCoord;
NSString *currentAddress;
int ZOOMLEVELDEFAULTSEARCH = 16;
ServerOperations *serverOperations;


@interface SolicitacaoMapViewController ()

@end

@implementation SolicitacaoMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self->freeJobId = 0;
    
    NSString *titleStr = @"Nova solicitação";
   
    UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    [lblTitle setFont:[Utilities fontOpensSansLightWithSize:18]];
    [lblTitle setTextColor:[UIColor blackColor]];
    [lblTitle setText:titleStr];
    [self.navigationController.navigationBar.topItem setTitleView:lblTitle];
    
    [self.navigationItem setHidesBackButton:YES];

    [self.titleLabel setFont:[Utilities fontOpensSansBoldWithSize:11]];
    
    self.arrMainInventory = [[NSMutableArray alloc]init];

    [self.mapView setDelegate:self];
    [self.mapView setMyLocationEnabled:YES];
    
    [self.tfNumber setFont:[Utilities fontOpensSansLightWithSize:14]];
    [self.tvReferencia setFont:[Utilities fontOpensSansLightWithSize:14]];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(5, 5, 75, 35);
    [button.titleLabel setFont:[Utilities fontOpensSansWithSize:14]];
    [button setBackgroundImage:[UIImage imageNamed:@"menubar_btn_cancelar_normal-1"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"menubar_btn_cancelar_active-1"] forState:UIControlStateHighlighted];
    [button setTitle:@"Cancelar" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    
    if (![Utilities isIpad]) {
        
    } else {
        
    }
        btFilter = [[CustomButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 80, 5, 75, 35)];
        [btFilter setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_normal-1"] forState:UIControlStateNormal];
        [btFilter setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_active-1"] forState:UIControlStateHighlighted];
        [btFilter setFontSize:14];
        [btFilter setTitle:@"Confirmar" forState:UIControlStateNormal];
        [btFilter addTarget:self action:@selector(btConfirm) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.navigationBar addSubview:btFilter];
        [btFilter setHidden:YES];

    
    [self.navigationController.navigationBar addSubview:button];
    
    [self.btNext.titleLabel setFont:[Utilities fontOpensSansLightWithSize:14]];
    
    [self getCurrentLocation];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    [self buildPoint];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget: self action:@selector(didPan:)];
    self.mapView.gestureRecognizers = @[panRecognizer];
    
    if (![[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
        [self.titleLabel setText:@"TOQUE NO PONTO EXATO QUE DESEJA FAZER A SOLICITAÇÃO"];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeText) name:UITextFieldTextDidChangeNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(endText) name:UITextFieldTextDidEndEditingNotification object:nil];

}

- (void)didPan:(UIPanGestureRecognizer*)pan {
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if ([[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
            
            
            boundsCurrent = [[GMSCoordinateBounds alloc]
                             initWithRegion: self.mapView.projection.visibleRegion];
            
            
            [self getLocationWithLoction:currentCoord];
        }
    }
    
}
- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPositionMarkerForSearch {
    
    if ([[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
        return;
    }

    CLLocationCoordinate2D location = currentCoord;
    markerSearch = [GMSMarker markerWithPosition:location];
    [markerSearch setTappable:NO];
    markerSearch.map = self.mapView;
}

#pragma mark - Core Location

- (void)getCurrentLocation {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    int diffZoom = 3;
    if ([Utilities isIpad])
        zoomCurrent = ZOOMLEVELDEFAULTSEARCH + diffZoom;
    else
        zoomCurrent = ZOOMLEVELDEFAULTSEARCH + diffZoom;
    
//#warning TESTE
//    coordinate = CLLocationCoordinate2DMake(-23.548090, -46.636069);
    [self setLocationWithCoordinate:coordinate zoom:zoomCurrent];
}

- (void)setLocationWithCoordinate:(CLLocationCoordinate2D)coordinate zoom:(int)zoom{
    [btFilter setHidden:YES];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coordinate.latitude
                                                            longitude:coordinate.longitude
                                                                 zoom:zoom];
    self.mapView.camera = camera;
    
    
    [self.searchBar resignFirstResponder];
    
    [self getIventoryPoints];

}

- (void) buildPoint {
    
    NSDictionary *dictCat = [UserDefaults getCategory:self.catStr.integerValue];
    
    UIImage *image = [UIImage imageWithData:[dictCat valueForKey:@"markerData"]];
    
    image = [Utilities imageWithImage:image scaledToSize:CGSizeMake(image.size.width/2, image.size.height/2)];

    self.imageMarkerPositionCenter = [[UIImageView alloc]initWithImage:image];
    
    if ([Utilities isIpad]) {
        [self.imageMarkerPositionCenter setCenter:CGPointMake(778/2, 944/2)];
    } else {
        CGPoint centerMap = self.mapView.center;
        
        if ([Utilities isIphone4inch]) {
            [self.imageMarkerPositionCenter setCenter:CGPointMake(centerMap.x += 2, centerMap.y)];
        } else {
            [self.imageMarkerPositionCenter setCenter:CGPointMake(centerMap.x += 2, centerMap.y-55)];
        }
    }
    
    [self.view addSubview:self.imageMarkerPositionCenter];
    
    imageCurrentMarker = image;
    
    if (![[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
        [self.imageMarkerPositionCenter setHidden:YES];
        [self.btNext setHidden:YES];
    }
}

- (void)setMarkerWithCoordinate:(CLLocationCoordinate2D)coordinate {
    
    userMarker = [[GMSMarker alloc] init];
    userMarker.position = coordinate;
    userMarker.draggable = YES;
    userMarker.map = self.mapView;
    
    [self getLocationWithLoction:coordinate];
}


- (void)mapView:(GMSMapView *)mapView didEndDraggingMarker:(GMSMarker *)marker {
    
    currentMarker = marker;
}

- (void)getLocationWithLoction:(CLLocationCoordinate2D)location
{
    [self.searchBar setText:@""];
    [self.searchBar setPlaceholder:@"Carregando endereço..."];
    
    int jobId = self->freeJobId++;
    self->locationJobId = jobId;
    
    [serverOperations CancelRequest];
    serverOperations = [[ServerOperations alloc] init];
    serverOperations.action = @selector(didReceiveAddress:withOperation:);
    serverOperations.target = self;
    serverOperations.jobId = jobId;
    [serverOperations getAddressWitLatitude:location.latitude andLongitude:location.longitude];
    //[self performSelector:@selector(didFailLoadAddress) withObject:nil afterDelay:5];
}

- (void) didReceiveAddress:(NSData*)data withOperation:(TIRequestOperation*)operation
{
    if(operation.jobId != self->locationJobId)
        return;
    
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSArray* results = [dictionary valueForKey:@"results"];
    NSDictionary* mainResult = [results objectAtIndex:0];
    
    NSString* streetNumber = [self component:@"street_number" forAddress:mainResult];
    NSString* route = [self component:@"route" forAddress:mainResult];
    
    self.tfNumber.text = streetNumber;
    self.searchBar.text = route;
    self.searchBar.placeholder = @"Endereço";
    
    NSMutableString *str = [[NSMutableString alloc]init];
    
    [str appendString:[self component:@"route" forAddress:mainResult]];
    //[str appendString:@", "];
    //[str appendString:[self component:@"street_number" forAddress:mainResult]];
    
    userMarker.title = @"Posição atual";
    userMarker.snippet = str;
    
    currentAddress = str;
}

- (NSString*) component:(NSString*)componentType forAddress:(NSDictionary*)address
{
    NSArray* components = [address objectForKey:@"address_components"];
    for(NSDictionary* _component in components)
    {
        NSString* value = [_component objectForKey:@"short_name"];
        NSArray* types = [_component objectForKey:@"types"];
        
        for(NSString* typeName in types)
        {
            if([typeName isEqualToString:componentType])
                return value;
        }
    }
    
    return @"UNAVAILABLE";
}

- (void)didFailLoadAddress {
    /*if (self.searchBar.text.length == 0 && !isSearch) {
        self.searchBar.text = currentAddress;
    }*/
}

- (void)getLocation {
    
    [serverOperations CancelRequest];
    serverOperations = nil;
    
    serverOperations = [[ServerOperations alloc]init];
    [serverOperations setTarget:self];
    [serverOperations setJobId:self->freeJobId];
    [serverOperations setAction:@selector(didReceiveAddress:withOperation:)];
    [serverOperations getAddressWitLatitude:currentCoord.latitude andLongitude:currentCoord.longitude];
    
    self->locationJobId = self->freeJobId;
    self->freeJobId++;
}

- (void)mapView:(GMSMapView *)mapView
didChangeCameraPosition:(GMSCameraPosition *)position {
    CGPoint point = self.mapView.center;
    point.y -= 60;
    currentCoord = [self.mapView.projection coordinateForPoint:point];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapMovementEnd) object:nil];
    
    //[self mapMovementEnd];
    //if (!isMoving) {
        [self performSelector:@selector(mapMovementEnd) withObject:nil afterDelay:0.15];
    //}
}

- (void)mapView:(GMSMapView *)mapView
idleAtCameraPosition:(GMSCameraPosition *)position {
    if ([[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
        [self getLocationWithLoction:currentCoord];
    }
}

- (void) mapMovementEnd {
    //isMoving = NO;
    //    [self.mapView clear];
    
    [self getIventoryPoints];
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btPrev:(id)sender {
    
}

- (IBAction)btNext:(id)sender {
    
    if(!currentAddress || self.tfNumber.text.length < 1)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Preencher Endereço" message:@"É necessário preencher o endereço para enviar o relato." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (!photoView) {
        photoView = [[SolicitacaoPhotoViewController alloc]initWithNibName:@"SolicitacaoPhotoViewController" bundle:nil];
    }
    
    if (currentAddress == nil) {
        currentAddress = @"";
    } else {
        currentAddress = [NSString stringWithFormat:@"%@, %@", currentAddress, self.tfNumber.text];
    }
    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc]init];
    if (strCurrentInventoryId.length > 0) {
        [dictTemp setObject:strCurrentInventoryId forKey:@"inventory_category_id"];
        [dictTemp setObject:[self.dictMain valueForKey:@"id"] forKey:@"catId"];
        [dictTemp setObject:self.tvReferencia.text forKey:@"reference"];
    } else {
        [dictTemp setObject:[NSString stringWithFormat:@"%f", currentCoord.latitude] forKey:@"latitude"];
        [dictTemp setObject:[NSString stringWithFormat:@"%f", currentCoord.longitude] forKey:@"longitude"];
        [dictTemp setObject:currentAddress forKey:@"address"];
        [dictTemp setObject:@"" forKey:@"inventory_category_id"];
        [dictTemp setObject:[self.dictMain valueForKey:@"id"] forKey:@"catId"];
        [dictTemp setObject:currentAddress forKey:@"address"];
        [dictTemp setObject:self.tvReferencia.text forKey:@"reference"];
    }
    
    photoView.dictMain = [NSMutableDictionary dictionaryWithDictionary:dictTemp];
    photoView.catStr = self.catStr;
    
    [self.navigationController pushViewController:photoView animated:YES];
    
}


#pragma mark - Search Bar delegates

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:YES animated:YES];
    [self loadSearchTable];
}

- (void)loadSearchTable {
    if (!searchTable) {
        
        searchTable = [[SearchTableViewController alloc]initWithNibName:@"SearchTableViewController" bundle:nil];
        searchTable.solicitacaoView = self;
        searchTable.isExplore = NO;
        
        if ([Utilities isIpad]) {
            [searchTable.view setFrame:CGRectMake(self.view.center.x - searchTable.view.frame.size.width/2,
                                                  self.viewSearchBar.frame.origin.y + self.viewSearchBar.frame.size.height + 60,
                                                  searchTable.view.frame.size.width,
                                                  searchTable.view.frame.size.height)];
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
        
        [self.view bringSubviewToFront:self.viewSearchBar];
        
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
    
    isSearch = YES;
    
}
- (void)closeSearchTable {
    [searchTable.view setHidden:YES];
    
    if (![Utilities isIpad]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self moveSearchBarIsTop:NO];
    }
    
    isSearch = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
//    [searchBar setShowsCancelButton:NO animated:YES];
//    [self closeSearchTable];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(requestAddresses) withObject:nil afterDelay:0.3];
    
}

- (void)requestAddresses {
    NSString *strLocation = [NSString stringWithFormat:@"%@-%@", self.searchBar.text, self.tfNumber.text];
    [searchTable getLocationWithString:strLocation andLocation:boundsCurrent];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *strLocation = [NSString stringWithFormat:@"%@-%@", self.searchBar.text, self.tfNumber.text];
    [searchTable getLocationWithString:strLocation andLocation:boundsCurrent];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
//    [searchBar setShowsCancelButton:NO animated:YES];
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
    int positionSearchBar = 42;
    
    if (isTop) {
        positionBox = 27;
        positionSearchBar = 30;
    }
    
    CGRect frameSBar = self.viewSearchBar.frame;
    frameSBar.origin.y = positionSearchBar;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.viewSearchBar setFrame:frameSBar];
    }];
}

#pragma mark - Text Field Delegates

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self.tvReferencia setHidden:NO];
    [btFilter setHidden:NO];
}

- (void)changeText {
    
    if (self.tfNumber.text.length == 0) {
        isEditingNumber = NO;
    } else {
        [self.tvReferencia setHidden:NO];
        isEditingNumber = YES;
    }
    
    NSString *strLocation = [NSString stringWithFormat:@"%@-%@", self.searchBar.text, self.tfNumber.text];
    [searchTable getLocationWithString:strLocation andLocation:boundsCurrent];
    
}

- (void)endText {
    
    if (self.tfNumber.text.length == 0) {
        [self.tvReferencia setText:@"Ponto de referência (ex: próximo ao ponto de ônibus)"];
    }
    [btFilter setHidden:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.tfNumber) {
        NSCharacterSet *_NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:string];
        
        if (![_NumericOnly isSupersetOfSet: myStringSet]) {
            return NO;
        }
    }

       return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self btConfirm];
    
    [textField resignFirstResponder];
    [self.searchBar resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [textView setHidden:YES];
        [btFilter setHidden:YES];
        return NO;
    }
    
    return YES;
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
        
//#warning TESTE
//        currentCoord = CLLocationCoordinate2DMake(-23.548090, -46.636069);

        int radius = self.mapView.camera.zoom;
        radius = 21 - radius;
        if ([Utilities isIpad]) {
            radius = radius * 2000;
        } else {
            radius = radius * 1400;
        }
        
        GMSVisibleRegion visibleRegion = [[self.mapView projection] visibleRegion];
        double distance = [self getDistance:visibleRegion.nearRight p2:visibleRegion.nearLeft];
        
        if (![[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
            ServerOperations *serverOp = [[ServerOperations alloc]init];
            [serverOp setTarget:self];
            [serverOp setAction:@selector(didReceiveInventoryData:)];
            [serverOp setActionErro:@selector(didReceiveIventoryError:data:)];
            
            NSArray* categoryIds = [self.dictMain valueForKey:@"inventory_categories"];

            if([categoryIds count] == 0)
                [serverOp getItemsForPosition:currentCoord.latitude longitude:currentCoord.longitude radius:distance zoom:self.mapView.camera.zoom];
            else
                [serverOp getItemsForPosition:currentCoord.latitude longitude:currentCoord.longitude radius:distance zoom:self.mapView.camera.zoom categoryIds:categoryIds];
            //[serverOp getItemsForPosition:currentCoord.latitude longitude:currentCoord.longitude radius:radius zoom:self.mapView.camera.zoom categoryId:[self.dictMain valueForKey:@"id"]];
        }
    
    }
}

- (void)didReceiveInventoryData:(NSData*)data {
    
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    
    NSArray *arr = [dict valueForKey:@"items"];
    
    for (NSDictionary *dict in arr) {
        if (![self.arrMainInventory containsObject:dict]) {
            [self.arrMainInventory addObject:dict];
        }
    }
    
    for (NSDictionary *dict in self.arrMainInventory) {
        [self setLocationWithCoordinate:dict];
    }
    
}

- (void)didReceiveIventoryError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
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
    
    NSString *strColor = [[self.dictMain valueForKey:@"color"] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    UIColor *color = [Utilities colorWithHexString:strColor];
    
    UIImage *img = [UIImage imageNamed:@"ponto_bocalobo"];
    img = [Utilities changeColorForImage:img toColor:color];
    
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

#pragma mark - Map Handle

- (void)setLocationWithCoordinate:(NSDictionary*)dict{
    
    double lat = [[dict valueForKeyPath:@"position.latitude"]doubleValue];
    
    double lng = [[dict valueForKeyPath:@"position.longitude"]doubleValue];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
    
    [self setMarkerInventoryWithCoordinate:coord snippet:nil draggable:NO type:[[dict valueForKey:@"inventory_category_id"]intValue] userData:dict];
    
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    
    [self.searchBar setText:@""];
    
    if (self.btNext.hidden) {
        [self.btNext setHidden:NO];
    }
    
    NSDictionary *dict = marker.userData;
    
    currentCoord = CLLocationCoordinate2DMake([[dict valueForKeyPath:@"position.latitude"]floatValue], [[dict valueForKeyPath:@"position.longitude"]floatValue]);
    [self getLocationWithLoction:currentCoord];
    
    NSString *strColor = [[self.dictMain valueForKey:@"color"] stringByReplacingOccurrencesOfString:@"#" withString:@""];
    UIColor *color = [Utilities colorWithHexString:strColor];
    
    UIImage *img = [UIImage imageNamed:@"ponto_bocalobo"];
    img = [Utilities changeColorForImage:img toColor:color];
    
    currentMarker.icon = img;

    [marker setIcon:imageCurrentMarker];
    [marker setAppearAnimation:kGMSMarkerAnimationPop];
    currentMarker = marker;
    
    [self.imageMarkerPositionCenter setImage:[UIImage imageNamed:@""]];
        
    if (![[self.dictMain valueForKey:@"arbitrary"]boolValue]) {
        strCurrentInventoryId = [NSString stringWithFormat:@"%@",[marker.userData valueForKey:@"id"]];
    }
    
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@"Ponto de referência (ex: próximo ao ponto de ônibus)"]) {
        textView.text = @"";
    }
    return YES;
    
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    [btFilter setHidden:NO];
    [self.tvReferencia setHidden:NO];
    
    
}


- (void)btConfirm {
    [self.tvReferencia resignFirstResponder];
    [self.tfNumber resignFirstResponder];
    [btFilter setHidden:YES];

    NSString *strLocation = [NSString stringWithFormat:@"%@-%@", self.searchBar.text, self.tfNumber.text];
    [self getLocationWithString:strLocation andLocation:boundsCurrent];
}

- (void)getLocationWithString:(NSString*)strKey andLocation:(GMSCoordinateBounds*)coord{
    
    [serverOperations CancelRequest];
    serverOperations = nil;
    
    serverOperations = [[ServerOperations alloc]init];
    [serverOperations setTarget:self];
    [serverOperations setAction:@selector(didReceiveAddressLocal:)];
    [serverOperations getAddressWithString:strKey andGeo:coord.northEast.latitude lng:coord.northEast.longitude southLat:coord.southWest.latitude southLng:coord.southWest.longitude];
}

- (void)didReceiveAddressLocal:(NSData*)data {
    NSDictionary *dict = [[NSDictionary alloc]init];
    dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    if ([dict valueForKey:@"results"]) {
        
        NSDictionary *newDict = [[dict valueForKey:@"results"]objectAtIndex:0];
        
        if (![newDict valueForKeyPath:@"geometry.location.lat"]) {
            return;
        }
        
        NSString* route = [self component:@"route" forAddress:newDict];
      
        if (![route isEqualToString:self.searchBar.text]) {
            return;
        }
        double lat = [[newDict valueForKeyPath:@"geometry.location.lat"]doubleValue];
        
        double lng = [[newDict valueForKeyPath:@"geometry.location.lng"]doubleValue];
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
        
       
        
        currentCoord = coord;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coord.latitude
                                                                longitude:coord.longitude
                                                                     zoom:self.mapView.camera.zoom];
        self.mapView.camera = camera;
    }
}

@end
