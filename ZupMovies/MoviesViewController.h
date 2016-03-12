//
//  MoviesViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/12/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"
#import "MovieDetailViewController.h"
#import "AppDelegate.h"

@interface MoviesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MovieDelegate>

@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;

@end
