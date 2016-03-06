//
//  Movie.h
//  ZupMovies
//
//  Created by Antonio Carlos Silva on 3/6/16.
//  Copyright © 2016 Antonio Carlos Silva. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movie : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* actors;
@property (nonatomic, copy) NSString* year;
@property (nonatomic, copy) NSString* plot;
@property (nonatomic, copy) NSString* genre;
@property (nonatomic, copy) NSString* imdbRaiting;

- (id) init;

- (id) initWithTitle:(NSString*)_title actors:(NSString*)_actors imdbScore:(NSString*)_imdbRaiting year:(NSString*)_year;

+ (Movie*) parseDictionary:(NSDictionary *) dict;

@end
