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

@property (strong, nonatomic) ContentDownloader *contentDownloader;
@property (strong, nonatomic) ImageDownloader *imageDownloader;
@property (strong, nonatomic) NSMutableArray *images;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) UIImageView *tempImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 140.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.contentDownloader = [[ContentDownloader alloc] init];
    self.contentDownloader.delegate = self;
    
//    self.imageDownloader = [[ImageDownloader alloc] init];
//    self.imageDownloader.delegate = self;
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

- (void)imageDownloader:(ImageDownloader *)imageDownloader didDownloadImage:(UIImage *)image withIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        cell.imageView.image = image;
//        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSLog(@"Set image for indexPath %@", indexPath);
    }
    else {
        NSLog(@"Cell with indexPath %@ is out of range", indexPath);
    }
}

#pragma mark - IBActions

- (IBAction)refresh:(UIButton *)sender {
    [self.contentDownloader downloadContent];
}

#pragma mark - <TableViewDataSourse>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    NSLog(@"INDEX PATH %@", indexPath);
    cell.titleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"title"];
    cell.subTitleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"subtitle"];
    [self.images[indexPath.row] downloadImageFromString:[self.dataArray[indexPath.row] objectForKey:@"image_name"] withIndexPath:indexPath];
    return cell;
}

@end
