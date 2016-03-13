//
//  MovieDetailViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Movie.h"
#import <UIKit/UIKit.h>

@protocol MovieDelegate

    -(void)updateMovies:(BOOL)update;

@end

@interface MovieDetailViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UINavigationItem *navigationItem;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblGenre;
@property (weak, nonatomic) IBOutlet UILabel *lblMovieTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDirector;
@property (weak, nonatomic) IBOutlet UILabel *lblYear;
@property (weak, nonatomic) IBOutlet UILabel *lblScore;
@property (weak, nonatomic) IBOutlet UITextView *textViewPlot;
@property (weak, nonatomic) IBOutlet UILabel *lblDirectorTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblGenreTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblOutOfTen;
@property (weak, nonatomic) IBOutlet UILabel *lblActorsTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblActors;

@property (weak, nonatomic) UIImage *image;
@property (retain, nonatomic) id delegate;
@property (nonatomic) BOOL hideSaveButton;
@property (strong, nonatomic) Movie *movie;

- (IBAction)save:(id)sender;
- (IBAction)cancel:(id)sender;

@end
