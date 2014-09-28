//
//  RunDatePickerViewController.h
//  ShoeCycle
//
//  Created by Bob Bitchin on 9/23/14.
//
//

#import <UIKit/UIKit.h>

@protocol RunDatePickerViewDelegate;

@interface RunDatePickerViewController : UIViewController

@property (nonatomic, weak) id<RunDatePickerViewDelegate>delegate;

- (void)setDate:(NSDate *)newDate;

@end

@protocol RunDatePickerViewDelegate <NSObject>

- (void)dismissDatePicker:(RunDatePickerViewController *)datePicker;
- (void)runDatePickerValueDidChange:(NSDate *)newDate;

@end
