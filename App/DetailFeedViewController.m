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
#import "FeedViewController.h"

@interface DetailFeedViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *titlteTextView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;


@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) FeedManager *feedManager;
@property (strong, nonatomic) NSMutableArray *navigationBarItems;
//@property (strong, nonatomic) UIImagePickerController *imagePickerController;



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
    
    if (self.feed) {
        self.titlteTextView.text = self.feed.title;
        self.subtitleTextView.text = self.feed.subtitle;
        
        [ImageDownloader downloadImageFromString:self.feed.imageName forIndexPath:nil completion:^(UIImage *image, NSIndexPath *indexPath) {
            self.photoImageView.image = image;
        }];
    } else {
        self.titlteTextView.delegate = self;
        self.titlteTextView.text = @"What's happening?";
        self.titlteTextView.textColor = [UIColor lightGrayColor];
        
        self.subtitleTextView.delegate = self;
        self.subtitleTextView.text = @"What's happening?";
        self.subtitleTextView.textColor = [UIColor lightGrayColor];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)editFeed:(id)sender {    
    self.titlteTextView.editable = YES;
    self.subtitleTextView.editable = YES;
    
    self.titlteTextView.text = self.feed.title;
    self.subtitleTextView.text = self.feed.subtitle;
    
    [self.titlteTextView becomeFirstResponder];
    
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
    
    [self.feedManager updateOrAddFeed:self.feed accordingToChangedTitle:self.titlteTextView.text subtitle:self.subtitleTextView.text];
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ( textView == self.titlteTextView && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.subtitleTextView becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (textView.textColor == [UIColor grayColor]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void) textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor lightGrayColor];
        if (textView == self.titlteTextView ) {
            textView.text = @"Write your title here";
        } else {
            textView.text = @"Write your subtitle here";
        }
        [textView resignFirstResponder];
    }
    
}









@end
