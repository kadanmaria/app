//
//  ViewController.m
//  App
//
//  Created by Admin on 07.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "FeedViewController.h"
#import "FeedCell.h"
#import "ContentManager.h"
#import "ImageManager.h"
#import "Feed.h"
#import "AppDelegate.h"
#import "DetailFeedViewController.h"
#import "AuthorizationViewController.h"
#import "AuthorizationManager.h"
#import "FeedManager.h"


@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, ContentManagerDelegate, NSFetchedResultsControllerDelegate, AuthorizationManagerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *synchronizeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) ContentManager *contentManager;
@property (strong, nonatomic) AuthorizationManager *authManager;
@property (strong, nonatomic) AppDelegate *appDelegate;


@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 140.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.contentManager = [[ContentManager alloc] init];
    self.contentManager.delegate = self;

    AuthorizationManager *authManager = [[AuthorizationManager alloc] init];
    authManager.delegate = self;
    self.authManager = authManager;
    
    id appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.appDelegate = appDelegate;
    
    NSFetchedResultsController *fetchedResultsController = [[FeedManager sharedInstance] fetchedResultsController];

    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        [self showAlertWithTitle:@"Data problem" message:@"Ooops! Data fetching problem!"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self enableButtons:NO];
    [self.appDelegate startThinkingInViewController:self];
    [self.authManager isSessionValid];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <AuthorisationManagerDelegate>

- (void)authorizationManagerSessionIsNotValid {
    [self.appDelegate stopThinkingInViewController:self];
    [self performSegueWithIdentifier:@"ShowAuthorizationController" sender:self];
}

- (void)authorizationManagerSessionIsValid{
    [self enableButtons:YES];
    [self.appDelegate stopThinkingInViewController:self];
}

- (void)authorizationManager:(AuthorizationManager *)manager validationHasExecutedWithError:(NSError *)error {
    [self showAlertWithTitle:@"Log in problem" message:@"Ooops! Validation has exequted with error!"];
    [self.appDelegate stopThinkingInViewController:self];
}

#pragma mark - IBActions

- (IBAction)addFeed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"AddFeedSegue" sender:nil];
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    [self enableButtons:NO];
    [self.appDelegate startThinkingInViewController:self];
    
    [ImageManager uploadImagesWithCompletion:^(NSError *error) {
        if (!error) {
             [self.contentManager putChangesToServer];
        } else {
            [self showAlertWithTitle:@"Synchronize problem" message:@"Please, try again later."];
            [self.appDelegate stopThinkingInViewController:self];
        }
    }];
}


#pragma mark - <ContentManagerDelegate>

- (void)contentManager:(ContentManager *)contentManager didDownloadContentToArray:(NSArray *)array {
    [self enableButtons:YES];
    [self.appDelegate stopThinkingInViewController:self];
    
    [[FeedManager sharedInstance] manageObjects:array];
}

- (void)contentManagerDidUploadObjectsToServer {
    [self.contentManager downloadContent];
}

- (void)contentManager:(ContentManager *)contentManager hasExecutedWithError:(NSError *)error {
    [self showAlertWithTitle:@"Synchronize problem" message:@"Please, try again later."];
    [self.appDelegate stopThinkingInViewController:self];
}

#pragma mark - <TableViewDataSourse>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedCell *cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(FeedCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.titleLabel.text = feed.title;
    cell.subTitleLabel.text = feed.subtitle;
    
    if (!feed.localImage) {
        __weak FeedViewController *weakSelf = self;
        [ImageManager downloadImageFromString:feed.imageName forIndexPath:indexPath completion:^(UIImage *image, NSIndexPath *indexPath) {
            __strong FeedViewController *strongSelf = weakSelf;
            if (strongSelf) {
                FeedCell *cell = [strongSelf.tableView cellForRowAtIndexPath:indexPath];
                if (cell) {
                    cell.photoImageView.image = image;
                }
            }
        }];
    } else {
        cell.photoImageView.image = [UIImage imageWithData:feed.localImage];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"CellFeedSegue"]) {
        DetailFeedViewController *detailController = [segue destinationViewController];
        detailController.feed = [self.fetchedResultsController objectAtIndexPath:self.tableView.indexPathForSelectedRow];
    }
    
    if ([[segue identifier] isEqualToString:@"AddSegue"]) {
        DetailFeedViewController *detailController = [segue destinationViewController];
        detailController.feed = nil;
    }
}

#pragma mark - <NSFetchedResultsControllerDelegate>

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch (type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch (type) {

        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark - Other

- (void)enableButtons:(BOOL)how {
    NSArray *buttons = self.navigationItem.rightBarButtonItems;
    for (UIBarButtonItem *button in buttons) {
        button.enabled = how;
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:NO completion:nil];
}

@end
