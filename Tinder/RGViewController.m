//
//  RGViewController.m
//  Tinder
//
//  Created by Vensi Developer on 8/30/14.
//  Copyright (c) 2014 EnterWithBoldness. All rights reserved.
//

#define PUSH_FORCE 2

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
@property (nonatomic) UIPushBehavior *pushBehaviour;

@property (weak, nonatomic) IBOutlet UIImageView *mainImage;

@property (nonatomic) NSArray *arrayOfImages;

@property CGPoint initalImageLocation;
@property CGAffineTransform initalTransform;

@end

@implementation RGViewController
{
    NSInteger count ;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    count = 0;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.initalImageLocation = self.mainImage.center ;
    self.initalTransform = self.mainImage.transform;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)panRecognizer:(UIPanGestureRecognizer *)sender
{
    
    CGPoint locationOfTouch = [sender locationInView:self.view];
    if( sender.state == UIGestureRecognizerStateBegan)
    {
        //remove snap/push behaviour(in case this is the second round of interaction)
        [self.mainAnimator removeBehavior:self.snapBehaviour];
        [self.mainAnimator removeBehavior:self.pushBehaviour];
        
        //add the attachment Behaviour
        CGPoint touchPointInImage = [sender locationInView:self.mainImage];
        CGFloat midXValueOfBox = CGRectGetMidX( self.mainImage.frame);
        CGFloat midYValueOfBox = CGRectGetMidY(self.mainImage.frame);
        
        UIOffset userTouchTriggerdOffset = UIOffsetMake((touchPointInImage.x - midXValueOfBox)/5,
                                                        (touchPointInImage.y -midYValueOfBox)/5);
        
        
        _attachmentBehaviour = [[ UIAttachmentBehavior alloc]initWithItem:self.mainImage
                                                         offsetFromCenter:userTouchTriggerdOffset
                                                         attachedToAnchor:self.mainImage.center] ;
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
        DIRECTION  userIntention = [self getUserMovementIntention:self.mainImage];
        switch (userIntention) {
            case ORIGINAL_LOCATION:
                //snap back to original position
                [self.mainAnimator addBehavior:self.snapBehaviour];
                break;
            case BOTTOM:
                //use push to get rid of the card by pushing it down
                self.pushBehaviour.angle = 1.5f;
                [self.mainAnimator addBehavior:self.pushBehaviour];
                [self animateBackToScreen];
                break;
            case RIGHT:
                //user force to push it to the right
                self.pushBehaviour.angle = M_PI_2;
                [self.mainAnimator addBehavior:self.pushBehaviour];
                [self animateBackToScreen];
                break;
            case LEFT:
                //use force to push it to the left
                self.pushBehaviour.angle = M_PI;
                [self.mainAnimator addBehavior:self.pushBehaviour];
                [self animateBackToScreen];
                break;
            default:
                break;
        }
    }
    
}


#pragma mark - Move back onto screen 
- (void)animateBackToScreen
{
    count +=1;
    
    NSString *imageId = [self.arrayOfImages objectAtIndex:count%7];
    UIImage *imageToBeSeen = [UIImage imageNamed:imageId];
    self.mainImage.image = imageToBeSeen;
    [self.mainAnimator removeAllBehaviors];
    self.mainImage.transform = self.initalTransform;
    self.mainImage.alpha = 0.0;
    self.mainImage.center = self.initalImageLocation;
    NSTimeInterval waitForTime = .5;
    
    self.mainImage.frame  = CGRectMake(self.initalImageLocation.x, self.initalImageLocation.y, 10, 10);
    [UIView animateWithDuration:.8
                          delay:waitForTime
         usingSpringWithDamping:.4
          initialSpringVelocity:1.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.mainImage.frame  = CGRectMake(self.initalImageLocation.x, self.initalImageLocation.y, 300, 200);
                         self.mainImage.center = self.initalImageLocation;
                         self.mainImage.alpha = 1.0;
    }
                     completion:^(BOOL finished) {
       
    }];
    
    CABasicAnimation *scaleUp = [CABasicAnimation animation];
    scaleUp.keyPath = @"transform.scale";
    scaleUp.toValue =   [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    [self.mainImage.layer addAnimation:scaleUp forKey:@"scaleUpNow"];
    
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
                                                         offsetFromCenter:UIOffsetMake(10,0)
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

- (UIPushBehavior *)pushBehaviour
{
    if(!_pushBehaviour)
    {
        _pushBehaviour = [[UIPushBehavior alloc]initWithItems:@[self.mainImage] mode:UIPushBehaviorModeInstantaneous];
        _pushBehaviour.magnitude = PUSH_FORCE;
    }
    return _pushBehaviour;
}


- ( NSArray *)arrayOfImages
{
    if(!_arrayOfImages)
    {
        _arrayOfImages = @[@"i1",@"i2",@"i3",@"i4",@"i5",@"i6",@"i7"];
    }
    return _arrayOfImages;
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
