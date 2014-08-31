//
//  RGViewController.m
//  Tinder
//
//  Created by Vensi Developer on 8/30/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#import "RGViewController.h"

typedef enum{
    RIGHT,
    LEFT,
    BOTTOM,
    ORIGINAL_LOCATION
}DIRECTION;

@interface RGViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic) UIDynamicAnimator *mainAnimator;
@property (nonatomic) UISnapBehavior *snapBehaviour;
@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@property CGPoint initalImageLocation;

@end

@implementation RGViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.initalImageLocation = self.mainImage.center ;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender
{
    NSLog(@"panning image");
    
    CGPoint locationOfTouch = [sender locationInView:self.view];
    NSLog(@"%@",NSStringFromCGPoint(locationOfTouch));
    if( sender.state == UIGestureRecognizerStateBegan)
    {
        //remove snap behaviour(in case this is the second round of interaction)
        [self.mainAnimator removeBehavior:self.snapBehaviour];
        
        //add the attachment Behaviour
        [self.mainAnimator addBehavior:self.attachmentBehaviour];
        
    }else if (sender.state == UIGestureRecognizerStateChanged)
    {
        //change anchor point to change the location of the
        self.attachmentBehaviour.anchorPoint = locationOfTouch;
        
    }else if(sender.state == UIGestureRecognizerStateEnded)
    {
        //remove the attachment Behaviour
        [self.mainAnimator removeBehavior:self.attachmentBehaviour];
        
        DIRECTION  userIntention = [self getUserMovementIntention:self.mainImage];
        switch (userIntention) {
            case ORIGINAL_LOCATION:
                //snap back to original position
                [self.mainAnimator addBehavior:self.snapBehaviour];
                break;
            case BOTTOM:
                //use gravity to pull it down
                break;
            case RIGHT:
                //user force to push it to the right
                break;
            case LEFT:
                //use force to push it to the left
                break;
            default:
                break;
        }
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
        _mainAnimator = [[UIDynamicAnimator alloc]initWithReferenceView:self.view];
    }
    return _mainAnimator;
}


- (UIAttachmentBehavior *)attachmentBehaviour
{
    if(!_attachmentBehaviour)
    {
//        _attachmentBehaviour.anchorPoint.x - self.mainImage.center.x
//        self.mainImage.center.y - _attachmentBehaviour.anchorPoint.y
                
//        self.mainImage.center.x - self.initalImageLocation.x
        NSLog(@"X value: %f",(self.mainImage.center.x - self.initalImageLocation.x )/1.3 );

        _attachmentBehaviour = [[ UIAttachmentBehavior alloc]initWithItem:self.mainImage
                                                         offsetFromCenter:UIOffsetMake(-10,10)
                                                         attachedToAnchor:self.mainImage.center] ;
                                                                                       
        
    }
    return _attachmentBehaviour;
}

- (UISnapBehavior *)snapBehaviour
{
    if(!_snapBehaviour)
    {
        _snapBehaviour = [[UISnapBehavior alloc]initWithItem:self.mainImage snapToPoint:self.initalImageLocation];
    }
    return  _snapBehaviour;
        
}


#pragma mark - hit test 
/**
 *  Figures out where the user intends to move the image towards
 *
 *  @return DIRECITON typedef
 */
-(DIRECTION )getUserMovementIntention:(UIView *)givenImage
{
    //TODO:
    return ORIGINAL_LOCATION;
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
