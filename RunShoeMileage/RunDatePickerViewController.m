//
//  RunDatePickerViewController.m
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/23/14.
//
//

#import "RunDatePickerViewController.h"
#import "UIColor+ShoeCycleColors.h"

@interface RunDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIButton *todayButton;

@end

@implementation RunDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.infoLabel.textColor = [UIColor shoeCycleBlue];
    self.doneButton.tintColor = [UIColor shoeCycleOrange];
    self.todayButton.tintColor = [UIColor shoeCycleBlue];
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self.delegate dismissDatePicker:self ];
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

- (IBAction)todayButtonTapped:(id)sender
{
    [self.datePicker setDate:[NSDate date] animated:YES];
    [self.delegate runDatePickerValueDidChange:self.datePicker.date];
}

@end
