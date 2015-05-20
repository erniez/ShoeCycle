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


@interface EditShoesCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end


@implementation EditShoesCell

- (void)awakeFromNib {
    self.selectedLabel.textColor = [UIColor orangeColor];
    self.selectedLabel.text = @"";
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
    if (self.selected) {
        self.backgroundColor = [UIColor shoeCycleGreen];
        self.selectedLabel.text = @"Selected";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    CGFloat animationTime = animated ? 0.25 : 0.0;
    [UIView animateWithDuration:animationTime animations:^{
        self.selectedLabel.text = selected ? @"Selected" : @"";
        self.backgroundColor = selected ? [UIColor shoeCycleGreen] : [UIColor whiteColor];
        [self layoutIfNeeded];
    } completion:nil];
    
}

- (void)prepareForReuse
{
    self.selectedLabel.text = @"";
    self.nameLabel.text = @"";
    self.distanceLabel.text = @"";
    self.backgroundColor = [UIColor whiteColor];
}

@end
