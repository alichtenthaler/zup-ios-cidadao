//
//  MainViewController.h
//  Zup
//
//  Created by Renato Kuroe on 29/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerfilViewController.h"
#import "ExploreViewController.h"
#import "RelateViewController.h"

@interface MainViewController : UIViewController <UIScrollViewDelegate> {
    BOOL isJump;
    UIActivityIndicatorView *spin;
    UIImageView *imgViewLoad;
    
    BOOL onlyReload;
}

@property (strong, nonatomic) UIViewController* exploreVC;

@property (nonatomic) BOOL isFromPerfil;
@property (nonatomic) BOOL isFromSolicit;
@property (strong, nonatomic)  PerfilViewController *perfilVC;
@property (strong, nonatomic)  RelateViewController *relateVC;


@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (retain, nonatomic) IBOutlet UILabel *lblTitle1;
@property (retain, nonatomic) IBOutlet UILabel *lblTitle2;

@property (retain, nonatomic) IBOutlet CustomButton *btLogin;
@property (retain, nonatomic) IBOutlet CustomButton *btRegister;
@property (retain, nonatomic) IBOutlet CustomButton *btJump;

@property (nonatomic, retain) IBOutlet UIView* tabExplore;
@property (nonatomic, retain) IBOutlet UITabBarItem* tabSolicite;
@property (nonatomic, retain) IBOutlet UITabBarItem* tabPerfil;
@property (nonatomic, retain) IBOutlet UITabBarItem* tabEstatisticas;

@property (nonatomic, retain) IBOutlet UIImageView* logoView;

- (IBAction)btRegister:(id)sender;
- (IBAction)btLogin:(id)sender;
- (IBAction)btJump:(id)sender;
- (void)didCancelButton:(id)sender;
- (void)getReportCategories;

@end
