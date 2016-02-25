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
#import "ImageDownloader.h"
#import "Feed.h"
#import "AppDelegate.h"
#import "DetailFeedViewController.h"
#import "AuthorizationViewController.h"
#import "AuthorizationManager.h"


@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, ContentManagerDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityIndicatorItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *synchronizeButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) ContentManager *contentManager;
@property (strong, nonatomic) FeedManager *feedManager;
@property (strong, nonatomic) AuthorizationManager *authManager;
@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) NSDate *lastLoginDate;

@property (strong, nonatomic) NSMutableArray *navigationBarItems;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSNumber *isAlreadyLogedIn;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 140.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.isAlreadyLogedIn = [NSNumber numberWithBool:FALSE];
    
    self.contentManager = [[ContentManager alloc] init];
    self.contentManager.delegate = self;

    id feedManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] feedManager] ;
    self.feedManager = feedManager;
    
    NSFetchedResultsController *fetchedResultsController = self.feedManager.fetchedResultsController;
    fetchedResultsController.delegate = self;
    self.fetchedResultsController = fetchedResultsController;

    NSMutableArray *navigationBarItems = [self.navigationItem.rightBarButtonItems mutableCopy];
    self.navigationBarItems = navigationBarItems;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error %@, %@", error, [error userInfo]);
    }
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = [UIColor blackColor];
    activityIndicator.center = self.view.center;
    self.activityIndicator = activityIndicator;
    [self.view addSubview:self.activityIndicator];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    if ([user objectForKey:@"token"]) {
        if ([self.isAlreadyLogedIn isEqualToNumber:[NSNumber numberWithBool:FALSE]]) {
            
            [self.activityIndicator startAnimating];
            
            AuthorizationManager *authManager = [[AuthorizationManager alloc] init];
            self.authManager = authManager;
            
            [self.authManager isSessionValidWithUserToken:[user objectForKey:@"token"] completion:^(bool isValid) {
                if (isValid) {
                    [self.activityIndicator stopAnimating];
                    self.isAlreadyLogedIn = [NSNumber numberWithBool:TRUE];
                    
                } else {
                    [self performSegueWithIdentifier:@"ShowAuthorizationController" sender:self];
                }
            }];
        }
    } else {
        self.isAlreadyLogedIn = [NSNumber numberWithBool:TRUE];
        [self performSegueWithIdentifier:@"ShowAuthorizationController" sender:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - IBActions

- (IBAction)addFeed:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"AddFeedSegue" sender:nil];
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    if (![self.navigationItem.rightBarButtonItems containsObject:self.activityIndicatorItem]) {
        [self.navigationBarItems addObject:self.activityIndicatorItem];
    }
    [self.navigationBarItems removeObject:self.synchronizeButton];
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.color = self.view.tintColor;
    [activityIndicator startAnimating];
    
    self.activityIndicatorItem.customView = activityIndicator;
    
    NSArray *feedsToBeUploaded = [self.feedManager changedFeeds];
    if (feedsToBeUploaded.count > 0) {
        [self.contentManager putChangesOnServer:feedsToBeUploaded];
    }
    else {
        [self.contentManager downloadContent];
    }
}


#pragma mark - <ContentManagerDelegate>

- (void)contentManager:(ContentManager *)contentManager didDownloadContentToArray:(NSArray *)array {
    [self.feedManager manageObjects:array];
    
    [self.activityIndicatorItem.customView stopAnimating];
    [self.navigationBarItems removeObject:self.activityIndicatorItem];
    
    if (![self.navigationItem.rightBarButtonItems containsObject:self.synchronizeButton]) {
        [self.navigationBarItems addObject:self.synchronizeButton];
    }
    [self.navigationItem setRightBarButtonItems:self.navigationBarItems animated:YES];
}

- (void)contentManagerDidUploadObjectsToServer:(ContentManager *)contentManager {
    [self.contentManager downloadContent];
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
    
    __weak FeedViewController *weakSelf = self;
    [ImageDownloader downloadImageFromString:feed.imageName forIndexPath:indexPath completion:^(UIImage *image, NSIndexPath *indexPath) {
        __strong FeedViewController *strongSelf = weakSelf;
        if (strongSelf) {
            FeedCell *cell = [strongSelf.tableView cellForRowAtIndexPath:indexPath];
            if (cell) {
                cell.photoImageView.image = image;
            }
        }
    }];
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

@end
