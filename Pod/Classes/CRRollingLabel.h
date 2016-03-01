//
//  CRRollingLabel.h
//  CRRollingLabel-iOS
//
//  Created by Prokopiev on 2/18/16.
//  Copyright © 2016 Cleveroad inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRRollingLabel : UILabel
/**
  * The numerical value displayed by the label. Animated by default.
**/
@property (nonatomic, strong) NSNumber *value;

/**
 * The text displayed by the label, consisting of the numerical values. Non-numeric values are ignored. Animated by default.
**/
- (void)setText:(NSString *)text animated:(BOOL)animated;

/**
 * The styled text displayed by the label, consisting of the numerical values. Non-numeric values are ignored. Animated by default.
**/
- (void)setAttributedText:(NSAttributedString *)attributedText animated:(BOOL)animated;

/**
 * The numerical value displayed by the label. Animated by default.
**/
- (void)setValue:(NSNumber *)value animated:(BOOL)animated;
@end
