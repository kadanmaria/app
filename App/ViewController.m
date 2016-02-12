//
//  ViewController.m
//  App
//
//  Created by Admin on 07.02.16.
//  Copyright © 2016 OrgName. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"
#import "Data.h"


@interface ViewController () <UITableViewDelegate, UITableViewDataSource, JSONDelegate> {
    Data *currentData;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentData = [[Data alloc] init];
    currentData.JSONDelegate = self;
//    [currentData getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - JSONDelegate

- (void)recievedArrayFromJSON:(NSArray *)array {
    self.dataArray = array;
    [self.tableView reloadData];
}

#pragma mark - IBActions

- (IBAction)refresh:(UIButton *)sender {
    self.tableView.estimatedRowHeight = 140.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [currentData getData];
}

#pragma mark - TableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(Cell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.cellIndex = (NSInteger *)indexPath.row;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.dataArray[indexPath.row] objectForKey:@"image_name"]]];
        if(imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            if(image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(cell.cellIndex == (NSInteger *)indexPath.row) {
                        cell.photoImageView.image = image;
                    }
                });
            }
        }
    });
}

#pragma mark - TableViewDataSourse

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];

    cell.titleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"title"];
    cell.subTitleLabel.text = [self.dataArray[indexPath.row] objectForKey:@"subtitle"];
    return cell;
}

@end
