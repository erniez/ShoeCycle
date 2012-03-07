//
//  Shoe.m
//  RunShoeMileage
//
//  Created by Ernie on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Shoe.h"
#import "History.h"


@implementation Shoe

@dynamic brand;
@dynamic expirationDate;
@dynamic imageKey;
@dynamic maxDistance;
@dynamic orderingValue;
@dynamic startDistance;
@dynamic thumbnail;
@dynamic thumbnailData;
@dynamic totalDistance;
@dynamic startDate;
@dynamic history;


- (void)awakeFromFetch
{
    [super awakeFromFetch];
    
    UIImage *tn = [UIImage imageWithData:[self thumbnailData]];
    [self setPrimitiveValue:tn forKey:@"thumbnail"];
}


- (void)setThumbnailDataFromImage:(UIImage *)image width:(int)w height:(int)h
{
    CGSize origImageSize = [image size];
    
    CGRect newRect;
    newRect.origin = CGPointZero;
    newRect.size = [[self class] thumbnailSizeFromWidth:w height:h];
    
    // How do we scale the image?
    float ratio = MAX(newRect.size.width/origImageSize.width,
                      newRect.size.height/origImageSize.height);
    
    // Create a bitmap image context
    UIGraphicsBeginImageContext(newRect.size);
    
    // Round the corners
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:newRect
//                                                    cornerRadius:5.0];
//    [path addClip];
    
    // Into what rectangle shall I composite the image?
    CGRect projectRect;
    projectRect.size.width = ratio * origImageSize.width;
    projectRect.size.height = ratio * origImageSize.height;
    projectRect.origin.x = (newRect.size.width - projectRect.size.width)/2.0;
    projectRect.origin.y = (newRect.size.height - projectRect.size.height) / 2.0;
    
    // Draw an image on it
    [image drawInRect:projectRect];
    
    // Get the image from the image context, retain it as our thumbnail
    UIImage *small = UIGraphicsGetImageFromCurrentImageContext();
    [self setThumbnail:small];
    
    // Get the image as a PNG data
    NSData *data = UIImagePNGRepresentation(small);
    [self setThumbnailData:data];
    
    // Cleanup image context resources, we're done
    UIGraphicsEndImageContext();
}


+ (CGSize)thumbnailSizeFromWidth:(int)w height:(int)h
{
    return CGSizeMake(w, h);
}


@end
