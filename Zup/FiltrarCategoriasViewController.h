//
//  FiltrarCategoriasViewController.h
//  zup
//
//  Created by Igor Lira on 10/22/14.
//  Copyright (c) 2014 ntxdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FiltrarCategoriasViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSArray* categories;
    NSMutableArray* selectedCategories;
    NSMutableArray* expandedCategories;
    
    id delegateObj;
    SEL delegate;
}

@property (weak, nonatomic) IBOutlet UITableView* tableView;

- (NSArray*) categoriesIds;
- (void)setDelegate:(id)obj selector:(SEL)delegate;
- (void)deselectAll;

@end
