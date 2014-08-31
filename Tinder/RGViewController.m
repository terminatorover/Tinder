//
//  RGViewController.m
//  Tinder
//
//  Created by Vensi Developer on 8/30/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#import "RGViewController.h"

@interface RGViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic) UIDynamicAnimator *mainAnimator;
@property (nonatomic) UISnapBehavior *snapBehaviour;

@end

@implementation RGViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender
{
    NSLog(@"panning image");
    
    if( sender.state == UIGestureRecognizerStateBegan)
    {
        
    }else if (sender.state == UIGestureRecognizerStateChanged)
    {
        
    }else if(sender.state == UIGestureRecognizerStateEnded)
    {
        
    }
    
}

#pragma mark - Gesture Recongziner Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return  YES;
}


#pragma mark - Lazy Loading
- (UIDynamicAnimator *)mainAnimator
{
    if(!_mainAnimator)
    {
        _mainAnimator = [[UIDynamicAnimator alloc]init];
    }
    return _mainAnimator;
}


- (UIAttachmentBehavior *)attachmentBehaviour
{
    if(!_attachmentBehaviour)
    {
        _attachmentBehaviour = [[ UIAttachmentBehavior alloc]init];
    }
    return _attachmentBehaviour;
}

- (UISnapBehavior *)snapBehaviour
{
    if(!_snapBehaviour)
    {
        _snapBehaviour = [[UISnapBehavior alloc]init];
    }
    return  _snapBehaviour;
        
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
