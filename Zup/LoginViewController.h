//
//  LoginViewController.h
//  Zup
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "PerfilViewController.h"
#import "RelateViewController.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic) BOOL isFromInside;
@property (nonatomic) BOOL isFromPerfil;
@property (nonatomic) BOOL isFromSolicit;

@property (weak, nonatomic) IBOutlet CustomButton* btLogin;
@property (weak, nonatomic) IBOutlet CustomButton *btForgot;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *spin;

@property (weak, nonatomic) IBOutlet UITextField *tfEmail;
@property (weak, nonatomic) IBOutlet UITextField *tfPass;

@property (retain, nonatomic) IBOutlet UILabel *lblTitle;

@property (retain, nonatomic) IBOutlet MainViewController *mainVC;
@property (weak, nonatomic)  PerfilViewController *perfilVC;
@property (weak, nonatomic)  RelateViewController *relateVC;


- (IBAction)btForogt:(id)sender;

@end
