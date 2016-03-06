//
//  Movie.m
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import "Movie.h"

@implementation Movie

@synthesize title, actors, genre,
imdbRaiting, year, plot, director, poster;

- (id) init
{
    self = [super init];
    if (self) {
        self.title = nil;
        self.actors = nil;
        self.year = nil;
        self.plot = nil;
        self.genre = nil;
        self.imdbRaiting = nil;
        self.director = nil;
        self.poster = nil;
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
              poster:(NSString*)_poster
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
        self.poster = _poster;
    }
    return self;
}

+ (Movie*) parseDictionary:(NSDictionary *) dict
{
    Movie *m = [[Movie alloc] init];
    
    [m setTitle: dict[@"Title"]];
    [m setActors: dict[@"Actors"]];
    [m setYear: dict[@"Year"]];
    [m setPlot: dict[@"Plot"]];
    [m setGenre: dict[@"Genre"]];
    [m setImdbRaiting: dict[@"imdbRating"]];
    [m setDirector: dict[@"Director"]];
    [m setPoster: dict[@"Poster"]];
    
    return m;
}

@end
