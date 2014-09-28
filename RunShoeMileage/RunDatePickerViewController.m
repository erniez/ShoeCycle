//
//  RunDatePickerViewController.m
//  ShoeCycle
//
//  Created by Bob Bitchin on 9/23/14.
//
//

#import "RunDatePickerViewController.h"


@interface RunDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation RunDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
