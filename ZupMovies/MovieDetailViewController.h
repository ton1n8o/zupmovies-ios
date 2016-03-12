//
//  MovieDetailViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface MovieDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lblGenre;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;

@property (weak, nonatomic) NSString *imdbId;
@property (weak, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property (weak, nonatomic) NSString *movieTitle;

- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
