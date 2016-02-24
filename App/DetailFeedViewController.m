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
#import "FeedManager.h"

@interface DetailFeedViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *titlteTextView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;
@property (weak, nonatomic) FeedManager *feedManager;


@property (strong, nonatomic) NSString *userToken;

@end

@implementation DetailFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id userToken = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userToken] ;
    self.userToken = userToken;
    
    self.titlteTextView.text = self.feed.title;
    self.subtitleTextView.text = self.feed.subtitle;
    [ImageDownloader downloadImageFromString:self.feed.imageName forIndexPath:nil completion:^(UIImage *image, NSIndexPath *indexPath) {
        self.photoImageView.image = image;
    }];    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)editFeed:(id)sender {
    self.titlteTextView.editable = YES;
    self.subtitleTextView.editable = YES;
}

- (IBAction)saveFeed:(id)sender {
    FeedManager *feedManager = [[FeedManager alloc] init];
    self.feedManager = feedManager;
    [self.feedManager updateFeed:self.feed accordingToChangedTitle:self.titlteTextView.text subtitle:self.subtitleTextView.text];
}


#pragma mark - <UITextFieldDelegate>

@end
