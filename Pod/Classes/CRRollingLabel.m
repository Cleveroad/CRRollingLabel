//
//  CRRollingLabel.m
//  CRRollingLabel-iOS
//
//  Created by Prokopiev on 2/18/16.
//  Copyright © 2016 Cleveroad inc. All rights reserved.
//

#import "CRRollingLabel.h"
#import <CoreText/CoreText.h>
#import "CATextLayer+RollingLabelLayerText.h"

static NSString* const kCATextLayerTextCharacterPreset = @" .,:-+()0123456789";

@interface CRRollingLabel () <NSLayoutManagerDelegate>
@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSTextContainer *textContainer;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSMutableArray <CATextLayer *> *charactersLayers;
@property (nonatomic, strong) CALayer *basicLayer;
@property (nonatomic, assign) BOOL animated;
@property (nonatomic, strong) NSMutableAttributedString *internalAttributedText;
@property (nonatomic, strong) UIFont *providedFont;
@property (nonatomic, strong) UIColor *providedTextColor;
@property (nonatomic, strong) NSAttributedString *previousText;
@end

@implementation CRRollingLabel

@synthesize providedFont = _providedFont;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}

#pragma mark - Configuration

- (void)configure {
    self.charactersLayers = [NSMutableArray array];
    self.basicLayer = [CALayer layer];
    self.basicLayer.masksToBounds = YES;
    self.clipsToBounds = NO;
    self.providedTextColor = self.textColor;
    self.providedFont = self.font;
    [self configureLayoutManager];
}

- (void)configureLayoutManager {
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:@""]];
    self.layoutManager = [[NSLayoutManager alloc] init];
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.basicLayer.frame.size];
    self.textContainer.lineFragmentPadding = 0.f;
    [self.textStorage addLayoutManager:self.layoutManager];
    [self.layoutManager addTextContainer:self.textContainer];
    self.layoutManager.delegate = self;
    self.textContainer.maximumNumberOfLines = self.numberOfLines;
    self.textContainer.lineBreakMode = self.lineBreakMode;
    
    [self configureBasicLayer];
    
    [self setAttributedText:self.attributedText];
}

- (void)configureBasicLayer {
    CGFloat fontHeights = [self.providedFont pointSize];
    [CATransaction begin];
    [CATransaction setDisableActions:!self.animated];
    self.basicLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds) / 2.f - fontHeights / 2.f, self.bounds.size.width, fontHeights);
    [CATransaction commit];
    self.textContainer.size = self.basicLayer.frame.size;
    if (![self.layer.sublayers containsObject:self.basicLayer]) {
        [self.layer addSublayer:self.basicLayer];
    }
}

#pragma mark - Actions

- (void)setValue:(NSNumber *)value animated:(BOOL)animated {
    NSString *string = [value stringValue];
    [self setText:string animated:animated];
}

- (void)setText:(NSString *)text animated:(BOOL)animated {
    NSRange wordRange = NSMakeRange(0, text.length);
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.providedTextColor.CGColor range:wordRange];
    [attributedText addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:wordRange];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:self.textAlignment];
    [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wordRange];
    [self setAttributedText:attributedText animated:animated];
}

- (void)setAttributedText:(NSAttributedString *)attributedText animated:(BOOL)animated {
    self.previousText = self.attributedText;
    self.internalAttributedText = [attributedText mutableCopy];
    self.animated = animated;
    
    NSMutableAttributedString *clearColorText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
    [clearColorText addAttribute:NSForegroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, clearColorText.length)];
    [clearColorText addAttribute:(NSString *)kCTFontAttributeName value:self.font range:NSMakeRange(0, clearColorText.length)];
    
    [super setAttributedText:clearColorText];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (attributedText) {
        NSCharacterSet *availableCharacters = [NSCharacterSet characterSetWithCharactersInString:kCATextLayerTextCharacterPreset];
        NSString *text = [[attributedText.string componentsSeparatedByCharactersInSet:[availableCharacters invertedSet]] componentsJoinedByString:@""];
        __block NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        [attributedText enumerateAttributesInRange:NSMakeRange(0, text.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            attributes = attrs.mutableCopy;
        }];
        
        attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        
        NSMutableAttributedString *testStr = [[NSMutableAttributedString alloc] initWithAttributedString:attributedText];
        
        if ([self isAvailableToReduceFontSize] && self.intrinsicContentSize.width > self.bounds.size.width) {
            [self reduceFontSize];
        }
        
        if (attributedText.length < self.previousText.length && [self isAvailableToIncreaseFontSize]) {
            [self increaseFontSize];
        }
        
        if (!self.providedFont) {
            self.providedFont = attributes[NSFontAttributeName];
        } else {
            [testStr addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:NSMakeRange(0, attributedText.length)];
        }
        
        [self.textStorage setAttributedString:testStr];
    }
    
    [self configureBasicLayer];
    [self configureLayers];
}

#pragma mark - Private get & set

- (void)setValue:(NSNumber *)value {
    [self setValue:value animated:YES];
}

- (NSNumber *)value {
    NSCharacterSet *availableCharacters = [NSCharacterSet characterSetWithCharactersInString:@"-0123456789"];
    NSString *text = [[self.text componentsSeparatedByCharactersInSet:[availableCharacters invertedSet]] componentsJoinedByString:@""];
    return @(text.longLongValue);
}

- (NSMutableAttributedString *)internalAttributedText {
    if (!_internalAttributedText) {
        NSRange wordRange = NSMakeRange(0, self.textStorage.string.length);
        _internalAttributedText = [[NSMutableAttributedString alloc] initWithString:self.textStorage.string];
        [_internalAttributedText addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.providedTextColor.CGColor range:wordRange];
        [_internalAttributedText addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:wordRange];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setAlignment:self.textAlignment];
        [_internalAttributedText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wordRange];
    }
    
    return _internalAttributedText;
}

- (UIColor *)providedTextColor {
    if (!_providedTextColor) {
        _providedTextColor = [super textColor];
    }
    return _providedTextColor;
}

- (UIFont *)providedFont {
    if (!_providedFont) {
        _providedFont = [super font];
    }
    return _providedFont;
}

- (void)setProvidedFont:(UIFont *)providedFont {
    _providedFont = providedFont;
    
    void (^tableEnumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CATextLayer *textlayer = (CATextLayer *)obj;
        NSMutableAttributedString *updatedAttributedString = [textlayer.string mutableCopy];
        [updatedAttributedString addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:NSMakeRange(0, updatedAttributedString.length)];
        textlayer.string = [[NSAttributedString alloc] initWithAttributedString:updatedAttributedString];
        CGRect frame = textlayer.frame;
        frame.origin.y = idx * providedFont.pointSize;
        textlayer.frame = frame;
    };
    
    void (^enumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:tableEnumerationBlock];
    };
    
    [self.basicLayer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:enumerationBlock];
        CATextLayer *textlayer = (CATextLayer *)obj;
        [self scrollLayer:textlayer toValue:textlayer.cr_text forceScroll:YES];
    }];
}

#pragma mark - Overrides

- (void)layoutSubviews {
    [super layoutSubviews];
    [self configureBasicLayer];
}

- (void)setBounds:(CGRect)bounds {
    self.textContainer.size = bounds.size;
    super.bounds = bounds;
}

- (void)setFrame:(CGRect)frame {
    self.textContainer.size = frame.size;
    super.frame = frame;
}

- (void)setLineBreakMode:(NSLineBreakMode)lineBreakMode {
    self.textContainer.lineBreakMode = lineBreakMode;
}

- (NSInteger)numberOfLines {
    return 1;
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    super.numberOfLines = 1;
}

- (void)setFont:(UIFont *)font {
    self.providedFont = font;
    
    void (^tableEnumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CATextLayer *textlayer = (CATextLayer *)obj;
        NSMutableAttributedString *updatedAttributedString = [textlayer.string mutableCopy];
        [updatedAttributedString addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:NSMakeRange(0, updatedAttributedString.length)];
        textlayer.string = [[NSAttributedString alloc] initWithAttributedString:updatedAttributedString];
    };
    
    void (^enumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:tableEnumerationBlock];
    };
    
    [self.basicLayer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:enumerationBlock];
    }];
    
    super.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    self.providedTextColor = textColor;
    
    void (^tableEnumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CATextLayer *textlayer = (CATextLayer *)obj;
        NSMutableAttributedString *updatedAttributedString = [textlayer.string mutableCopy];
        [updatedAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)self.providedTextColor.CGColor range:NSMakeRange(0, updatedAttributedString.length)];
        textlayer.string = [[NSAttributedString alloc] initWithAttributedString:updatedAttributedString];
        [textlayer setNeedsDisplay];
    };
    
    void (^enumerationBlock)(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) = ^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:tableEnumerationBlock];
    };
    
    [self.basicLayer.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.sublayers enumerateObjectsUsingBlock:enumerationBlock];
    }];
    
    super.textColor = [UIColor clearColor];
}

- (UIColor *)textColor {
    return self.providedTextColor;
}

- (void)setText:(NSString *)text {
    [self setText:text animated:YES];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [self setAttributedText:attributedText animated:YES];
}

#pragma mark - NSLayoutManagerDelegate

- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag {
    if (!self.animated) {
        [CATransaction begin];
        [CATransaction setDisableActions:!self.animated];
    }
    
    [self configureTextLayersFrames];
    
    if (!self.animated) {
        [CATransaction commit];
    }
}

#pragma mark - Layout configuration

- (void)configureLayers {
    if (self.textStorage.string.length < self.charactersLayers.count) {
        NSMutableArray <CATextLayer *> *layersToDelete = [NSMutableArray array];
        [CATransaction begin];
        [CATransaction setDisableActions:!self.animated];
        [CATransaction setCompletionBlock:^{
            [layersToDelete makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        }];
        
        for (NSInteger layerIndex = self.textStorage.string.length; layerIndex < self.charactersLayers.count; layerIndex++) {
            [self scrollLayer:self.charactersLayers[layerIndex] toValue:@" " forceScroll:NO];
            [layersToDelete addObject:self.charactersLayers[layerIndex]];
        }
        [self.charactersLayers removeObjectsInArray:layersToDelete];
        [CATransaction commit];
    }
    
    for (NSInteger characterIndex = 0; characterIndex < self.textStorage.string.length; characterIndex++) {
        NSString *character = [self.textStorage.string substringWithRange:NSMakeRange(characterIndex, 1)];
        if (characterIndex < self.charactersLayers.count) {
            CATextLayer *textLayer = self.charactersLayers[characterIndex];
            [CATransaction begin];
            [CATransaction setDisableActions:!self.animated];
            [self scrollLayer:textLayer toValue:character forceScroll:NO];
            [CATransaction commit];
        } else {
            [self createNewTextLayerAtIndex:characterIndex];
        }
    }
}

- (void)configureTextLayersFrames {
    if (self.charactersLayers.count) {
        NSRange wordRange = NSMakeRange(0, self.charactersLayers.count);
        for (NSUInteger glyphIndex = wordRange.location; glyphIndex < (wordRange.length + wordRange.location); glyphIndex ++) {
            NSInteger textLayerIndex = glyphIndex;
            NSRange glyphRange = NSMakeRange(glyphIndex, 1);
            BOOL shouldConfigure = glyphIndex < self.textStorage.string.length;
            
            if (!shouldConfigure) {
                continue;
            }
            
            NSTextContainer *textContainer = [self.layoutManager textContainerForGlyphAtIndex:glyphIndex effectiveRange:nil];
            CGRect glyphRect = [self.layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
            
            NSRange glyphKerningRange = [self.layoutManager rangeOfNominallySpacedGlyphsContainingIndex:glyphIndex];
            
            if (glyphIndex == glyphKerningRange.location && textLayerIndex != 0) {
                CATextLayer *previousLayer = self.charactersLayers[textLayerIndex-1];
                CGRect frame = previousLayer.frame;
                frame.size.width = CGRectGetMaxX(glyphRect)-CGRectGetMinX(frame);
                previousLayer.frame = frame;
            }
            
            CATextLayer *textLayer = self.charactersLayers[textLayerIndex];
            
            CGRect sublayerRect = textLayer.sublayers.firstObject.frame;
            sublayerRect.size = glyphRect.size;
            textLayer.sublayers.firstObject.frame = sublayerRect;
            
            [textLayer.sublayers.firstObject.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CGRect sublayerRect = obj.frame;
                sublayerRect.size = glyphRect.size;
                obj.frame = sublayerRect;
            }];
            
            textLayer.frame = glyphRect;
            
            CGPoint position = textLayer.position;
            position.y = CGRectGetHeight(self.basicLayer.frame) / 2.f;
            textLayer.position = position;
        }
    }
}

#pragma mark - Functions

- (void)createNewTextLayerAtIndex:(NSInteger)index {
    NSString *character = [self.textStorage.string substringWithRange:NSMakeRange(index, 1)];
    
    CGRect textLayerFrame = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(index, 1) inTextContainer:self.textContainer];
    
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = textLayerFrame;
    __block CGRect sublayerFrame = CGRectZero;
    sublayerFrame.size = textLayer.frame.size;
    __block NSDictionary *attributes = [NSDictionary dictionary];
    
    [self.internalAttributedText enumerateAttributesInRange:NSMakeRange(0, self.textStorage.string.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        attributes = attrs;
    }];
    
    NSArray *charactersPreset = @[@"+", @"(", @")", @".", @",", @" ", @":", @" ", @"-", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    CALayer *sublayer = [CALayer layer];
    sublayer.frame = CGRectMake(0.f, 0.f, textLayerFrame.size.width, textLayerFrame.size.height * charactersPreset.count);
    [charactersPreset enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CATextLayer *textSublayer = [CATextLayer layer];
        textSublayer.masksToBounds = NO;
        sublayerFrame.origin.y = CGRectGetHeight(sublayerFrame) * idx;
        textSublayer.frame = sublayerFrame;
        textSublayer.string = [[NSAttributedString alloc] initWithString:obj attributes:attributes];
        textSublayer.cr_text = [textSublayer.string string];
        textSublayer.contentsScale = [UIScreen mainScreen].scale;
        if (self.shadowColor) {
            textSublayer.shadowColor = self.shadowColor.CGColor;
            textSublayer.shadowOffset = self.shadowOffset;
            textSublayer.shadowOpacity = 1.f;
            textSublayer.shadowRadius = 0.f;
        }
        [sublayer addSublayer:textSublayer];
    }];
    [textLayer addSublayer:sublayer];
    [self.charactersLayers addObject:textLayer];
    [self.basicLayer addSublayer:textLayer];
    
    CGPoint position = textLayer.position;
    position.y = CGRectGetHeight(self.basicLayer.frame) / 2.f;
    textLayer.position = position;
    
    [CATransaction flush];
    
    [CATransaction begin];
    [CATransaction setDisableActions:!self.animated];
    [self scrollLayer:textLayer toValue:character forceScroll:NO];
    [CATransaction commit];
}

- (void)scrollLayer:(CATextLayer *)textLayer toValue:(NSString *)value forceScroll:(BOOL)forceScroll {
    if ([textLayer.cr_text isEqualToString:value] && !forceScroll) {
        return;
    }
    CATextLayer *layerToScroll = (CATextLayer*)textLayer.sublayers.firstObject;
    __block CGRect layerToScrollFrame = layerToScroll.frame;
    [layerToScroll.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CATextLayer *sublayer = (CATextLayer *)obj;
        if ([sublayer.cr_text isEqualToString:value]) {
            textLayer.cr_text = value;
            layerToScrollFrame.origin.y = -sublayer.frame.origin.y;
            layerToScroll.frame = layerToScrollFrame;
            *stop = YES;
        }
    }];
}

#pragma mark - Autoshrink

- (BOOL)isAvailableToReduceFontSize {
    return self.providedFont.pointSize / self.font.pointSize > self.minimumScaleFactor && self.minimumScaleFactor;
}

- (BOOL)isAvailableToIncreaseFontSize {
    return self.providedFont.pointSize / self.font.pointSize < 1.f && self.minimumScaleFactor;
}

- (void)reduceFontSize {
    if (self.intrinsicContentSize.width <= self.bounds.size.width) {
        return;
    }
    UIFont *font = self.providedFont;
    CGFloat calculatedWidth = [self.text sizeWithAttributes:@{NSFontAttributeName:[font fontWithSize:font.pointSize]}].width;
    
    while (calculatedWidth > self.frame.size.width && font.pointSize <= self.font.pointSize) {
        font = [font fontWithSize:font.pointSize - 1.f];
        calculatedWidth = [self.text sizeWithAttributes:@{NSFontAttributeName:font}].width;
    }
    
    self.providedFont = [UIFont fontWithName:self.providedFont.fontName size:font.pointSize];
    [self.internalAttributedText addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:NSMakeRange(0, self.internalAttributedText.length)];
}

- (void)increaseFontSize {
    UIFont *font = self.providedFont;
    
    CGFloat updatedPointSize = font.pointSize + 1.f;
    CGFloat calculatedWidth = [self.text sizeWithAttributes:@{NSFontAttributeName:[font fontWithSize:updatedPointSize]}].width;
    while (calculatedWidth < self.frame.size.width && font.pointSize <= self.font.pointSize) {
        font = [font fontWithSize:updatedPointSize];
        updatedPointSize += 1.f;
        calculatedWidth = [self.text sizeWithAttributes:@{NSFontAttributeName:[font fontWithSize:updatedPointSize]}].width;
    }
    
    self.providedFont = [self.providedFont fontWithSize:font.pointSize > self.font.pointSize ? self.font.pointSize : font.pointSize];
    [self.internalAttributedText addAttribute:(NSString *)kCTFontAttributeName value:self.providedFont range:NSMakeRange(0, self.internalAttributedText.length)];
}

@end
