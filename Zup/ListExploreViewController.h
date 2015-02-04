//
//  ListExploreViewController.h
//  Zup
//
//  Created by Renato Kuroe on 02/12/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PerfilDetailViewController.h"
#import "XL/XLMediaZoom.h"

@interface ListExploreViewController : UIViewController {
    CustomButton *btCancel;
    PerfilDetailViewController *detailView;
    BOOL isSolicit;
    BOOL showingImage;
    XLMediaZoom* currentZoom;
}

@property (nonatomic, retain) NSMutableDictionary* imageZooms;
@property (weak, nonatomic) IBOutlet UILabel *lblNoSolicits;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spin;
@property (weak, nonatomic) IBOutlet UIButton *btSolicit;
@property (weak, nonatomic) IBOutlet UIButton *btInfo;
@property (nonatomic) BOOL isColeta;
@property (strong, nonatomic) NSArray *arrMain;
@property (strong, nonatomic) NSDictionary *dictMain;
@property (weak, nonatomic) NSString *strTitle;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (retain, nonatomic) IBOutletCollection(UIButton) NSArray *arrBt;

- (IBAction)btMenu:(id)sender;
- (IBAction)btSolicit:(id)sender;

@end
