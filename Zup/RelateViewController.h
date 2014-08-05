//
//  RelateViewController.h
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelateViewController : UIViewController {
    NSString *tokenStr;
}

@property (retain, nonatomic) IBOutletCollection(UILabel) NSArray *arrLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet NSArray *arrMain;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

- (IBAction)btExibirRelato:(id)sender;

- (void)setToken;

@end
