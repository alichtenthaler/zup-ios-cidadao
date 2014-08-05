//
//  FilterEstatisticasViewController.h
//  Zup
//
//  Created by Renato Kuroe on 30/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EstatisticasViewController.h"

@interface FilterEstatisticasViewController : UIViewController{
    BOOL isCategoriesOpen;
    int currentIdCat;
}

@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *arrBtStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imgLineBottomCategoriesBox;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewCategories;
@property (weak, nonatomic) IBOutlet UIView *viewSlider;
@property (weak, nonatomic) IBOutlet UIView *ViewAllCat;

@property (retain, nonatomic)  NSMutableArray *arrButtonStatuses;
@property (retain, nonatomic)  EstatisticasViewController *estatisticasVC;

@property (retain, nonatomic) IBOutlet UIImageView *imgSeta;

@property (retain, nonatomic) IBOutlet UIButton *btTodasCategorias;
@property (retain, nonatomic) IBOutlet UIButton *btResolvidos;
@property (retain, nonatomic) IBOutlet UIButton *btAndamento;
@property (retain, nonatomic) IBOutlet UIButton *btAberto;

- (IBAction)btCategories:(id)sender;
- (IBAction)slider:(id)sender;
- (IBAction)btStatus:(id)sender;

@end
