//
//  MainViewController.m
//  Zup
//
//  Created by Renato Kuroe on 29/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "MainViewController.h"
#import "CreateViewController.h"
#import "LoginViewController.h"
#import "TabBarController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <CoreLocation/CoreLocation.h>
#import "ExploreViewController.h"

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
    
    if ([Utilities isIpad]) {
        imgName = @"launch_image_ipad";
        posY = 650;
    } else {
        if ([Utilities isIphone4inch]) {
            imgName = @"launch_image_iphone5";
            posY = 370;
        }
        else {
            imgName = @"launch_image_iphone";
            posY = 316;
        }
    }
    
    imgViewLoad = [[UIImageView alloc]initWithFrame:self.view.frame];
    [imgViewLoad setImage:[UIImage imageNamed:imgName]];
    [self.view addSubview:imgViewLoad];
    
    spin = [[UIActivityIndicatorView alloc]init];
    [spin setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [spin setFrame:CGRectMake(self.view.center.x - (spin.frame.size.width/2), posY, spin.frame.size.width, spin.frame.size.height)];
    [self.view addSubview:spin];
    [spin startAnimating];
    
}

- (void)getReportCategories {
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveData:)];
    [server setActionErro:@selector(didReceiveError:)];
    [server getReportCategories];
}

- (void)didReceiveData:(NSData*)data {
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSMutableArray *mutArr = [[NSMutableArray alloc]init];
    
    NSArray *arr = [dict valueForKey:@"categories"];
    for (NSDictionary  *dict in arr) {
        
        NSURL *urlIcon = [NSURL URLWithString:[dict valueForKeyPath:@"icon.default.mobile.active"]];
        
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV setImageWithURL:urlIcon completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            if (image == nil) {
                image = [UIImage imageNamed:@"mapMarker"];
            }
            
            NSData *dataImgIcon = UIImagePNGRepresentation(image);
            
            NSURL *urlMarker = [NSURL URLWithString:[dict valueForKeyPath:@"marker.retina.mobile"]];
            UIImageView *imgV = [[UIImageView alloc]init];
            [imgV setImageWithURL:urlMarker completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"mapMarker"];
                }
                
                NSData *dataImgMarker = UIImagePNGRepresentation(image);
                
                
                NSURL *urlIconDisabled = [NSURL URLWithString:[dict valueForKeyPath:@"icon.default.mobile.disabled"]];
                
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
                    
                    
                    NSDictionary *tempDict = @{@"arbitrary" : [dict valueForKey:@"allows_arbitrary_position"],
                                               @"iconData": dataImgIcon,
                                               @"markerData" : dataImgMarker,
                                               @"iconDataDisabled" : dataImgIconDisabled,
                                               @"id" : [dict valueForKey:@"id"],
                                               @"title" : [dict valueForKey:@"title"],
                                               @"resolution_time" : [Utilities checkIfNull:[dict valueForKey:@"resolution_time"]],
                                               @"statuses" : arrStatus,
                                               @"user_response_time" : [Utilities checkIfNull:[dict valueForKey:@"user_response_time"]],
                                               @"color" :[dict valueForKey:@"color"]
                                               };
                    
                    [mutArr addObject:tempDict];
                    
                    
                    if (mutArr.count == arr.count) {
                        [UserDefaults setReportCategories:mutArr];
                        [self getInventoryCategories];
                    }
                    
                }];
            }];
        }];
    }
    
}

- (void)didReceiveError:(NSError*)error {
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
        
        NSURL *urlIcon = [NSURL URLWithString:[dict valueForKeyPath:@"icon.retina.mobile.active"]];
        
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV setImageWithURL:urlIcon completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            if (image == nil) {
                image = [UIImage imageNamed:@"mapMarker"];
            }
            
            NSData *dataImgIcon = UIImagePNGRepresentation(image);
            
            
            NSURL *urlIconDisabled = [NSURL URLWithString:[dict valueForKeyPath:@"icon.retina.mobile.disabled"]];
            
            [imgV setImageWithURL:urlIconDisabled completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                
                if (image == nil) {
                    image = [UIImage imageNamed:@"mapMarker"];
                }
                
                NSData *dataImgIconDisabled = UIImagePNGRepresentation(image);
                
                NSURL *urlMarker = [NSURL URLWithString:[dict valueForKeyPath:@"pin.retina.mobile"]];
                UIImageView *imgV = [[UIImageView alloc]init];
                [imgV setImageWithURL:urlMarker completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    if (image == nil) {
                        image = [UIImage imageNamed:@"mapMarker"];
                    }
                    
                    NSData *dataImgMarker = UIImagePNGRepresentation(image);
                    
                    NSData *sectionsData = [NSKeyedArchiver archivedDataWithRootObject:[dict valueForKey:@"sections"]];
                    
                    NSDictionary *tempDict = @{@"iconData": dataImgIcon,
                                               @"iconDataDisabled" : dataImgIconDisabled,
                                               @"markerData" : dataImgMarker,
                                               @"id" : [dict valueForKey:@"id"],
                                               @"title" : [dict valueForKey:@"title"],
                                               @"description" : [Utilities checkIfNull:[dict valueForKey:@"description"]],
                                               @"sectionsData" : sectionsData
                                               };
                    
                    [mutArr addObject:tempDict];
                    
                    
                    if (mutArr.count == arr.count) {
                        [UserDefaults setInventoryCategories:mutArr];
                        
                        if ([UserDefaults isUserLogged]) {
                            [self btJump:nil];
                        }
                        [UIView animateWithDuration:0.5 animations:^{
                            [imgViewLoad setAlpha:0];
                            [spin setAlpha:0];
                        }completion:^(BOOL finished) {
                            [imgViewLoad removeFromSuperview];
                            [spin removeFromSuperview];
                            [self.view setUserInteractionEnabled:YES];
                        }];
                        
                    }
                    
                }];
                
            }];
            
        }];
        
    }
    
}


- (void)didReceiveInventoryError:(NSError*)error {
    [Utilities alertWithServerError];
}


- (void)buildScroll {
    
    float sideSize = self.view.frame.size.width;
    
    int count = 0;
    for (int i = 1; i < 6; i ++) {
        NSString *imgStr = nil;
        if ([Utilities isIpad]) {
            imgStr = [NSString stringWithFormat:@"iPadtour_img%i",i];
        } else {
            imgStr = [NSString stringWithFormat:@"tour_img%i",i];
            
        }
        UIImage *image = [UIImage imageNamed:imgStr];
        UIImageView *imgV = [[UIImageView alloc]initWithImage:image];
        
        [imgV setFrame:CGRectMake(sideSize * count, 0, sideSize, sideSize)];
        [self.scroll addSubview:imgV];
        count ++;
    }
    
    [self.scroll setContentSize:CGSizeMake(sideSize * count, sideSize)];
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
    
    if (self.isFromPerfil || self.isFromSolicit) {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToMapFromPerfil" object:nil];
        
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
