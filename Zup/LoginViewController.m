//
//  LoginViewController.m
//  Zup
//
//  Created by Renato Kuroe on 28/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "LoginViewController.h"
#import "TabBarController.h"
#import "CreateViewController.h"
#import "NavigationControllerViewController.h"
#import "ForgotViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.spin setHidesWhenStopped:YES];

    [self.navigationItem setHidesBackButton:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    [self.tfEmail setFont:[Utilities fontOpensSansLightWithSize:14]];
    [self.tfPass setFont:[Utilities fontOpensSansLightWithSize:14]];
    [self.btForgot.titleLabel setFont:[Utilities fontOpensSansBoldWithSize:13]];
    
    [self.tfPass setSecureTextEntry:YES];
    
    CustomButton *btCancel = [[CustomButton alloc] init];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_sair_normal"] forState:UIControlStateNormal];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_sair_active"] forState:UIControlStateHighlighted];
    [btCancel setFontSize:14];
    [btCancel setTitle:@"Cancelar" forState:UIControlStateNormal];
    [btCancel addTarget:self action:@selector(didCancelButton) forControlEvents:UIControlEventTouchUpInside];
    [btCancel setFrame:CGRectMake(5, 5, 74, 35)];
    [self.navigationController.navigationBar addSubview:btCancel];
    
    int x = self.navigationController.navigationBar.bounds.size.width - 79;
    x = self.navigationController.view.superview.bounds.size.width - 600;
    
    /*CustomButton *btCreate = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    [btCreate setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_normal-1"] forState:UIControlStateNormal];
    [btCreate setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_active-1"] forState:UIControlStateHighlighted];
    [btCreate setFontSize:14];
    [btCreate setTitle:@"Entrar" forState:UIControlStateNormal];
    [btCreate addTarget:self action:@selector(didLoginButton) forControlEvents:UIControlEventTouchUpInside];
    [btCreate setFrame:CGRectMake(self.navigationController.view.superview.bounds.size.width - 600, 5, 74, 35)];
    [self.navigationController.navigationBar addSubview:btCreate];*/
    
    [self.navigationItem setHidesBackButton:YES];
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.tfEmail.frame.size.height)];
    leftView.backgroundColor = [UIColor clearColor];
    self.tfEmail.leftView = leftView;
    self.tfEmail.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *leftView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.tfPass.frame.size.height)];
    leftView2.backgroundColor = [UIColor clearColor];
    self.tfPass.leftView = leftView2;
    self.tfPass.leftViewMode = UITextFieldViewModeAlways;
    
    [self.tfEmail setDelegate:self];
    [self.tfPass setDelegate:self];
    
    NSString *titleStr = @"Login";
    
    if ([Utilities isIOS7]) {
        [self setTitle:titleStr];
        
    } else {
        
        UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
        [lblTitle setFont:[Utilities fontOpensSansLightWithSize:18]];
        [lblTitle setTextColor:[UIColor blackColor]];
        [lblTitle setText:titleStr];
        [self.navigationController.navigationBar.topItem setTitleView:lblTitle];
        [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    }

    if (self.isFromPerfil || self.isFromInside || self.isFromSolicit) {
        [self.btForgot setHidden:YES];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [self.tfEmail becomeFirstResponder];
}

- (void)didLoginButton {
    
    if (self.tfPass.text.length == 0 || self.tfEmail.text.length == 0) {
        if (![Utilities isValidEmail:self.tfEmail.text]) {
            [Utilities alertWithError:@"Insira um e-mail válido!"];
            return;
        }
        [Utilities alertWithError:@"Preencha todos os campos!"];
        return;
    }
    
    
    if ([Utilities isInternetActive]) {
        ServerOperations *serverOp = [[ServerOperations alloc]init];
        [serverOp setTarget:self];
        [serverOp setAction:@selector(didReceiveData:)];
        [serverOp setActionErro:@selector(didReceiveError:data:)];
        [serverOp authenticate:self.tfEmail.text pass:self.tfPass.text];
    }
}

- (void)didReceiveData:(NSData*)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
   
    if (![Utilities checkIfError:dict]) {
        [UserDefaults setUserId:[dict valueForKeyPath:@"user.id"]];
        [UserDefaults setToken:[dict valueForKey:@"token"]];
        [UserDefaults setIsUserLogged:YES];
        
        [self.mainVC getReportCategories];

        if ([Utilities isIpad] && !self.isFromPerfil && !self.isFromSolicit ) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.mainVC btJump:nil];
        } else {
            
            if (!self.isFromPerfil && !self.isFromSolicit) {
                    TabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBar"];
                    [self.navigationController setNavigationBarHidden:YES];
                    [self.navigationController pushViewController:tabBar animated:YES];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
                [self.perfilVC getData];
                if ([Utilities isIpad]) {
                    [self.relateVC setToken];
                }
            }
        }
        
        
    }
}

- (void)didReceiveError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
}

- (void)didCancelButton {
    if ([Utilities isIpad]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        
        if (self.isFromInside || self.isFromPerfil || self.isFromSolicit)
            [self dismissViewControllerAnimated:YES completion:nil];
        else
            [self.navigationController popViewControllerAnimated:YES];
        
    }
    
    if (self.isFromPerfil || self.isFromSolicit) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"backToMapFromPerfil" object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidDisappear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:YES];
//}
//
- (void)viewWillAppear:(BOOL)animated {
    if (![Utilities isIpad]) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    
    CustomButton *btCreate = [[CustomButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
    [btCreate setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_normal-1"] forState:UIControlStateNormal];
    [btCreate setBackgroundImage:[UIImage imageNamed:@"menubar_btn_filtrar-editar_active-1"] forState:UIControlStateHighlighted];
    [btCreate setFontSize:14];
    [btCreate setTitle:@"Entrar" forState:UIControlStateNormal];
    [btCreate addTarget:self action:@selector(didLoginButton) forControlEvents:UIControlEventTouchUpInside];
    [btCreate setFrame:CGRectMake(self.navigationController.view.superview.bounds.size.width - 79, 5, 74, 35)];
    [self.navigationController.navigationBar addSubview:btCreate];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [textField setBackground:[UIImage imageNamed:@"textbox_1linha-larga_active"]];

    if (textField == self.tfEmail) {
        [self.tfPass setBackground:[UIImage imageNamed:@"textbox_1linha-larga_normal"]];

    } else {
        [self.tfEmail setBackground:[UIImage imageNamed:@"textbox_1linha-larga_normal"]];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.tfEmail)
        [self.tfPass becomeFirstResponder];
    else if (textField == self.tfPass) {
        [textField resignFirstResponder];
        [self.tfPass setBackground:[UIImage imageNamed:@"textbox_1linha-larga_normal"]];
    }
    
    return YES;
}

- (IBAction)btForogt:(id)sender {
    
    ForgotViewController *forgotVC = [[ForgotViewController alloc]initWithNibName:@"ForgotViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:forgotVC];
    
    [nav.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor blackColor], NSForegroundColorAttributeName,
      [Utilities fontOpensSansLightWithSize:14], NSFontAttributeName, nil]];

    if ([Utilities isIpad]) {
        [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    }
    
    [self presentViewController:nav animated:YES completion:nil];
    
    if ([Utilities isIpad]) {
        nav.view.superview.bounds = CGRectMake(-25, 0, 470, 620);
        [nav.view.superview setBackgroundColor:[UIColor clearColor]];
    }

}
@end