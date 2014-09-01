//
//  RGViewController.m
//  Tinder
//
//  Created by Vensi Developer on 8/30/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#define PUSH_FORCE 100.0

#import "RGViewController.h"

typedef enum{
    RIGHT = 0,
    LEFT,
    BOTTOM,
    ORIGINAL_LOCATION
}DIRECTION;


typedef enum{
    TOP_CARD = 0,
    BOTTOM_CARD
}CURRENTLY_SHOWING;

@interface RGViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic) UIDynamicAnimator *mainAnimator;
@property (nonatomic) UISnapBehavior *snapBehaviour;
@property (nonatomic) UIPushBehavior *mainPushBehaviour;
@property (nonatomic) UIPushBehavior *backImagePushBehaviour;

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;
@property (weak, nonatomic) IBOutlet UIImageView *backImage;

@property CURRENTLY_SHOWING cardShown;

@property CGPoint initalImageLocation;
@property CGRect initalImageFrame;

@end

@implementation RGViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cardShown = TOP_CARD;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.initalImageLocation = self.mainImage.center ;
    self.initalImageFrame = self.mainImage.frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender
{
    NSLog(@"Current Card: %d",self.cardShown);
    
    CGPoint locationOfTouch = [sender locationInView:self.view];
    UIImageView *toAnimate = [self toBeAnimated];
    if( sender.state == UIGestureRecognizerStateBegan)
    {
        //remove snap/push behaviour(in case this is the second round of interaction)
        [self.mainAnimator removeAllBehaviors];
        
        
        //add the attachment Behaviour
        CGPoint touchPointInImage = [sender locationInView:self.mainImage];
        CGFloat midXValueOfBox = CGRectGetMidX( self.mainImage.frame);
        CGFloat midYValueOfBox = CGRectGetMidY(self.mainImage.frame);
        
        UIOffset userTouchTriggerdOffset = UIOffsetMake((touchPointInImage.x - midXValueOfBox)/5,
                                                        (touchPointInImage.y -midYValueOfBox)/5);
        
        
        _attachmentBehaviour = [[ UIAttachmentBehavior alloc]initWithItem:toAnimate
                                                         offsetFromCenter:userTouchTriggerdOffset
                                                         attachedToAnchor:toAnimate.center] ;
        [self.mainAnimator addBehavior:self.attachmentBehaviour];
        
    }else if (sender.state == UIGestureRecognizerStateChanged)
    {
        //change anchor point to change the location of the
        self.attachmentBehaviour.anchorPoint = locationOfTouch;
//        self.mainImage.center = locationOfTouch ;
        
    }else if(sender.state == UIGestureRecognizerStateEnded)
    {
        //remove the attachment Behaviour
        [self.mainAnimator removeBehavior:self.attachmentBehaviour];
        DIRECTION  userIntention = [self getUserMovementIntention:toAnimate];
        switch (userIntention) {
            case ORIGINAL_LOCATION:
                //snap back to original position
                [self.mainAnimator addBehavior:self.snapBehaviour];
                break;
            case BOTTOM:
                //use push to get rid of the card by pushing it down
                self.mainPushBehaviour.angle = 1.5f;
                [self.mainAnimator addBehavior:self.mainPushBehaviour];
                [self addPushToCorrectImage];
                [self setCurrentCardShown];
                break;
            case RIGHT:
                //user force to push it to the right
                self.mainPushBehaviour.angle = M_PI_2;
                [self addPushToCorrectImage];
                [self setCurrentCardShown];
                break;
            case LEFT:
                //use force to push it to the left
                self.mainPushBehaviour.angle = M_PI;
                [self addPushToCorrectImage];
                [self setCurrentCardShown];
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



- (UISnapBehavior *)snapBehaviour
{
    if(!_snapBehaviour)
    {
        _snapBehaviour = [[UISnapBehavior alloc]initWithItem:self.mainImage snapToPoint:self.initalImageLocation];
    }
    return  _snapBehaviour;
        
}

- (UIPushBehavior *)mainPushBehaviour
{
    if(!_mainPushBehaviour)
    {
        _mainPushBehaviour = [[UIPushBehavior alloc]initWithItems:@[self.mainImage] mode:UIPushBehaviorModeInstantaneous];
        _mainPushBehaviour.magnitude = PUSH_FORCE;
    }
    return _mainPushBehaviour;
}


- (UIPushBehavior *)backImagePushBehaviour
{
    if(!_backImagePushBehaviour)
    {
        _backImagePushBehaviour = [[UIPushBehavior alloc]initWithItems:@[self.backImagePushBehaviour] mode:UIPushBehaviorModeInstantaneous];
        _backImagePushBehaviour.magnitude = PUSH_FORCE;
    }
    return _backImagePushBehaviour;
}

#pragma mark - Helepers
/**
 *  Gives us which view needs to be interactive,also moves the
 *  image view that was pushed out to it's inital location
 *  @return top/bottom imageView
 */
- (UIImageView *)toBeAnimated
{
    if(self.cardShown == TOP_CARD)
    {
//        self.backImage.center = self.initalImageLocation;
        self.backImage.frame = self.initalImageFrame;
        return self.mainImage;
    }
//    self.mainImage.center = self.initalImageLocation;
    self.mainImage.frame = self.initalImageFrame;
    return self.backImage;
}

/**
 *  Sets the current card shown to the appropraite card, namely 
 *  if were were showing the top one and the user moves it
 *  off the scree we say that the other one is on top(we also 
 *  bring it to the front(in the view hierarcy
 */
- (void)setCurrentCardShown
{
    if(self.cardShown == TOP_CARD)
    {
        self.cardShown = BOTTOM_CARD;
        self.mainImage.userInteractionEnabled = NO;
        [self.view bringSubviewToFront:self.backImage];
        return;
    }
    [self.view bringSubviewToFront:self.mainImage];
    self.backImage.userInteractionEnabled = NO;
    self.cardShown = TOP_CARD;
}
/**
 *  There are two images and each has it's own push behaviour. 
 *  calling this method adds the right push behaviour to the 
 *  the right image
 */
- (void)addPushToCorrectImage
{
    
    if(self.cardShown == TOP_CARD)
    {
        [self.mainAnimator addBehavior:self.mainPushBehaviour];
        return;
    }else
    {
        [self.mainAnimator addBehavior:self.backImagePushBehaviour];
    }

}

#pragma mark - hit test
/**
 *  Figures out where the user intends to move the image towards
 *
 *  @return DIRECITON typedef
 */
- (DIRECTION )getUserMovementIntention:(UIView *)givenImage
{
    //TODO:
    BOOL leaningLeft = givenImage.center.x  < self.initalImageLocation.x - 50 ;
    BOOL inBottomHalf = givenImage.center.y > self.initalImageLocation.y + 200 ;
    BOOL leaningRight = givenImage.center.x  > self.initalImageLocation.x + 50;

    if(leaningLeft && inBottomHalf )
    {
        NSLog(@"Move LEft");
        return LEFT;
    }
    else if (leaningRight && inBottomHalf )
    {
        NSLog(@"Move Right");
        return RIGHT ;
    }
    NSLog(@"Move back where you came from");
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
