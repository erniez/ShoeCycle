//
//  FileHelpers.m
//  Homepwner
//
//  Created by Ernie on 11/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileHelpers.h"

// To use this function, you pass it a file name, and it will construct
// the full path for that file in the Documents directory.
NSString *pathInDocumentDirectory(NSString *filename)
{
    // Get list of document directories in sandbox
    NSArray *documentDirectories =
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                NSUserDomainMask, YES);
    
    // Get the one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    // Append passed in the file name to that directory, return it
    return [documentDirectory stringByAppendingPathComponent:filename];
}