//
//  MainViewController.m
//  Zup
//

#import "MainViewController.h"
#import "CreateViewController.h"
#import "LoginViewController.h"
#import "TabBarController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import "ExploreViewController.h"
#import "RavenClient.h"
#import "AppDelegate.h"

@interface MainViewController ()

@end

@implementation MainViewController

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
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.scroll setDelegate:self];
    
    self->onlyReload = NO;
    [self.btLogin setFontSize:14];
    [self.btRegister setFontSize:14];
    [self.lblTitle1 setFont:[Utilities fontOpensSansWithSize:11]];
    [self.lblTitle2 setFont:[Utilities fontOpensSansWithSize:11]];
    
    [self.btJump.titleLabel setFont:[Utilities fontOpensSansBoldWithSize:12]];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            UITextAttributeTextColor: [UIColor blackColor],
                                                            UITextAttributeFont: [Utilities fontOpensSansLightWithSize:18]
                                                            }];
    
    self.pageControl.pageIndicatorTintColor = [Utilities colorGray];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(btJump:) name:@"jump" object:nil];
    
    if (self.isFromPerfil || self.isFromSolicit) {
        [self setLabel];
        [self.btJump setTitle:@"Cancelar" forState:UIControlStateNormal];
    } else {
        [self.view setUserInteractionEnabled:NO];
        [self getReportCategories];
        [self buildScroll];
        [self buildLoadPage];
        [self requestLocation];
        [self.btJump setTitle:@"Pule para acessar o aplicativo" forState:UIControlStateNormal];
        
    }
    
    self.logoView.image = [Utilities getTenantLoginImage];
    if(![Utilities isIphone4inch])
        self.logoView.hidden = YES;
}

- (void)requestLocation {
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    [locationManager stopUpdatingLocation];
}

- (void)buildLoadPage {
    NSString *imgName;
    
    float posY = 0.0;
    BOOL large = NO;
    
    if ([Utilities isIpad]) {
        //imgName = @"launch_sbc_ipad";
        posY = 150;
        large = YES;
        
    } else {
        if ([Utilities isIphone4inch]) {
            //imgName = @"launch_sbc_iphone5hd";
            posY = 124;
        }
        else {
            //imgName = @"launch_sbc_iphone4";
            posY = 70;
        }
    }
    
    UIImage* img = [Utilities getTenantLaunchImage];
    
    imgViewLoad = [[UIImageView alloc]initWithFrame:self.view.frame];
    //[imgViewLoad setImage:[UIImage imageNamed:imgName]];
    [imgViewLoad setImage:img];
    [self.view addSubview:imgViewLoad];
    
    spin = [[UIActivityIndicatorView alloc]init];
    if(large)
    {
        [spin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [spin setColor:[UIColor grayColor]];
    }
    else
        [spin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spin setFrame:CGRectMake(self.view.center.x - (spin.frame.size.width/2), posY, spin.frame.size.width, spin.frame.size.height)];
    [self.view addSubview:spin];
    [spin startAnimating];
    
}

- (void)getReportCategories {
    NSLog(@"Reloading report categories");
    
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveData:)];
    [server setActionErro:@selector(didReceiveError:)];
    [server getReportCategories];
}

- (int)totalCategoryCount:(NSArray*)arr
{
    int count = 0;
    for(NSDictionary* dict in arr)
    {
        count++;
        
        NSArray* subcategories = [dict valueForKey:@"subcategories"];
        if(subcategories != nil)
            count += [self totalCategoryCount:subcategories];
    }
    
    return count;
}

- (void)parseCategory:(NSDictionary*)dict mutArr:(NSMutableArray*)mutArr arr:(NSArray*)arr
{
    NSURL *urlIcon = [NSURL URLWithString:[dict valueForKeyPath:@"icon.default.mobile.active"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
    
    UIImageView *imgV = [[UIImageView alloc]init];
    [imgV setImageWithURL:urlIcon completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        
        if (image == nil) {
            image = [UIImage imageNamed:@"mapMarker"];
        }
        
        NSData *dataImgIcon = UIImagePNGRepresentation(image);
        
        NSURL *urlMarker = [NSURL URLWithString:[dict valueForKeyPath:@"marker.retina.mobile"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV setImageWithURL:urlMarker completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            if (image == nil) {
                image = [UIImage imageNamed:@"mapMarker"];
            }
            
            NSData *dataImgMarker = UIImagePNGRepresentation(image);
            
            
            NSURL *urlIconDisabled = [NSURL URLWithString:[dict valueForKeyPath:@"icon.default.mobile.disabled"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
            
            UIImageView *imgV = [[UIImageView alloc]init];
            
            [imgV setImageWithURL:urlIconDisabled completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"mapMarker"];
                }
                
                NSData *dataImgIconDisabled = UIImagePNGRepresentation(image);
                
                
                NSMutableArray *arrStatus = [[NSMutableArray alloc]init];
                
                for (NSDictionary *dictTemp in [dict valueForKey:@"statuses"]) {
                    NSArray *keys = [dictTemp allKeys];
                    NSArray *values = [dictTemp allValues];
                    
                    NSMutableDictionary *dictStatus = [[NSMutableDictionary alloc]init];
                    int i = 0;
                    for (NSString *key in keys) {
                        
                        NSString *newValue = [Utilities checkIfNull:[values objectAtIndex:i]];
                        [dictStatus setValue:newValue forKey:[keys objectAtIndex:i]];
                        i ++;
                    }
                    [arrStatus addObject:dictStatus];
                }
                
                NSMutableArray* arrCategories = [[NSMutableArray alloc] init];
                if([dict valueForKey:@"inventory_categories"])
                {
                    for (NSDictionary *dictTemp in [dict valueForKey:@"inventory_categories"]) {
                        NSNumber* cid = [dictTemp valueForKey:@"id"];
                        [arrCategories addObject:cid];
                    }
                }
                
                NSNumber* resolution_time_enabled = [dict valueForKey:@"resolution_time_enabled"];
                NSNumber* private_resolution_time = [dict valueForKey:@"private_resolution_time"];
                
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:@{@"arbitrary" : [dict valueForKey:@"allows_arbitrary_position"],
                    @"iconData": dataImgIcon,
                    @"markerData" : dataImgMarker,
                    @"iconDataDisabled" : dataImgIconDisabled,
                    @"id" : [dict valueForKey:@"id"],
                    @"title" : [dict valueForKey:@"title"],
                    @"resolution_time" : [Utilities checkIfNull:[dict valueForKey:@"resolution_time"]],
                    @"statuses" : arrStatus,
                    @"user_response_time" : [Utilities checkIfNull:[dict valueForKey:@"user_response_time"]],
                    @"color" :[dict valueForKey:@"color"],
                    @"inventory_categories": arrCategories,
                    @"resolution_time_enabled": resolution_time_enabled,
                    @"private_resolution_time": private_resolution_time
                }];
                
                if(![[dict valueForKey:@"parent_id"] isKindOfClass:[NSNull class]])
                {
                    [tempDict setValue:[dict valueForKey:@"parent_id"] forKeyPath:@"parent_id"];
                }
                if(![[dict valueForKey:@"private"] isKindOfClass:[NSNull class]])
                {
                    [tempDict setValue:[dict valueForKey:@"private"] forKeyPath:@"private"];
                }
                if(![[dict valueForKey:@"confidential"] isKindOfClass:[NSNull class]])
                {
                    [tempDict setValue:[dict valueForKey:@"confidential"] forKeyPath:@"confidential"];
                }
                else
                {
                    NSNumber* val = [NSNumber numberWithBool:NO];
                    [tempDict setValue:val forKeyPath:@"confidential"];
                }
                
                NSArray* subCategories = [dict valueForKey:@"subcategories"];
                if(subCategories != nil)
                {
                    for(NSDictionary* subdict in subCategories)
                    {
                        [self parseCategory:subdict mutArr:mutArr arr:arr];
                    }
                }
                
                [mutArr addObject:tempDict];
                
                
                if (mutArr.count == [self totalCategoryCount:arr]) {
                    [UserDefaults setReportCategories:mutArr];
                    
                    NSLog(@"Loaded %i report categories", mutArr.count);
                    //if(!self->onlyReload)
                        [self getInventoryCategories];
                }
                
            }];
        }];
    }];
}

- (void)didReceiveData:(NSData*)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    
    NSArray *arr = [dict valueForKey:@"categories"];
    for (NSDictionary  *dict in arr) {
        [self parseCategory:dict mutArr:mutArr arr:arr];
    }
    
    if (arr.count == 0) {
        [UserDefaults setReportCategories:mutArr];
        [self getInventoryCategories];
    }
}

- (void)didReceiveError:(NSError*)error {
    NSString* errorString = [NSString stringWithFormat:@"%@", error];
    [[RavenClient sharedClient] captureMessage:errorString];
    
    [Utilities alertWithServerError];
}


- (void)getInventoryCategories {
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveInventoryData:)];
    [server setActionErro:@selector(didReceiveInventoryError:)];
    [server getInventoryCategories];
}

- (void)didReceiveInventoryData:(NSData*)data {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *arr = [dict valueForKey:@"categories"];
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    
    for (NSDictionary *dict in arr) {
        
        NSURL *urlIcon = [NSURL URLWithString:[dict valueForKeyPath:@"icon.retina.mobile.active"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
        
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV setImageWithURL:urlIcon completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            if (image == nil) {
                image = [UIImage imageNamed:@"mapMarker"];
            }
            
            NSData *dataImgIcon = UIImagePNGRepresentation(image);
            
            
            NSURL *urlIconDisabled = [NSURL URLWithString:[dict valueForKeyPath:@"icon.retina.mobile.disabled"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
            
            [imgV setImageWithURL:urlIconDisabled completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"mapMarker"];
                }
                
                NSData *dataImgIconDisabled = UIImagePNGRepresentation(image);
                
                NSURL *urlPin = [NSURL URLWithString:[dict valueForKeyPath:@"pin.retina.mobile"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
                UIImageView *imgV = [[UIImageView alloc]init];
                [imgV setImageWithURL:urlPin completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    if (image == nil) {
                        image = [UIImage imageNamed:@"mapMarker"];
                    }
                    
                    NSData *dataImgPin = UIImagePNGRepresentation(image);
                    
                    NSURL* urlMarker = [NSURL URLWithString:[dict valueForKeyPath:@"marker.retina.mobile"] relativeToURL:[NSURL URLWithString:[ServerOperations baseAPIUrl]]];
                    UIImageView* imgV = [[UIImageView alloc] init];
                    [imgV setImageWithURL:urlMarker completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                        
                        if(image == nil) {
                            image = [UIImage imageNamed:@"mapMarker"];
                        }
                        
                        NSData *dataImgMarker = UIImagePNGRepresentation(image);
                        
                        NSData *sectionsData = [NSKeyedArchiver archivedDataWithRootObject:[dict valueForKey:@"sections"]];
                        
                        NSDictionary *tempDict = @{@"iconData": dataImgIcon,
                                                   @"iconDataDisabled" : dataImgIconDisabled,
                                                   @"markerData" : dataImgMarker,
                                                   @"pinData" : dataImgPin,
                                                   @"id" : [dict valueForKey:@"id"],
                                                   @"title" : [dict valueForKey:@"title"],
                                                   @"description" : [Utilities checkIfNull:[dict valueForKey:@"description"]],
                                                   @"sectionsData" : sectionsData,
                                                   @"plot_format" : [dict valueForKey:@"plot_format"],
                                                   @"color": [dict valueForKey:@"color"]
                                                   };
                        
                        [mutArr addObject:tempDict];
                        
                        
                        if (mutArr.count == arr.count) {
                            [UserDefaults setInventoryCategories:mutArr];
                            
                            if(!self->onlyReload)
                                [self getFeatureFlags];
                            else
                                [self goToMap];
                            
                        }
                    }];
                    
                }];
                
            }];
            
        }];
        
    }
    
    if(arr.count == 0)
    {
        [UserDefaults setInventoryCategories:mutArr];
        
        if(!self->onlyReload)
            [self getFeatureFlags];
        else
            [self goToMap];
    }
    
}

- (void)goToMap
{
    if ([Utilities isIpad] && !self.isFromPerfil && !self.isFromSolicit ) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self btJump:nil];
        
    } else {
        if (!self.isFromPerfil && !self.isFromSolicit) {
            TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
            [self.navigationController setNavigationBarHidden:YES];
            [self.navigationController pushViewController:tabBar animated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.perfilVC getData];
            //if ([Utilities isIpad]) {
                [self.relateVC setToken];
            //}
        }
        
        
    }
}

- (void)getFeatureFlags
{
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveFeatureFlags:)];
    [server setActionErro:@selector(didReceiveFeatureFlagsError:)];
    [server getFeatureFlags];
}

- (void)didReceiveFeatureFlags:(NSData*)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray* flags = [dict valueForKey:@"flags"];
    [UserDefaults setFeatureFlags:flags];
    
    if(![UserDefaults isFeatureEnabled:@"explore"])
    {
        [self.btJump removeFromSuperview];
    }
    
    if ([UserDefaults isUserLogged] && !self->onlyReload) {
        [self goToMap];
        //[self btJump:nil];
    }
    self->onlyReload = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        [imgViewLoad setAlpha:0];
        [spin setAlpha:0];
    }completion:^(BOOL finished) {
        [imgViewLoad removeFromSuperview];
        [spin removeFromSuperview];
        [self.view setUserInteractionEnabled:YES];
    }];
}

- (void)didReceiveFeatureFlagsError:(NSError*)error {
    NSString* errorString = [NSString stringWithFormat:@"%@", error];
    [[RavenClient sharedClient] captureMessage:errorString];
    
    [Utilities alertWithServerError];
}

- (void)didReceiveInventoryError:(NSError*)error {
    NSString* errorString = [NSString stringWithFormat:@"%@", error];
    [[RavenClient sharedClient] captureMessage:errorString];
    
    [Utilities alertWithServerError];
}


- (void)buildScroll {
    
    float sideSize = self.scroll.frame.size.width; //self.view.frame.size.width;
    
    int count = 0;
    for (int i = 1; i < 6; i ++) {
        NSString *imgStr = nil;
        if ([Utilities isIpad]) {
            //imgStr = [NSString stringWithFormat:@"iPadtour_img%i",i];
            imgStr = [NSString stringWithFormat:@"tour_%@_img%i_ipad",[Utilities getCurrentTenant], i];
        } else {
            //imgStr = [NSString stringWithFormat:@"tour_img%i",i];
            imgStr = [NSString stringWithFormat:@"tour_%@_img%i_iphone",[Utilities getCurrentTenant], i];
        }
        UIImage *image = [UIImage imageNamed:imgStr];
        if(image == nil)
            break;
        
        UIImageView *imgV = [[UIImageView alloc]initWithImage:image];
        
        [imgV setFrame:CGRectMake(sideSize * count, 0, sideSize, sideSize)];
        [self.scroll addSubview:imgV];
        count ++;
    }
    
    [self.scroll setContentSize:CGSizeMake(sideSize * count, 10)];
    [self.pageControl setNumberOfPages:count];
    
}

- (void)setLabel {
    
    CGRect frame;
    if (![Utilities isIpad]) {
        frame = self.scroll.frame;
        frame.origin.x += 40;
        frame.size.width -= 80;
        frame.origin.y += 20;
    } else {
        frame = CGRectMake(0, 200, 540, 80);
    }
    
    UILabel *lbl = [[UILabel alloc]initWithFrame:frame];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[Utilities fontOpensSansWithSize:14]];
    [lbl setNumberOfLines:2];
    [lbl setTextColor:[Utilities colorGray]];
    [lbl setText:@"Você precisa estar logado para acessar esta área."];
    [self.view addSubview:lbl];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scroll.frame.size.width;
    int page = floor((self.scroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btRegister:(id)sender {
    
    CreateViewController *createVC = [[CreateViewController alloc]initWithNibName:@"CreateViewController" bundle:Nil];
    createVC.isFromPerfil = self.isFromPerfil;
    createVC.perfilVC = self.perfilVC;
    createVC.isFromSolicit = self.isFromSolicit;
    createVC.relateVC = self.relateVC;
    createVC.mainVC = self;
    if ([Utilities isIpad]) {
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:createVC];
        
        if (self.isFromPerfil || self.isFromSolicit) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.navigationController pushViewController:createVC animated:YES];
        } else {
            [nav setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:nav animated:YES completion:nil];
            nav.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
            [nav.view.superview setBackgroundColor:[UIColor clearColor]];

        }
        
         } else {
        [self.navigationController pushViewController:createVC animated:YES];
    }
    
}

- (IBAction)btLogin:(id)sender {
    
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
    loginVC.isFromPerfil = self.isFromPerfil;
    loginVC.perfilVC = self.perfilVC;
    loginVC.isFromSolicit = self.isFromSolicit;
    loginVC.relateVC =self.relateVC;
    loginVC.mainVC = self;
    
    if (![Utilities isIpad]) {
        
        [self.navigationController pushViewController:loginVC animated:YES];
    } else {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
        
        if (self.isFromPerfil || self.isFromSolicit) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self.navigationController pushViewController:loginVC animated:YES];
        } else {
            [nav setModalPresentationStyle:UIModalPresentationFormSheet];
            [self presentViewController:nav animated:YES completion:nil];
            nav.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
            [nav.view.superview setBackgroundColor:[UIColor clearColor]];
        }
        
        
        loginVC.mainVC = self;
    }
}


- (void)didCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"backToMapFromPerfil" object:nil];
    
}

- (IBAction)btJump:(id)sender {
    
    if (self.isFromPerfil) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.exploreVC viewWillAppear:YES];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToMapFromPerfil" object:nil];
        
        return;
    }
    else if(self.isFromSolicit) {
        [self.relateVC viewWillAppear:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSArray *catArr = [UserDefaults getReportCategories];
    
    if (![UserDefaults isUserLogged] && catArr.count == 0) {
        ExploreViewController *exploreVC = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreView"];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController pushViewController:exploreVC animated:YES];
        return;
    }
    
    
    TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
    [self.navigationController pushViewController:tabBar animated:YES];
    
}

@end
