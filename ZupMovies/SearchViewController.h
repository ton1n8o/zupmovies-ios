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
#import "MovieDetailViewController.h"
#import "Reachability.h"

@interface SearchViewController : UIViewController<NSURLConnectionDataDelegate, UITableViewDataSource,
UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic, weak) UIViewController *moviesViewController;

@end

