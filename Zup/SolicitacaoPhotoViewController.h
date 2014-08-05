//
//  SolicitacaoPhotoViewController.h
//  Zup
//
//  Created by Renato Kuroe on 27/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomUIImagePickerController.h"

@interface SolicitacaoPhotoViewController : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int currentButtonTag;
}

@property (strong, nonatomic) NSMutableArray *arrPhotos;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btArray;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btPhoto1;
@property (weak, nonatomic) IBOutlet UIButton *btPhoto2;
@property (weak, nonatomic) IBOutlet UIButton *btPhoto3;
@property (weak, nonatomic) IBOutlet CustomButton *btAddPhoto;
@property (weak, nonatomic) IBOutlet CustomButton *btNext;
@property (weak, nonatomic) IBOutlet CustomButton *btBack;

@property (strong, nonatomic) NSString *catStr;
@property (strong, nonatomic)NSMutableDictionary *dictMain;

- (IBAction)btPhoto:(id)sender;
- (IBAction)btNext:(id)sender;
- (IBAction)btBack:(id)sender;

@end
