//
//  FiltrarViewController.h
//  Zup
//
//  Created by Renato Kuroe on 24/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ExploreViewController;
@interface FiltrarViewController : UIViewController <UIGestureRecognizerDelegate> {
    BOOL isMenuOpen;
}

@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *arrBtStatus;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSMutableArray *arrReportCategorias;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSMutableArray *arrInventoryCategories;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSMutableArray *arrButtonStatuses;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSMutableArray *arrCurrentButtonStatuses;
@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabel;
@property (retain, nonatomic)  NSMutableArray *arrBtPontos;


@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) ExploreViewController *exploreView;
@property (retain, nonatomic) IBOutlet UISlider *slider;

@property (retain, nonatomic) IBOutlet UIView *viewContent;
@property (retain, nonatomic) IBOutlet UIView *viewPontos;
@property (retain, nonatomic) IBOutlet UIView *viewStatus;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollInventoryCategories;
@property (retain, nonatomic) IBOutlet UIImageView *imgSeta;

@property (retain, nonatomic) IBOutlet UILabel *lblSolicitacoesTitle;
@property (retain, nonatomic) IBOutlet UILabel *lblPontosTitle;

@property (retain, nonatomic) IBOutlet UIButton *btBueiroBocaLobo;
@property (retain, nonatomic) IBOutlet UIButton *btColetaEntulho;
@property (retain, nonatomic) IBOutlet UIButton *btViewStatus;

@property (retain, nonatomic) IBOutlet UIButton *btTodosStatus;
@property (retain, nonatomic) IBOutlet UIButton *btResolvidos;
@property (retain, nonatomic) IBOutlet UIButton *btAndamento;
@property (retain, nonatomic) IBOutlet UIButton *btAberto;


@property (retain, nonatomic) IBOutlet UIScrollView *scrollCat;

- (IBAction)sliderDidChange:(id)sender;
- (IBAction)btExibirRelato:(id)sender;
- (IBAction)btStatus:(id)sender;
- (IBAction)btPontos:(id)sender;
- (IBAction)btViewStatus:(id)sender;

@end
