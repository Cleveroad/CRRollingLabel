//
//  CATextLayer+RollingLabelLayerText.m
//  CRRollingLabel-iOS
//
//  Created by Prokopiev on 2/24/16.
//  Copyright © 2016 Cleveroad inc. All rights reserved.
//

#import "CATextLayer+RollingLabelLayerText.h"
#import <objc/runtime.h>

static const char kCATextLayerText;

@implementation CATextLayer (RollingLabelLayerText)

- (void)setCr_text:(NSString *)cr_text {
    objc_setAssociatedObject(self, &kCATextLayerText, cr_text, OBJC_ASSOCIATION_RETAIN);
}

- (NSString *)cr_text {
    return objc_getAssociatedObject(self, &kCATextLayerText);
}

@end
