//
//  ProBaseNav.m
//  LBBaseNav
//
//  Created by 刘泊 on 2018/12/24.
//  Copyright © 2018 LB. All rights reserved.
//

#import "ProBaseNav.h"

NSTimeInterval animationTime = 0.4f;



#define S_W [UIScreen mainScreen].bounds.size.width
#define S_H [UIScreen mainScreen].bounds.size.height


#pragma mark - 自定义类型
typedef UINavigationControllerOperation NavOption;



#pragma mark - 没有交互的的push\pop
@protocol LBNoInteractAni <UIViewControllerAnimatedTransitioning>
@end


typedef NS_ENUM(NSInteger,TransformsType) {
    TransformsTypeScreen_L, //距屏幕左边一个屏宽
    TransformsTypeScreen_M, //当前屏幕显示
    TransformsTypeScreen_R, //距屏幕右边一个屏宽
    TransformsTypeScreenTotals,
};

static CGAffineTransform allTransForms[TransformsTypeScreenTotals] ={
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0},
    {1, 0, 0, 1, 0, 0}};





#pragma mark - 协议动画对象
/** 协议对象 */
@interface LBNavAniDelegate : NSObject<LBNoInteractAni>
/** 当前是pop还是push */
@property (nonatomic)  NavOption option;
/** 引用的导航控制器 */
@property (nonatomic,weak) ProBaseNav* nav;
/** 截屏的view */
@property (nonatomic,weak) UIImageView* shotIconView;
/** 遮盖的view */
@property (nonatomic,weak) UIView* maskView;
/** 截图数组 */
@property (nonatomic,weak) UIImage* showImg;

/** 解决pop的时候的问题 */
@property (nonatomic,strong) UIImageView* popCurrentView;
@end

@implementation LBNavAniDelegate
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
    return animationTime;
}


#pragma mark - 动画的处理
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIWindow* window = self.nav.view.window;

    NSTimeInterval time = [self transitionDuration:transitionContext];

    UIView* finalView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView* transitionView = [transitionContext containerView];

    __weak typeof(self) weakSelf = self;



    //push
    if (self.option == UINavigationControllerOperationPush) {
        [weakSelf.popCurrentView removeFromSuperview];
        UIViewController* fianlVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect toViewEndFrame = [transitionContext finalFrameForViewController:fianlVC];
        toViewEndFrame.origin.x = 0;
        finalView.frame = toViewEndFrame;
        [transitionView addSubview:finalView];
        //截屏view的起始frame
        self.shotIconView.transform = allTransForms[TransformsTypeScreen_M];

        //截屏view的图片
        self.shotIconView.image = self.showImg;

        //添加截屏的view到窗口上
        [window insertSubview:self.shotIconView atIndex:0];


        //必须重新设置仿射矩阵
        self.maskView.transform = self.shotIconView.transform;

        //将遮盖的view添加到截屏的上面
        [window insertSubview:self.maskView aboveSubview:self.shotIconView];

        //导航view的要做动画时候 最初的frame(往左移动)
        weakSelf.nav.view.transform = allTransForms[TransformsTypeScreen_R];

        [UIView animateWithDuration:(time) animations:^{
            weakSelf.shotIconView.transform = allTransForms[TransformsTypeScreen_L];

            weakSelf.maskView.alpha = 0.5;

            weakSelf.nav.view.transform = allTransForms[TransformsTypeScreen_M];

        } completion:^(BOOL finished) {
            [weakSelf.shotIconView removeFromSuperview];
            [weakSelf.maskView removeFromSuperview];

            [transitionContext completeTransition:1];
        }];
    }else{
        UIViewController* fianlVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        CGRect toViewEndFrame = [transitionContext finalFrameForViewController:fianlVC];
        toViewEndFrame.origin.x = 0;
        finalView.frame = toViewEndFrame;


        [self printfScreen];


        //添加截屏的view到窗口上
        [window insertSubview:self.shotIconView atIndex:0];

        //截屏view的起始frame
        self.shotIconView.transform = allTransForms[TransformsTypeScreen_L];

        //截屏view的图片
        self.shotIconView.image = self.showImg;


        //pop的时候必须跟随shotview一起移动并且渐变
        self.maskView.transform = self.shotIconView.transform;

        //将遮盖的view添加到截屏的上面
        [window insertSubview:self.maskView aboveSubview:self.shotIconView];

        //导航view的要做动画时候 最初的frame(往左移动)
        weakSelf.nav.view.hidden = 1;
        weakSelf.popCurrentView.transform = allTransForms[TransformsTypeScreen_M];
        [window addSubview:weakSelf.popCurrentView];

        [UIView animateWithDuration:(time) animations:^{
            weakSelf.shotIconView.transform = allTransForms[TransformsTypeScreen_M];
            weakSelf.maskView.transform = weakSelf.shotIconView.transform;

            weakSelf.maskView.alpha = 0.0;
            weakSelf.popCurrentView.transform = allTransForms[TransformsTypeScreen_R];

        } completion:^(BOOL finished) {
            weakSelf.nav.view.hidden = 0;
            [weakSelf.popCurrentView removeFromSuperview];
            [transitionView addSubview:finalView];
            [weakSelf.shotIconView removeFromSuperview];
            [weakSelf.maskView removeFromSuperview];

            [transitionContext completeTransition:1];
        }];
    }
}

#pragma mark - 截取当前的屏幕
- (void)printfScreen{
    UIView* targetShotView = self.nav.hasTabbarController ? self.nav.view.window.rootViewController.view:self.nav.view;

    CGSize size = targetShotView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, 1, 0.0f);

    CGRect rect = targetShotView.bounds;
    [targetShotView drawViewHierarchyInRect:rect afterScreenUpdates:NO];

    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    self.popCurrentView.image = img;
}

- (UIImageView *)popCurrentView{
    if (!_popCurrentView) {
        _popCurrentView = [UIImageView new];
        _popCurrentView.frame = CGRectMake(0, 0, S_W, S_H);
    }
    return _popCurrentView;
}
@end


















@interface ProBaseNav ()<UINavigationControllerDelegate>

/** 动画的代理对象 */
@property (nonatomic,strong) LBNavAniDelegate* animationDelegate;
/** 是不是有tabbarcontroller */
@property  bool first; //加锁
/** 截图的数组 */
@property (nonatomic,strong) NSMutableArray<UIImage*>* shots;
/** 截屏的view */
@property (nonatomic,strong) UIImageView* shotIconView;
/** 遮盖的vie */
@property (nonatomic,strong) UIView* maskView;

/** 记录要显示的图片 */
@property (nonatomic,strong) UIImage* recordShowImg;


/** 手势拖拽 */
@property (nonatomic,weak) UIScreenEdgePanGestureRecognizer* leftPan;
/** 当前是拖拽的过程还是点击导航back的过程 */
@property (nonatomic) bool interactEnable;
@end

@implementation ProBaseNav

- (void)viewDidLoad {
    [super viewDidLoad];
    _first = true;



    allTransForms[0].tx = -S_W;
    allTransForms[1].tx = 0;
    allTransForms[2].tx = S_W;

    [UINavigationBar appearance].translucent = 0;


    self.delegate = self;

    [self initinalizationData]; //手势动画
}

#pragma mark - 手势动画(拖拽pop)
- (void)initinalizationData{
    UIScreenEdgePanGestureRecognizer* pan = [UIScreenEdgePanGestureRecognizer new];
    pan.edges = UIRectEdgeLeft;
    [pan addTarget:self action:@selector(leftPanAction:)];
    [self.view addGestureRecognizer:pan];
    _leftPan = pan;
}






#pragma mark - push/pop的时候返回动画的代理
- (id <LBNoInteractAni>)navigationController:(UINavigationController *)nav
             animationControllerForOperation:(NavOption)operation
                          fromViewController:(UIViewController *)fromVC
                            toViewController:(UIViewController *)toVC{

    if (self.interactEnable) return nil;
    self.animationDelegate.option = operation;
    _animationDelegate.nav = self;
    _animationDelegate.showImg = self.recordShowImg;
    _animationDelegate.shotIconView = self.shotIconView;
    _animationDelegate.maskView = self.maskView;
    if (operation == UINavigationControllerOperationPush)_maskView.alpha = 0.0f;
    else _maskView.alpha = 0.5;
    return _animationDelegate;
}




#pragma mark - 手势拖拽的处理
- (void)leftPanAction:(UIScreenEdgePanGestureRecognizer*)pan{
    if (self.visibleViewController == self.childViewControllers.firstObject)return;

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            [self panBegin:pan];
        }break;

        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:{
            [self panEnd:pan];
        }
            break;

        default:{
            [self panIng:pan];
        }break;
    }
}


#pragma mark - 开始拖拽的时候
- (void)panBegin:(UIScreenEdgePanGestureRecognizer*)pan{

    _interactEnable = true;
    [self.view.window insertSubview:self.shotIconView atIndex:0];
    [self.view.window insertSubview:self.maskView aboveSubview:self.shotIconView];
    self.shotIconView.image = self.shots.lastObject;

    self.shotIconView.transform = allTransForms[TransformsTypeScreen_L];
    self.maskView.transform = allTransForms[TransformsTypeScreen_M];
    self.maskView.alpha = 0.5;
}



#pragma mark - 拖拽的过程
- (void)panIng:(UIScreenEdgePanGestureRecognizer*)pan{
    float offsetX = [pan translationInView:self.view].x;

    if (offsetX > 0)self.view.transform = CGAffineTransformMakeTranslation(offsetX, 0);

    if (offsetX < S_W) self.shotIconView.transform = CGAffineTransformMakeTranslation(offsetX - S_W, 0);

    self.maskView.alpha = 0.5 - offsetX / S_W * 0.5;
}


#pragma mark - 结束拖拽的时候
- (void)panEnd:(UIScreenEdgePanGestureRecognizer*)pan{
    float tx = self.view.transform.tx;

    _interactEnable = false;

    __weak typeof(self) weakSelf = self;
    if (tx < 50) {
        [UIView animateWithDuration:animationTime animations:^{
            weakSelf.view.transform = allTransForms[TransformsTypeScreen_M];
            weakSelf.shotIconView.transform = allTransForms[TransformsTypeScreen_L];
        } completion:^(BOOL finished) {
            weakSelf.maskView.alpha = 0.5;
            [weakSelf.shotIconView removeFromSuperview];
            [weakSelf.maskView removeFromSuperview];
        }];

        return;
    }



    [UIView animateWithDuration:animationTime animations:^{
        weakSelf.view.transform = allTransForms[TransformsTypeScreen_R];
        weakSelf.shotIconView.transform = allTransForms[TransformsTypeScreen_M];

    } completion:^(BOOL finished) {
        weakSelf.maskView.alpha = 0;
        weakSelf.view.transform = allTransForms[TransformsTypeScreen_M];
        [weakSelf.shotIconView removeFromSuperview];
        [weakSelf.maskView removeFromSuperview];
        [weakSelf popViewControllerAnimated:NO];
    }];
}













#pragma mark - push拦截
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count) {
        viewController.hidesBottomBarWhenPushed = 1;
        viewController.tabBarController.tabBar.hidden= 1;
        _interactEnable = false;
        [self prinfScreen];
    }
    [super pushViewController:viewController animated:animated];
}


#pragma mark - pop上一个vc的时候删掉最后一张截图
- (UIViewController *)popViewControllerAnimated:(BOOL)animated{
    self.recordShowImg = self.shots.lastObject;
    [self.shots removeLastObject];
    return[super popViewControllerAnimated:animated];
}


#pragma mark - pop到根vc的时候移除所有的截图
- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated{
    self.recordShowImg = self.shots.firstObject;
    [self.shots removeAllObjects];
    return [super popToRootViewControllerAnimated:animated];
}


#pragma mark - pop某一个控制器的时候算出删除截图
- (NSArray<UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    NSInteger count = self.viewControllers.count;
    for (NSInteger i = count; i > -1; --i) {
        if (self.viewControllers[i] == viewController)break;
        self.recordShowImg = self.shots.lastObject;
        [self.shots removeLastObject];
    }
    return [super popToViewController:viewController animated:animated];
}


#pragma mark - 在push的时候就截屏
- (void)prinfScreen{
    UIView* targetShotView = self.hasTabbarController ? self.view.window.rootViewController.view:self.view;

    CGSize size = targetShotView.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, 1, 0.0f);

    CGRect rect = targetShotView.bounds;
    [targetShotView drawViewHierarchyInRect:rect afterScreenUpdates:NO];

    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    [self.shots addObject:img];
    _recordShowImg = img; //记录一下

    UIGraphicsEndImageContext();
}





#pragma mark - 图片数组
- (NSMutableArray<UIImage *> *)shots{
    if (!_shots) _shots = @[].mutableCopy;
    return _shots;
}


#pragma mark - 截屏的bool条件
- (bool)hasTabbarController{

    if (self.first){
        _hasTabbarController = self.tabBarController == self.view.window.rootViewController;
        self.first = false;
    }
    return _hasTabbarController;
}

#pragma mark - 动画代理
- (LBNavAniDelegate *)animationDelegate{
    if (!_animationDelegate) {
        _animationDelegate = [LBNavAniDelegate new];
    }
    return _animationDelegate;
}


#pragma mark - 截屏的vie
- (UIImageView *)shotIconView{
    if (!_shotIconView) {
        _shotIconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, S_W, S_H)];
        _shotIconView.backgroundColor = UIColor.greenColor;
    }
    return _shotIconView;
}


- (UIView *)maskView{
    if (!_maskView) {
        _maskView = [UIView new];
        _maskView.alpha = 0;
        _maskView.frame = CGRectMake(0, 0, S_W, S_H);
        _maskView.backgroundColor = UIColor.blackColor;
    }
    return _maskView;
}

@end





