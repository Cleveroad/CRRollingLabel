//
//  CRViewController.m
//  CRRollingLabel
//
//  Created by Prokopiev Nick on 02/22/2016.
//  Copyright (c) 2016 Prokopiev Nick. All rights reserved.
//

#import "CRViewController.h"
#import <CRRollingLabel/CRRollingLabel.h>

@interface CRViewController ()
@property (weak, nonatomic) IBOutlet CRRollingLabel *label;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation CRViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionSet:(UIButton *)sender {
    self.label.text = self.textField.text;
}

- (IBAction)actionIncrease:(UIButton *)sender {
    self.label.value = @(self.label.value.longLongValue + 1);
}

- (IBAction)actionDecrease:(UIButton *)sender {
    self.label.value = @(self.label.value.longLongValue - 1);
}

- (IBAction)actionRandom:(UIButton *)sender {
    NSNumber *value = @(arc4random() % 99999);
    [self.label setValue:value];
}

@end
