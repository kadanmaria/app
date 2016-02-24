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

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) FeedManager *feedManager;
@property (strong, nonatomic) NSMutableArray *navigationBarItems;

@property (strong, nonatomic) NSString *userToken;


@end

@implementation DetailFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id feedManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] feedManager];
    self.feedManager = feedManager;
    
    NSMutableArray *navigationBarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    self.navigationBarItems = navigationBarItems;
    [self.navigationBarItems removeObject:self.saveButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
    
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
    
    [self.navigationBarItems removeObject:self.editButton];
    [self.navigationBarItems addObject:self.saveButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
}

- (IBAction)saveFeed:(id)sender {
    self.titlteTextView.editable = NO;
    self.subtitleTextView.editable = NO;
    
    [self.navigationBarItems removeObject:self.saveButton];
    [self.navigationBarItems addObject:self.editButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
    
    [self.feedManager updateFeed:self.feed accordingToChangedTitle:self.titlteTextView.text subtitle:self.subtitleTextView.text];
}


#pragma mark - <UITextFieldDelegate>

@end
