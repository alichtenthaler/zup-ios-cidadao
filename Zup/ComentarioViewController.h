//
//  ComentarioViewController.h
//  zup
//
//  Created by Igor Lira on 2/5/15.
//  Copyright (c) 2015 ntxdev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComentarioViewController : UIViewController
{
    NSDictionary* comentario;
}

@property (nonatomic, retain) IBOutlet UILabel* lblText;
@property (nonatomic, retain) IBOutlet UILabel* lblDate;

- (id)initWithComentario:(NSDictionary*)comentario;

@end
