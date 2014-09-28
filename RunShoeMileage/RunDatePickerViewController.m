//
//  RunDatePickerViewController.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 9/23/14.
//
//

#import "RunDatePickerViewController.h"
#import "UIColor+ShoeCycleColors.h"

@interface RunDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

@end

@implementation RunDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.infoLabel.textColor = [UIColor shoeCycleOrange];
    self.doneButton.tintColor = [UIColor shoeCycleOrange];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self.delegate dismissDatePicker:self];
}

- (IBAction)datePickerValueDidChange:(UIDatePicker *)datePicker
{
    NSDate *pickerDate = datePicker.date;
    [self.delegate runDatePickerValueDidChange:pickerDate];
}

- (void)setDate:(NSDate *)newDate
{
    self.datePicker.date = newDate;
}

@end
