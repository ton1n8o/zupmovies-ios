//
//  MovieDetailViewController.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/9/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "ViewController.h"

@interface MovieDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;

- (IBAction)save:(id)sender;

- (IBAction)cancel:(id)sender;

@end
