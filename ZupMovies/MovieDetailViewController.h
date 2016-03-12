//
//  MovieDetailViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@protocol MovieDelegate

    -(void)updateMovies:(BOOL)update;

@end

@interface MovieDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet UILabel *lblGenre;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;

@property (weak, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property (weak, nonatomic) NSString *movieTitle;

@property (weak, nonatomic) NSString *imdbId;
@property (retain, nonatomic) id delegate;
@property (nonatomic) BOOL hideSaveButton;

- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
