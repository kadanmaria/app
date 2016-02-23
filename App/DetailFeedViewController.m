//
//  DetailFeedViewController.m
//  App
//
//  Created by Admin on 22.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "DetailFeedViewController.h"
#import "AppDelegate.h"
#import "ImageDownloader.h"

@interface DetailFeedViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *titlteTextView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;


@property (strong, nonatomic) NSString *userToken;

@end

@implementation DetailFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id userToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userToken] ;
    self.userToken = userToken;
//    self.titleLabel.text = self.userToken;
    self.titlteTextView.text = self.feed.title;
//    self.subtitleTextField.text = nil;
    self.subtitleTextView.text = self.feed.subtitle;
    
    [ImageDownloader downloadImageFromString:self.feed.imageName forIndexPath:nil completion:^(UIImage *image, NSIndexPath *indexPath) {
        self.photoImageView.image = image;
    }];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
