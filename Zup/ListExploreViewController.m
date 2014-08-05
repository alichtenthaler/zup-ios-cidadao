//
//  ListExploreViewController.m
//  Zup
//
//  Created by Renato Kuroe on 02/12/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "ListExploreViewController.h"
#import "CellMinhaConta.h"
#import "CustomMap.h"

@interface ListExploreViewController ()

@end

@implementation ListExploreViewController

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
    
    [self.lblNoSolicits setHidden:YES];

    [self.table registerNib:[UINib nibWithNibName:@"CellMinhaConta" bundle:nil] forCellReuseIdentifier:@"CellConta"];
    
    [super viewDidLoad];
    
    for (UIButton *bt in self.arrBt) {
        [bt.titleLabel setFont:[Utilities fontOpensSansWithSize:14]];
    }
    
    [self setTitle:self.strTitle];
    
    [self.navigationItem setHidesBackButton:YES];
    
    if ([Utilities isIpad]) {
        CGRect tableFrame = self.table.frame;
        tableFrame.origin.x = 50;
        tableFrame.origin.y = 50;
        tableFrame.size.height +=10;
        [self.table setFrame:tableFrame];
    }
    
    
    if (!self.isColeta) {
        NSString *nibName = nil;
        if ([Utilities isIpad]) {
            nibName = @"PerfilDetailViewController_iPad";
        } else {
            nibName = @"PerfilDetailViewController";
        }
        
        detailView = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
        detailView.isFromFeed = YES;
        detailView.dictMain = self.dictMain;
        
        if ([Utilities isIpad]) {
            [detailView.view setFrame:self.view.frame];
            
        } else {
            [detailView.view setFrame:self.table.frame];
            
        }
        [self.view addSubview:detailView.view];
        
        for (UIButton *newBt in self.arrBt) {
            if (self.btInfo == newBt) {
                [newBt setSelected:YES];
            } else
                [newBt setSelected:NO];
        }
        
    }
    
    [detailView.view setHidden:YES];
    
    [self getDetails];
    //    [self removeLabelSolcitations];
}

- (void)removeLabelSolcitations {
    
    CGRect frameBt = self.btInfo.frame;
    frameBt.origin.x = 110;
    [self.btInfo setFrame:frameBt];
    
    [self.btSolicit setHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    btCancel = [[CustomButton alloc] initWithFrame:CGRectMake(0, 5, 56, 35)];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_voltar_normal-1"] forState:UIControlStateNormal];
    [btCancel setBackgroundImage:[UIImage imageNamed:@"menubar_btn_voltar_active-1"] forState:UIControlStateHighlighted];
    [btCancel setFontSize:14];
    [btCancel setTitle:@"Voltar" forState:UIControlStateNormal];
    [btCancel addTarget:self action:@selector(btBack) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.navigationBar addSubview:btCancel];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [btCancel removeFromSuperview];
}

- (void)btBack {
    [btCancel removeFromSuperview];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btSolicit:(id)sender {
    
    isSolicit = YES;
    [self.table setHidden:YES];
    UIButton *bt = (UIButton*)sender;
    
    for (UIButton *newBt in self.arrBt) {
        if (bt == newBt) {
            [newBt setSelected:YES];
        } else
            [newBt setSelected:NO];
    }
    
    [self getRequests];
//    if (!detailView) {
//        NSString *nibName = nil;
//        if ([Utilities isIpad]) {
//            nibName = @"PerfilDetailViewController_iPad";
//        } else {
//            nibName = @"PerfilDetailViewController";
//        }
    
//        detailView = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
//        //        detailView.isFromFeed = YES;
//        detailView.dictMain = self.dictMain;
//        
//        if ([Utilities isIpad]) {
//            
//            CGRect frame = self.view.frame;
//            frame.origin.y = 50;
//            frame.size.height -= 50;
//            [detailView.view setFrame:frame];
//            [detailView.view setBackgroundColor:[Utilities colorGrayLight]];
//        } else {
//            [detailView.view setFrame:self.table.frame];
//            
//        }
//        [self.view addSubview:detailView.view];
//    }
    
//    [detailView.view setHidden: NO];

}

- (IBAction)btMenu:(id)sender {
    
    isSolicit = NO;
    [self getDetails];
    
    UIButton *bt = (UIButton*)sender;
    
    for (UIButton *newBt in self.arrBt) {
        if (bt == newBt) {
            [newBt setSelected:YES];
        } else
            [newBt setSelected:NO];
    }
    if (detailView) {
        [detailView.view setHidden:YES];
    }
    
}

#pragma mark - Request Info

- (void)getDetails {
    
    [self.lblNoSolicits setHidden:YES];
    [self.table setHidden:YES];
    [self.spin startAnimating];
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveData:)];
    [server setActionErro:@selector(didReceiveError:)];
    [server getInventoryDetailsWithId:[self.dictMain valueForKey:@"inventory_category_id"] idItem:[self.dictMain valueForKey:@"id"]];
}

- (void)didReceiveData:(NSData*)data {
    
    [self.spin stopAnimating];
    [self.table setHidden:NO];

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    NSArray *arrData = [dict valueForKeyPath:@"item.data"];
    
    NSMutableArray *arrTempForTable = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in arrData) {
        NSString *titleStr = [UserDefaults getTitleForFieldId:[[dict valueForKey:@"inventory_field_id"]intValue] idCat:[[self.dictMain valueForKey:@"inventory_category_id"]intValue]];
        NSString *content = [dict valueForKey:@"content"];
        NSDictionary *dictTemp = @{@"title": titleStr,
                                   @"content" : content};
        
        [arrTempForTable addObject:dictTemp];
        
    }
    self.arrMain = [[NSArray alloc]initWithArray:arrTempForTable];
    [self.table reloadData];
    
    if ([Utilities isIpad]) {
        [self buildMap];
    }
}

- (void)didReceiveError:(NSError*)error {
    [Utilities alertWithServerError];
    [self.spin stopAnimating];
}


#pragma mark - Request Requests

- (void)getRequests {
    
    [self.lblNoSolicits setHidden:YES];

    [self.spin startAnimating];
    ServerOperations *server = [[ServerOperations alloc]init];
    [server setTarget:self];
    [server setAction:@selector(didReceiveRequestData:)];
    [server setActionErro:@selector(didReceiveError:)];
    [server getReportItemsForInventory:[self.dictMain valueForKey:@"id"]];
}

- (void)didReceiveRequestData:(NSData*)data {
    
    [self.spin stopAnimating];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    
    [self.table setHidden:NO];

    self.arrMain = [[NSArray alloc]initWithArray:[dict valueForKey:@"reports"]];
    [self.table reloadData];
    
    if (self.arrMain.count == 0) {
        [self.lblNoSolicits setHidden:NO];
    }
    
    if ([Utilities isIpad]) {
        [self buildMap];
    }
}

- (void)buildMap {
    
    NSString *latStr = [self.dictMain valueForKeyPath:@"position.latitude"];
    
    NSString *lngStr = [self.dictMain valueForKeyPath:@"position.longitude"];
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latStr.floatValue, lngStr.floatValue);
    
    CustomMap *map = [[CustomMap alloc]init];
    CGRect frame = self.table.frame;
    frame.size.height = frame.size.width;
    frame.origin.x = self.table.frame.size.width + self.table.frame.origin.x + 30;
    [map setFrame:frame];
    
    if ([Utilities isIpad]) {
        [self.view addSubview:map];
    }
    
    
    NSString *catStr = nil;
    BOOL isReport = YES;
    
    if ([self.dictMain valueForKey:@"inventory_category_id"]) {
        catStr = [self.dictMain valueForKeyPath:@"inventory_category_id"];
        isReport = NO;
    } else if ([self.dictMain valueForKeyPath:@"category.id"]) {
        catStr = [self.dictMain valueForKeyPath:@"category.id"];
    } else if ([self.dictMain valueForKey:@"category_id"]) {
        catStr = [self.dictMain valueForKey:@"category_id"];
    }

    
    [map setPositionWithLocation:coord andCategory:[catStr intValue] isReport:isReport];
    [map setUserInteractionEnabled:NO];
    
}


#pragma mark - Table View Delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSolicit) {
        return 80;
    }
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrMain.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (isSolicit) {
        CellMinhaConta *cell = [tableView dequeueReusableCellWithIdentifier:@"CellConta"];
        
        if(cell == nil)
        {
            cell = [[CellMinhaConta alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellConta"];
        }
        
        [cell setvalues:[self.arrMain objectAtIndex:indexPath.row]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
        
    } else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        }
        
        NSDictionary *dict = [self.arrMain objectAtIndex:indexPath.row];
        [cell.textLabel setText:[[dict valueForKey:@"title"]uppercaseString]];
        NSString *value = [dict valueForKey:@"content"];

        if ([value isKindOfClass:[NSNull class]]) {
            value = @"";
        }
        
        if ([value isKindOfClass:[NSArray class]]) {
            value = [(NSArray *)value componentsJoinedByString:@", "];
        }
        
        [cell.detailTextLabel setText:value];
        
        [cell.textLabel setFont:[Utilities fontOpensSansBoldWithSize:12]];
        [cell.textLabel setTintColor:[Utilities colorGray]];
        [cell.detailTextLabel setFont:[Utilities fontOpensSansWithSize:13]];
        [cell.detailTextLabel setTintColor:[Utilities colorGrayLight]];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        return cell;

    }
    
    return nil;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.01f;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (isSolicit) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSString *nibName = nil;
        if ([Utilities isIpad]) {
            nibName = @"PerfilDetailViewController_iPad";
        } else {
            nibName = @"PerfilDetailViewController";
        }
        PerfilDetailViewController *perfilDetailVC = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
        perfilDetailVC.dictMain = [self.arrMain objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:perfilDetailVC animated:YES];
    }
    
    //    NSString *nibName = nil;
    //    if ([Utilities isIpad]) {
    //        nibName = @"PerfilDetailViewController_iPad";
    //    } else {
    //        nibName = @"PerfilDetailViewController";
    //    }
    //
    //    PerfilDetailViewController *perfilDetailVC = [[PerfilDetailViewController alloc]initWithNibName:nibName bundle:nil];
    //    perfilDetailVC.dictMain = [self.arrMain objectAtIndex:indexPath.row];
    //    [self.navigationController pushViewController:perfilDetailVC animated:YES];
    //
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
