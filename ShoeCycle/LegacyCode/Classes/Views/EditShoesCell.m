//
//  EditShoesCell.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/20/15.
//
//

#import "EditShoesCell.h"
#import "UIColor+ShoeCycleColors.h"
#import "Shoe.h"
#import "UserDistanceSetting.h"
#import "History.h"
#import "ShoeStore_Legacy.h"


@interface EditShoesCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLeadingAlignmentConstraint;

@end


@implementation EditShoesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectedLabel.textColor = [UIColor orangeColor];
    self.nameLabel.text = @"";
    self.distanceLabel.text = @"";
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)configureForShoe:(Shoe *)shoe
{
    self.nameLabel.text = shoe.brand;
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
    [super prepareForReuse];
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

@end
