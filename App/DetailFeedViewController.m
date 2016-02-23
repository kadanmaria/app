//
//  DetailFeedViewController.m
//  App
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "DetailFeedViewController.h"

@interface DetailFeedViewController ()

@property (weak, nonatomic) IBOutlet UILabel *someLabel;

@end

@implementation DetailFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    NSString *string = [NSString stringWithFormat:@"%lu", self.someProperty.row];
//    self.someLabel.text = string;
//    
    self.someLabel.text = self.userToken;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
