//
//  RelateViewController.m
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "RelateViewController.h"
#import "SolicitacaoMapViewController.h"
#import "NavigationControllerViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "LoginViewController.h"

@interface RelateViewController ()

@end

@implementation RelateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self setToken];
}

- (void)setToken {
    tokenStr = [UserDefaults getToken];

}

- (void)callLoginView {
    
    MainViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainVC"];
    loginVC.isFromSolicit = YES;
    loginVC.relateVC = self;
    UINavigationController *navLogin = [[UINavigationController alloc]initWithRootViewController:loginVC];
    
    if ([Utilities isIpad]) {
        [navLogin setModalPresentationStyle:UIModalPresentationFormSheet];
        navLogin.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
        [navLogin.view.superview setBackgroundColor:[UIColor clearColor]];
        
    }
    [self presentViewController:navLogin animated:NO completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.lblTitle setFont:[Utilities fontOpensSansBoldWithSize:12]];
    
    
    for (UILabel *lbl in self.arrLabel) {
        [lbl setFont:[Utilities fontOpensSansLightWithSize:10]];
    }

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    NSString *titleStr = @"Nova solicitação";
 
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
        [lblTitle setFont:[Utilities fontOpensSansLightWithSize:18]];
        [lblTitle setTextColor:[UIColor blackColor]];
        [lblTitle setText:titleStr];
        [self.navigationController.navigationBar.topItem setTitleView:lblTitle];
    
    [self createButtons];
    
}

- (void)createButtons {
    
    self.arrMain = [[NSArray alloc]initWithArray:[UserDefaults getReportCategories]];

    int i = 0;
    int lines = 1;
    int positionX = 0;
    int positionY = 0;
    int weight = 90;
    int viewHeight = 120;
    int space = 24;
    for (NSDictionary *dict in self.arrMain) {
        
        float newPositionX = weight * positionX;
        
        if (self.arrMain.count == 1) {
            newPositionX = 90;
        } else if (self.arrMain.count == 2) {
            if (i == 0) {
                newPositionX += 25;
            } else {
                newPositionX += weight - space;
            }
        }
        
        UIView *viewButton = [[UIView alloc]initWithFrame:CGRectMake(newPositionX + space, positionY +20, weight, viewHeight)];

        if (newPositionX > weight) {
            positionX = 0;
            positionY += viewHeight;
            lines ++;
        } else {
            positionX ++;
        }
        
        UIImage *imgIcon = [UIImage imageWithData:[dict valueForKey:@"iconDataDisabled"]];
        
        UIButton *bt = [UIButton buttonWithType:UIButtonTypeCustom];
        [bt setImage:imgIcon forState:UIControlStateNormal];
        [bt setTag:i];
        [bt setFrame:CGRectMake(10, 0, 70, 70)];
        [bt addTarget:self action:@selector(btExibirRelato:) forControlEvents:UIControlEventTouchUpInside];
        [bt setAlpha:0.5];
        
        [viewButton addSubview:bt];
        
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 70, weight, 40)];
        [lbl setText:[dict valueForKey:@"title"]];
        [lbl setNumberOfLines:2];
        [lbl setFont:[Utilities fontOpensSansLightWithSize:10]];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [viewButton addSubview:lbl];
        
        [self.scroll addSubview:viewButton];
        
        i ++;
    }
    
    
    [self.scroll setContentSize:CGSizeMake(320, viewHeight * (lines + 1))];
    
    if (self.scroll.contentSize.width < self.view.frame.size.width) {
        
        [self.scroll setFrame:CGRectMake(self.scroll.frame.origin.x, self.scroll.frame.origin.y, self.scroll.contentSize.width, self.scroll.frame.size.height)];
        
        CGRect frame = self.scroll.frame;
        [self.scroll setFrame:frame];
        
    }
    
    if (self.scroll.contentSize.height < self.view.frame.size.height) {
        
        NSLog(@"%f", self.scroll.contentSize.height);
        
        [self.scroll setFrame:CGRectMake(self.scroll.frame.origin.x, self.scroll.frame.origin.y, self.scroll.contentSize.width, self.scroll.contentSize.height)];
        
        [self.scroll setScrollEnabled:NO];
        
    }
    
    [self.scroll setCenter:self.view.center];
    
    
    
}

- (IBAction)btExibirRelato:(id)sender {
   
    if (tokenStr.length == 0) {
        [self callLoginView];
        return;
    }
    
    UIButton *bt = (UIButton*)sender;
    
    [bt setSelected:YES];
    
    NSDictionary *dict = [self.arrMain objectAtIndex:[sender tag]];
    
    NSString *strCat = [dict valueForKey:@"id"];
    
    SolicitacaoMapViewController *solicVC = [[SolicitacaoMapViewController alloc]initWithNibName:@"SolicitacaoMapViewController" bundle:nil];
    
    solicVC.dictMain = dict;
    solicVC.catStr = strCat;
    
    solicVC.imgIcon = bt.imageView.image;
    NavigationControllerViewController *nav = [[NavigationControllerViewController alloc]initWithRootViewController:solicVC];
    
    if ([Utilities isIpad])
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];
    
    [self presentViewController:nav animated:YES completion:^{}];
    
    if ([Utilities isIpad]) {
        nav.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
        [nav.view.superview setBackgroundColor:[UIColor clearColor]];
    }
    
}

- (BOOL)disablesAutomaticKeyboardDismissal {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
