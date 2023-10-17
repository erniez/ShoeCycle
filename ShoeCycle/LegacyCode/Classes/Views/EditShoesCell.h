//
//  EditShoesCell.h
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/20/15.
//
//

#import <UIKit/UIKit.h>
@class Shoe;

@interface EditShoesCell : UITableViewCell

- (void)configureForShoe:(Shoe *)shoe;

@end
