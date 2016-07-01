//
//  TGGeneralInputTextRowView.m
//  Telegram
//
//  Created by keepcoder on 05/11/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGGeneralInputTextRowView.h"
#import "TGGeneralInputRowItem.h"
#import "TGPopoverHint.h"

@interface TGGeneralInputTextRowView () <NSTextFieldDelegate,TMTextFieldDelegate>
@property (nonatomic,strong) TMTextField *textField;
@property (nonatomic,strong) TMView *separator;

@end

@implementation TGGeneralInputTextRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

-(instancetype)initWithFrame:(NSRect)frameRect {
    if(self = [super initWithFrame:frameRect]) {
        _textField = [[TMTextField alloc] init];
        [_textField setFont:TGSystemFont(13)];
        [_textField setEditable:YES];
        [_textField setBordered:NO];
        [_textField setDrawsBackground:NO];
        [_textField setFocusRingType:NSFocusRingTypeNone];
        
        
        [_textField setFrameSize:NSMakeSize(NSWidth(self.frame) - 60, 20)];
        
        _textField.fieldDelegate = self;
        _textField.delegate = self;
        
        [self addSubview:_textField];
        
        _separator = [[TMView alloc] initWithFrame:NSZeroRect];
        
        _separator.backgroundColor = DIALOG_BORDER_COLOR;
        
        [self addSubview:_separator];
    }
    
    return self;
}



-(void)textFieldDidChange:(id)field {
   
}

-(BOOL)becomeFirstResponder {
    return [_textField becomeFirstResponder];
}

-(void)textFieldDidBecomeFirstResponder:(id)field {
    if( self.item.callback != nil) {
        self.item.callback(self.item);
    }
}



-(void)controlTextDidChange:(NSNotification *)obj {
    
    [_textField setStringValue:[_textField.stringValue substringToIndex:MIN(self.item.limit > 0 ? self.item.limit : 200,_textField.stringValue.length)]];
    
    self.item.result = _textField.attributedStringValue;
    

    
    NSSize size = [_textField.attributedStringValue sizeForTextFieldForWidth:NSWidth(self.frame) - (self.item.xOffset * 2)];
    
    size.height = MAX(17,size.height);
    
    self.item.height = size.height + 5;
    
    NSSize oldSize = _textField.frame.size;
    
    if(oldSize.height != size.height) {
        
        
        [[NSAnimationContext currentContext] setDuration:0];
        [self.rowItem.table noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:self.row]];
        
        
        [_textField setFrameSize:NSMakeSize(NSWidth(self.frame) - self.item.xOffset * 2, size.height)];
        
        
      //  [[_separator animator] setFrame:NSMakeRect(self.item.xOffset, 0, NSWidth(self.frame) - (self.item.xOffset * 2), DIALOG_BORDER_WIDTH)];
       // if(rand_limit(5) > 3) {
        
       // [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
          //  [context setDuration:0.5];
        [_textField setFrameOrigin:NSMakePoint(self.item.xOffset, 5)];
      //  } completionHandler:^{
            
    //    }];
        
     //   }
        
        
        
        
    }
    
    if( self.item.callback != nil) {
        self.item.callback(self.item);
    }
    
    
 //
    
    NSString *search = nil;
    NSString *string = self.textField.stringValue;
    NSRange selectedRange = self.textField.selectedRange;
    TGHintViewShowType type = [TGMessagesHintView needShowHint:string selectedRange:selectedRange completeString:&string searchString:&search];
    
    if(type == TGHintViewShowMentionType && search != nil && ![string hasPrefix:@" "]) {
        TGMessagesHintView *hintView = [TGPopoverHint showHintViewForView:self.textField ofRect:_textField.frame];
      
        [hintView showMentionPopupWithQuery:search conversation:self.item.conversation chat:self.item.conversation.chat allowInlineBot:NO choiceHandler:^(NSString *result) {
            
            NSMutableString *insert = [self.textField.stringValue mutableCopy];
            
            [insert insertString:result atIndex:selectedRange.location - search.length];
            
            
            
            [self.textField setStringValue:insert];
            
            [TGPopoverHint close];
            
        }];
        
        if(hintView.isHidden) {
            [TGPopoverHint close];
        }

    } else {
         [TGPopoverHint close];
    }
    
}


-(void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];
    
    [_textField setFrameOrigin:NSMakePoint(self.item.xOffset, 5)];
    [_textField setFrameSize:NSMakeSize(newSize.width - self.item.xOffset * 2, self.item.height - 5)];
    [_separator setFrame:NSMakeRect(self.item.xOffset, 0, NSWidth(self.frame) - (self.item.xOffset * 2), DIALOG_BORDER_WIDTH)];
}


-(void)redrawRow {
    [super redrawRow];
    
    [_textField setAttributedStringValue:self.item.result];
    
    if(self.item.placeholder.length > 0) {
        [_textField setPlaceholderString:self.item.placeholder];
    }
    
    [self.window makeFirstResponder:_textField];
    
}

-(TGGeneralInputRowItem *)item {
    return (TGGeneralInputRowItem *)[self rowItem];
}

@end
