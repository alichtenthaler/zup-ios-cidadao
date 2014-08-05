//
//  HeaderProfileCell.h
//  Zup
//
//  Created by Renato Kuroe on 05/03/14.
//  Copyright (c) 2014 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderProfileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lbltitleCell;
@property (weak, nonatomic) IBOutlet UILabel *lblNameCell;
@property (weak, nonatomic) IBOutlet UILabel *lblSoliciationsCell;

- (void)setValues:(NSDictionary *)dict count:(int)count;

@end
