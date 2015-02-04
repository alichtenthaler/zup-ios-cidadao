//
//  FiltrarInventarioViewController.h
//  zup
//
//  Created by Igor Lira on 10/23/14.
//  Copyright (c) 2014 ntxdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltrarInventarioViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* categories;
    NSMutableArray* selectedCategories;
    
    id delegateObj;
    SEL delegate;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;

- (NSArray*) categoriesIds;
- (void)deselectAll;
- (void)setDelegate:(id)obj selector:(SEL)delegate;

@end
