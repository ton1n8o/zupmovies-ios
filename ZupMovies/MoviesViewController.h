//
//  MoviesViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/12/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Movie.h"

@interface MoviesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *moviesTableView;

@end
