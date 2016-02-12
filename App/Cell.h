//
//  Cell.h
//  testApp
//
//  Created by Admin on 03.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (assign, nonatomic) NSInteger *cellIndex;

@end
