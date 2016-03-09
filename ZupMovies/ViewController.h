//
//  ViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Movie.h"

@interface ViewController : UIViewController<NSURLConnectionDataDelegate, UITableViewDataSource,
UITableViewDelegate, UISearchControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

