//
//  EditViewController.h
//  Zup
//
//  Created by Renato Kuroe on 30/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>
#import <GooglePlus/GooglePlus.h>
#import "TWAPIManager.h"
#import "SolicitacaoPublicarViewController.h"
#import "PerfilViewController.h"

@interface EditViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate, UIAlertViewDelegate, GPPSignInDelegate> {
    CustomButton *btSalvar;
    CustomButton *btCancel;
    SocialNetworkType socialType;
    GPPSignIn *signIn;
}
@property (nonatomic) BOOL isFromReportView;

@property (weak, nonatomic) IBOutlet UIButton *btFacebook;
@property (weak, nonatomic) IBOutlet UIButton *btTwitter;
@property (weak, nonatomic) IBOutlet UIButton *btPlus;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spin;

@property (weak, nonatomic) IBOutlet UIScrollView *scroll;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (strong, nonatomic) NSDictionary *dictUser;

@property (strong, nonatomic) IBOutletCollection (UITextField) NSArray *arrTf;
@property (strong, nonatomic) IBOutletCollection (UILabel) NSArray *arrLbl;
@property (strong, nonatomic) IBOutletCollection (UIButton) NSArray *arrBt;

@property (retain, nonatomic) IBOutlet GPPSignInButton *signInButton;
@property (nonatomic, strong) TWAPIManager *apiManager;

@property (weak, nonatomic) IBOutlet UILabel *lblSocialSentence;
@property (weak, nonatomic) IBOutlet UITextField *tfName;
@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPass;
@property (weak, nonatomic) IBOutlet UITextField *tfConfirmPass;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (weak, nonatomic) IBOutlet UITextField *tfCpf;
@property (weak, nonatomic) IBOutlet UITextField *tfBairro;
@property (weak, nonatomic) IBOutlet UITextField *tfAddress;
@property (weak, nonatomic) IBOutlet UITextField *tfComplement;
@property (weak, nonatomic) IBOutlet UITextField *tfCep;

@property (weak, nonatomic) SolicitacaoPublicarViewController *solicitView;
@property (weak, nonatomic) PerfilViewController *perfilView;

- (IBAction)btFacebook:(id)sender;
- (IBAction)btTwitter:(id)sender;
- (IBAction)btPlus:(id)sender;

@end