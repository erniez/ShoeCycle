//
//  ImageStore.m
//  RunShoeMileage
//
//  Created by Ernie on 1/4/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ImageStore.h"
#import "FileHelpers.h"

static ImageStore *defaultImageStore = nil;

@implementation ImageStore


+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultImageStore];
}


+ (ImageStore *)defaultImageStore
{
    if (!defaultImageStore) {
        // Create the singleton
        defaultImageStore = [[super allocWithZone:NULL] init];
    }
    return defaultImageStore;
}


- (id)init
{
    if (defaultImageStore) {
        return defaultImageStore;
    }
    
    self = [super init];
    if (self) {
        dictionary = [[NSMutableDictionary alloc] init];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(clearCache)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    
    return self;
}


- (void) clearCache:(NSNotification *)note
{
    NSLog(@"flushing %d images out of the cache", [dictionary count]);
    [dictionary removeAllObjects];
}

- (void)release
{
    // no op
}


- (id)retain
{
    return self;
}


- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}


- (void)setImage:(UIImage *)i withWidth:(int)w withHeight:(int)h forKey:(NSString *)s
{
    CGSize origImageSize = [i size];
    
    CGRect newRect;
    newRect.origin = CGPointZero;
    newRect.size = CGSizeMake(w, h);    
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
    [i drawInRect:projectRect];
    
    // Get the image from the image context, retain it as our thumbnail
    UIImage *reduced = UIGraphicsGetImageFromCurrentImageContext();
//    [self setThumbnail:small];
    
    // Get the image as a PNG data
//    NSData *data = UIImagePNGRepresentation(reduced);
//    [self setThumbnailData:data];
    
    // Cleanup image context resources, we're done
//    UIGraphicsEndImageContext();
    
    // Put it in the dictionary
    [dictionary setObject:reduced forKey:s];
    
    // Create full path for image
    NSString *imagePath = pathInDocumentDirectory(s);
    
    // Turn image into JPEG data
    NSData *d = UIImageJPEGRepresentation(reduced, 0.5);
    
    // Write it to full path
    [d writeToFile:imagePath atomically:YES];
}


- (UIImage *)imageForKey:(NSString *)s 
{
//  return [dictionary objectForKey:s];// -> removed because of updated code to make use of file system
    
    // If possible, get it from the dictionary
    UIImage *result = [dictionary objectForKey:s];
    
    if (!result) {
        // Create UIImage object from file
        result = [UIImage imageWithContentsOfFile:pathInDocumentDirectory(s)];
        
        // If we found an image on the file system, place it into the cache
        if (result){
            [dictionary setObject:result forKey:s];
        } else {
            NSLog(@"Error: unable to find %@", pathInDocumentDirectory(s));
        }
    }
    return result;
}


- (void)deleteImageForKey:(NSString *)s 
{
    if (!s)
        return;
    [dictionary removeObjectForKey:s];
    NSString *path = pathInDocumentDirectory(s);
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

@end
