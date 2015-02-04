//
//  PerfilDetailViewController.m
//  Zup
//
//  Created by Renato Kuroe on 01/12/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

int EMABERTO = 0;
int EMANDAMENTO = 1;
int NAORESOLVIDO = 2;
int RESOLVIDO = 3;

#import "PerfilDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CustomMap.h"

@interface PerfilDetailViewController ()

@end

@implementation PerfilDetailViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)getDetails {
    
    if ([Utilities isInternetActive]) {
        ServerOperations *serverOp = [[ServerOperations alloc]init];
        [serverOp setTarget:self];
        [serverOp setAction:@selector(didReceiveData:)];
        [serverOp setActionErro:@selector(didReceiveError:data:)];
        [serverOp getReportDetailsWithId:[self.dictMain valueForKey:@"id"]];
    }
}

- (void)didReceiveData:(NSData*)data {
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [self buildStatusWithColor:[dict valueForKeyPath:@"report.status.color"] title:[dict valueForKeyPath:@"report.status.title"]];
    
    NSString *timeSentence = [Utilities calculateNumberOfDaysPassed:[dict valueForKeyPath:@"report.updated_at"]];
    [self.lblSubtitle setText:timeSentence];
}

- (void)didReceiveError:(NSError*)error data:(NSData*)data {
    [Utilities alertWithServerError];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.spin setHidesWhenStopped:YES];
    [self.pageControl setHidden:YES];
    [self.pageControl setHidesForSinglePage:YES];

    [self.lblTitle setFont:[Utilities fontOpensSansBoldWithSize:11]];
    
    [self.lblCategoria setFont:[Utilities fontOpensSansWithSize:11]];
    
    [self.lblName setFont:[Utilities fontOpensSansLightWithSize:16]];
    [self.lblName setMinimumScaleFactor:0.5];
    
    [self.lblSubtitle setFont:[Utilities fontOpensSansBoldWithSize:10]];
    
    [self.lblAddress setText:[self.dictMain valueForKey:@"address"]];
    [self.lblAddress setFont:[Utilities fontOpensSansLightWithSize:11]];
    
    [self.lblDesc setText:[Utilities checkIfNull:[self.dictMain valueForKey:@"reference"]]];
    [self.lblDesc setFont:[Utilities fontOpensSansLightWithSize:11]];
    
    [self.lblAddress setMinimumScaleFactor:0.5];
    
    if (self.lblAddress.text.length == 0 && ![Utilities isIpad]) {
        
        CGRect frame = self.lblName.frame;
        //frame.size.height += 15;
        //[self.lblName setFrame:frame];
    
    }
    
    if([Utilities isIpad])
    {
        CGRect frm = self.lblName.frame;
        frm.origin.y -= 15;
        
        //self.lblName.frame = frm;
    }
    
    [self getDetails];
        
    NSDictionary *catDict;
    if ([self.dictMain valueForKeyPath:@"category.id"]) {
        catDict = [UserDefaults getCategory:[[self.dictMain valueForKeyPath:@"category.id"]integerValue]];
    } else if ([self.dictMain valueForKeyPath:@"category_id"]) {
        catDict = [UserDefaults getCategory:[[self.dictMain valueForKeyPath:@"category_id"]integerValue]];
    } else if ([self.dictMain valueForKeyPath:@"inventory_category_id"]) {
        catDict = [UserDefaults getInventoryCategory:[[self.dictMain valueForKeyPath:@"inventory_category_id"]integerValue]];
    }
    
    if([catDict valueForKey:@"parent_id"] != nil) // Categoria possui pai
    {
        NSNumber* parentcatid = [catDict valueForKey:@"parent_id"];
        NSDictionary* parentcatdict = [UserDefaults getCategory:[parentcatid intValue]];
        
        if([Utilities isIpad]) // No iPad, as posições são trocadas
        {
            if ([parentcatdict valueForKey:@"title"]) {
                [self.lblCategoria setText:[Utilities checkIfNull:[parentcatdict valueForKey:@"title"]]];
            }
            if ([catDict valueForKey:@"title"]) {
                [self.lblName setText:[Utilities checkIfNull:[catDict valueForKey:@"title"]]];
            }
        }
        else
        {
            if ([parentcatdict valueForKey:@"title"]) {
                [self.lblName setText:[Utilities checkIfNull:[parentcatdict valueForKey:@"title"]]];
            }
            if ([catDict valueForKey:@"title"]) {
                [self.lblCategoria setText:[Utilities checkIfNull:[catDict valueForKey:@"title"]]];
            }
        }
        
        self.lblCategoria.hidden = NO;
    }
    else
    {
        if ([catDict valueForKey:@"title"]) {
            [self.lblName setText:[catDict valueForKey:@"title"]];
        }
        
        if(![Utilities isIpad])
        {
            CGRect tframe = self.lblName.frame;
            tframe.origin.y += 4;
            tframe.size.height += 15;
            self.lblName.frame = tframe;
        }
        
        self.lblCategoria.hidden = YES;
    }
    
    UIImage* icon = [UIImage imageWithData:[catDict valueForKey:@"iconDataDisabled"]];
    self.imgIcon.image = icon;
    
    if ([self.dictMain valueForKey:@"updated_at"]) {
        NSString *timeSentence = [Utilities calculateNumberOfDaysPassed:[self.dictMain valueForKey:@"updated_at"]];
        [self.lblSubtitle setText:timeSentence];
    }

    
    [self.lblTitle setText:[NSString stringWithFormat:@"PROTOCOLO %@", [self.dictMain valueForKey:@"protocol"]]];
    [self.tvDesc setFont:[Utilities fontOpensSansWithSize:12]];
    [self.tvDesc setText:[Utilities checkIfNull:[self.dictMain valueForKey:@"description"]]];
    
    
    [self buildStatusWithColor:[self.dictMain valueForKeyPath:@"status.color"] title:[self.dictMain valueForKeyPath:@"status.title"]];
    
    
    [self.navigationItem setHidesBackButton:YES];
    
    [self buildScroll];
    
    // Só exibe o protocolo se for o criador do relato
    if([[self.dictMain valueForKeyPath:@"user.id"] intValue] != [[UserDefaults getUserId] intValue])
    {
        [self.lblTitle setHidden:YES];
    }
    
}

- (void)buildStatusWithColor:(NSString*)colorStr title:(NSString*)title {
    
    colorStr = [colorStr stringByReplacingOccurrencesOfString:@"#" withString:@""];
    UIColor *color = [Utilities colorWithHexString:colorStr];
    [self.lblStatus setText:title];
    [self.lblStatus setBackgroundColor:color];
    [self.lblStatus.layer setCornerRadius:10];
    [self.lblStatus setClipsToBounds:YES];
    self.lblStatus.text = self.lblStatus.text.uppercaseString;
    [self.lblStatus setFont:[Utilities fontOpensSansExtraBoldWithSize:11]];

    float currentW = self.lblStatus.frame.size.width;
    float width = [Utilities expectedWidthWithLabel:self.lblStatus];
    CGRect frame = self.lblStatus.frame;
    frame.size.width = width + 20;
    //frame.origin.x += currentW - width - 20;
    
    [self.lblStatus setFrame:frame];

}

- (void)buildMap {
    
    NSString *latStr = [self.dictMain valueForKeyPath:@"position.latitude"];
    
    NSString *lngStr = [self.dictMain valueForKeyPath:@"position.longitude"];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latStr.floatValue, lngStr.floatValue);
    
    CustomMap *map = [[CustomMap alloc]init];
    [map setFrame:self.scrollImages.frame];
    
    if ([Utilities isIpad]) {
        [self.view addSubview:map];
    } else {
        [self.scroll addSubview:map];
    }
    
    NSString *catStr = nil;
    BOOL isReport = YES;

    if ([self.dictMain valueForKeyPath:@"category.id"]) {
        catStr = [self.dictMain valueForKeyPath:@"category.id"];
    } else if ([self.dictMain valueForKey:@"category_id"]) {
        catStr = [self.dictMain valueForKey:@"category_id"];
    }
    
   
    [map setPositionWithLocation:coord andCategory:[catStr integerValue] isReport:isReport];
    [map setUserInteractionEnabled:NO];
    
}

- (void)viewWillAppear:(BOOL)animated {
    btCancel = [[CustomButton alloc] initWithFrame:CGRectMake(0, 5, 56, 35)];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_voltar_normal-1"] forState:UIControlStateNormal];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_voltar_active-1"] forState:UIControlStateHighlighted];
    [btCancel setFontSize:14];
    [btCancel setTitle:@"Voltar" forState:UIControlStateNormal];
    [btCancel addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:btCancel];

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [btCancel removeFromSuperview];
    
//    [self.navigationController popViewControllerAnimated:YES];

}


- (void)buildScroll {
    
    NSArray *arrImages = [self.dictMain valueForKey:@"images"];
    
    if (arrImages.count == 0) {
        [self buildMap];
    } else {
        [self.spin startAnimating];
    }
    
    int i = 0;
    float sideSize = 320;
    
    for (NSDictionary *dict in arrImages) {
        UIImageView *imgV = [[UIImageView alloc]init];
        [imgV setImageWithURL:[NSURL URLWithString:[dict valueForKeyPath:@"high"]]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {

            if (i == arrImages.count-1
                ) {
                [self.spin stopAnimating];
                [self.pageControl setHidden:NO];
            }
            
        }];
        
        [imgV setFrame:CGRectMake(sideSize * i, 0, sideSize, sideSize)];
        [self.scrollImages addSubview:imgV];
        
        
        i ++;
    }
    
    
    
    [self.scrollImages setContentSize:CGSizeMake(sideSize * i, sideSize)];
    [self.pageControl setNumberOfPages:i];

    CGRect frame;
    
    if ([Utilities isIpad]) {
        frame = CGRectMake(54, 98, 240, 20);
       
    } else {
        frame = CGRectMake(10, self.scrollImages.frame.size.height + self.scrollImages.frame.origin.y + 10, 300, 20);
    }

    if (self.isFromFeed) {
        
        [self.tvDesc removeFromSuperview];
        
        UILabel *currentLabel;
        for (NSDictionary *dict in [self.dictMain valueForKey:@"values"]) {
            NSString *strTitle = [dict valueForKey:@"title"];
            strTitle = [strTitle uppercaseString];
            NSString *strDesc = [dict valueForKey:@"desc"];
            
            UILabel *lbl = [[UILabel alloc]init];
            [lbl setText:strTitle];
            [lbl setFrame:frame];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setFont:[Utilities fontOpensSansBoldWithSize:12]];
            [lbl setTextColor:[UIColor blackColor]];
            if ([Utilities isIpad]) {
                [self.view addSubview:lbl];
            } else {
                [self.scroll addSubview:lbl];
            }
            
            frame.origin.y += 18;
            
            
            UILabel *lbl2 = [[UILabel alloc]init];
            [lbl2 setText:strDesc];
            [lbl2 setFrame:frame];
            [lbl2 setFont:[Utilities fontOpensSansWithSize:12]];
            [lbl2 setBackgroundColor:[UIColor clearColor]];
            [lbl2 setTextColor:[Utilities colorGray]];
            
            if ([Utilities isIpad]) {
                [self.view addSubview:lbl2];
            } else {
                [self.scroll addSubview:lbl2];
            }
            
            frame.origin.y += 25;
            
            currentLabel = lbl2;
        }
        
        
        if (![Utilities isIpad]) {
            [self.scroll setContentSize:CGSizeMake(320, currentLabel.frame.origin.y + currentLabel.frame.size.height + 10)];

          

            [self.scroll setContentInset:UIEdgeInsetsMake(-64, 0, 0, 0)];
            
            [self.lblName removeFromSuperview];
            [self.lblSubtitle removeFromSuperview];
            

        }
        
      
    } else {
        [self.scroll setContentSize:CGSizeMake(320, self.tvDesc.frame.origin.y + self.tvDesc.frame.size.height + 10)];
        
        if ([self.dictMain valueForKey:@"texto"] && [[self.dictMain valueForKey:@"texto"]length] > 0) {
            CGSize size = [Utilities sizeOfText:self.tvDesc.text widthOfTextView:self.tvDesc.frame.size.width withFont:self.tvDesc.font];
            CGRect frameDesc = self.tvDesc.frame;
            
            if (arrImages.count == 0) {
                frameDesc.origin.y = 59;
                [self.scrollImages setHidden:YES];
                [self.pageControl setHidden:YES];
            }
            
            size.height += 30;
            frameDesc.size = size;
            
            if ([Utilities isIpad]) {
                frameDesc.origin.x -= 16;
            }
            [self.tvDesc setFrame:frameDesc];
            
            
        }
    }

 

    if (![Utilities isIpad]) {
      
    } else {
        CGRect frame = self.viewBg.frame;
        frame.size.height = self.tvDesc.frame.size.height + 63;
        [self.viewBg setFrame:frame];
        
        CGRect frameLbl = self.lblSubtitle.frame;
        frameLbl.origin.x -=16;
        [self.lblSubtitle setFrame:frameLbl];

    }
   
    
    [self.pageControl setHidesForSinglePage:YES];

}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.scrollImages.frame.size.width;
    int page = floor((self.scrollImages.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)popView {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end