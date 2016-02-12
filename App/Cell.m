//
//  Cell.m
//  testApp
//
//  Created by Admin on 03.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.subTitleLabel.text = nil;
    self.photoImageView.image = nil;
    self.cellIndex = nil;
}

@end