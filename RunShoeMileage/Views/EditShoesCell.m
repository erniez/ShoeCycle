//
//  EditShoesCell.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 5/20/15.
//
//

#import "EditShoesCell.h"
#import "UIColor+ShoeCycleColors.h"
#import "Shoe.h"
#import "UserDistanceSetting.h"
#import "History.h"


@interface EditShoesCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLeadingAlignmentConstraint;

@end


@implementation EditShoesCell

- (void)awakeFromNib {
    self.selectedLabel.textColor = [UIColor orangeColor];
    self.nameLabel.text = @"";
    self.distanceLabel.text = @"";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureForShoe:(Shoe *)shoe
{
    self.nameLabel.text = shoe.brand;
    // TODO: This if statement is needed only for backwards compatibility.  Remove after user base is 3.0 or above.
    if ([shoe.totalDistance floatValue] == 0 && [shoe.history count] > 0) {
        [self updateTotalDistanceForShoe:shoe];
    }
    float totalDistance = [shoe.totalDistance floatValue];
    NSString *distanceText = [UserDistanceSetting displayDistance:totalDistance];
    NSString *unitOfMeasure = [UserDistanceSetting getDistanceUnit] ? @"km" : @"miles";
    self.distanceLabel.text = [NSString stringWithFormat:@"Distance: %@ %@",distanceText, unitOfMeasure];
    [self layoutIfNeeded];
    if (self.selected) {
        self.backgroundColor = [UIColor shoeCycleGreen];
        self.nameLabel.alpha = 1.0;
        self.distanceLeadingAlignmentConstraint.constant = 73;
        [self layoutIfNeeded];
    }
    else {
        self.selectedLabel.alpha = 0.0;
        self.distanceLeadingAlignmentConstraint.constant = 0;
        [self layoutIfNeeded];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    UIColor *selectedColor = selected ? [UIColor shoeCycleGreen] : [UIColor whiteColor];
    [UIView animateWithDuration:0.25 animations:^{
        self.distanceLeadingAlignmentConstraint.constant = selected ? 73 : 0;
        self.backgroundColor = selectedColor;
        self.selectedLabel.alpha = selected ? 1.0 : 0.0;
        [self layoutIfNeeded];
    } completion:nil];
}

- (void)prepareForReuse
{
    self.nameLabel.text = @"";
    self.distanceLabel.text = @"";
    self.backgroundColor = [UIColor shoeCycleGreen];
    self.nameLabel.alpha = 1.0;
    self.distanceLeadingAlignmentConstraint.constant = 73;
}

- (CGFloat)unselectedConstant
{
    return self.distanceLabel.frame.origin.x - self.nameLabel.frame.origin.x;

}


// TODO: Only need this as a backwards compatibility function for displaying the table view for the first time
// on upgrade.  This can be deleted once the user base is all 3.0 or above.
- (void)updateTotalDistanceForShoe:(Shoe *)shoe
{
    float totalDistance = 0;
    for (History *history in shoe.history) {
        totalDistance += [history.runDistance floatValue];
    }
    shoe.totalDistance = [NSNumber numberWithFloat:totalDistance];
}

@end
