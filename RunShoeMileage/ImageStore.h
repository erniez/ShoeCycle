//
//  ImageStore.h
//  RunShoeMileage
//
//  Created by Ernie on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageStore : NSObject
{
    NSMutableDictionary *dictionary;
}

+ (ImageStore *)defaultImageStore;


- (void)setImage:(UIImage *)i withWidth:(int)w withHeight:(int)h forKey:(NSString *)s;
- (UIImage *)imageForKey:(NSString *)s;
- (void)deleteImageForKey:(NSString *)s;

@end
