//
//  ViewController.m
//  App
//
//  Created by Admin on 07.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import "ContentDownloader.h"
#import "ImageDownloader.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, ContentDownloaderDelegate, ImageDownloaderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSArray *dataArray;
@property (strong, nonatomic) NSCache *imagesCache;
@property (strong, nonatomic) ContentDownloader *contentDownloader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 140.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.contentDownloader = [[ContentDownloader alloc] init];
    self.contentDownloader.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - <ContentDownloaderDelegate>

- (void)contentDownloader:(ContentDownloader *)contentDownloader didDownloadContentToArray:(NSArray *)array {
    self.dataArray = array;
    
    self.images = [[NSMutableArray alloc] init];
    for (int i=0; i<self.dataArray.count; i++) {
        ImageDownloader *image = [[ImageDownloader alloc] init];
        image.delegate = self;
        [self.images addObject:image];
    }
    [self.tableView reloadData];
}

#pragma mark - <ImageDownloaderDelegate>

- (void)imageDownloader:(ImageDownloader *)imageDownloader didDownloadImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.photoImageView.image = image;
        [self.imagesCache setObject:image forKey:indexPath];
    }
}

#pragma mark - IBActions

- (IBAction)refresh:(UIButton *)sender {
    NSLog(@"REFRESH");
    self.imagesCache = [[NSCache alloc] init]; //MAY INCORRECT WORK AFTER BACKGROWND+ADDING NEW FEEDS
    [self.contentDownloader downloadContent];
}

#pragma mark - <TableViewDataSourse>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.titleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"title"];
    cell.subTitleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"subtitle"];
    UIImage *imageAlreadyCahed = [self.imagesCache objectForKey:indexPath];
    if (imageAlreadyCahed) {
        cell.photoImageView.image = imageAlreadyCahed;
    } else {
        [self.images[indexPath.row] downloadImageFromString:[self.dataArray[indexPath.row] objectForKey:@"image_name"] forIndexPath:indexPath];
    }
    return cell;
}

@end
