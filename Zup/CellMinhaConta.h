//
//  CellMinhaConta.h
//  Zup
//
//  Created by Renato Kuroe on 27/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellMinhaConta : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStatus;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UILabel *lblCategory;
@property (strong, nonatomic) IBOutlet UILabel *lblSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine;
@property (weak, nonatomic) IBOutlet CustomButton *btAberto;
@property (weak, nonatomic) IBOutlet CustomButton *btAndamento;
@property (weak, nonatomic) IBOutlet CustomButton *btResolvido;
@property (weak, nonatomic) IBOutlet CustomButton *btNaoResolvido;
@property (weak, nonatomic) IBOutlet UILabel *lblProtocolo;
@property (strong, nonatomic) IBOutletCollection(CustomButton) NSArray *arrButton;

- (void)setvalues:(NSDictionary*)dict;

@end
