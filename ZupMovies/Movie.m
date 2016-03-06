//
//  Movie.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize title, actors, genre, imdbRaiting, year, plot, director;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.actors = nil;
        self.imdbRaiting = nil;
        self.year = nil;
        self.director = nil;
    }
    return self;
}

- (id) initWithTitle:(NSString*)_title
              actors:(NSString*)_actors
                year:(NSString*)_year
                year:(NSString*)_plot
                year:(NSString*)_genre
           imdbScore:(NSString*)_imdbRaiting
                year:(NSString*)_director
{
    self = [super init];
    if (self) {
        self.title = _title;
        self.actors = _actors;
        self.year = _year;
        self.plot = _plot;
        self.genre = _genre;
        self.imdbRaiting = _imdbRaiting;
        self.director = _director;
    }
    return self;
}

+ (Movie*) parseDictionary:(NSDictionary *) dict
{
    Movie *m = [Movie init];
    [m setTitle: dict[@"Title"]];
    [m setActors: dict[@"Actors"]];
    [m setYear: dict[@"Year"]];
    [m setPlot: dict[@"Plot"]];
    [m setGenre: dict[@"Genre"]];
    [m setImdbRaiting: dict[@"imdbRating"]];
    [m setDirector: dict[@"Director"]];
    
    return m;
}

@end
