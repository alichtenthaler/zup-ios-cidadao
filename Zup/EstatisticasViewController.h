//
//  EstatisticasViewController.h
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSPieProgressView.h"

@interface EstatisticasViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabel;
@property (nonatomic, retain) NSArray *arrMain;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spin;

- (void)refreshWithFilter:(int)days categoryId:(int)categoryId;

@end
