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

@interface DetailFeedViewController () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UITextView *titlteTextView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (strong, nonatomic) NSMutableArray *navigationBarItems;
@property (strong, nonatomic) UIImagePickerController *imagePickerController;


@end

@implementation DetailFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self showEditButton];
    
    self.titlteTextView.delegate = self;
    self.subtitleTextView.delegate = self;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPhotoDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.photoImageView addGestureRecognizer:singleTap];
    
    if (self.feed) {
        self.titlteTextView.text = self.feed.title;
        self.subtitleTextView.text = self.feed.subtitle;
        [ImageDownloader downloadImageFromString:self.feed.imageName forIndexPath:nil completion:^(UIImage *image, NSIndexPath *indexPath) {
            self.photoImageView.image = image;
        }];
    }
}

- (void)tapOnPhotoDetected {
    [[self view] endEditing:YES];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"Take photo");
            [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [actionSheet addAction:[UIAlertAction actionWithTitle:@"Choose from galery" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"Choose from galary");
             [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }]];
    }
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:actionSheet animated:NO completion:nil];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <ImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [ImageDownloader uploadImage:UIImageJPEGRepresentation(image, 1.0)];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    self.photoImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
     [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - IBActions

- (IBAction)editFeed:(id)sender {    
    self.titlteTextView.editable = YES;
    self.subtitleTextView.editable = YES;
    [self.photoImageView setUserInteractionEnabled:YES];
    
    self.titlteTextView.textColor = [UIColor blackColor];
    
    if (self.feed) {
        self.subtitleTextView.textColor = [UIColor blackColor];
        
        self.titlteTextView.text = self.feed.title;
        self.subtitleTextView.text = self.feed.subtitle;
    }
    
    [self.titlteTextView becomeFirstResponder];
    
    [self showSaveButton];
}

- (IBAction)saveFeed:(id)sender {
    self.titlteTextView.editable = NO;
    self.subtitleTextView.editable = NO;
    
    [self showEditButton];
    
    [[FeedManager sharedInstance] updateOrAddFeed:self.feed accordingToChangedTitle:self.titlteTextView.text subtitle:self.subtitleTextView.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)dissmissKeyboardOnTap:(id)sender{
    [[self view] endEditing:YES];
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView == self.titlteTextView && [text isEqualToString:@"\n"]) {
        [self.titlteTextView resignFirstResponder];
        [self.subtitleTextView becomeFirstResponder];
        return NO;
    }
    return YES;
}

- (void)showSaveButton {
    [self.navigationBarItems removeObject:self.editButton];
    [self.navigationBarItems addObject:self.saveButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
}

- (void)showEditButton {
    NSMutableArray *navigationBarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    self.navigationBarItems = navigationBarItems;
    [self.navigationBarItems removeObject:self.saveButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
}

@end
