//
//  VC1.m
//  LBBaseNav
//
//  Created by 刘泊 on 2018/12/23.
//  Copyright © 2018 LB. All rights reserved.
//

#import "VC1.h"

@interface VC1 ()
@property (nonatomic) float offsetx;
@end

@implementation VC1


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = 0;

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = 1;

}
    

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"VC1: %p",self.view);

    UIView* view = [UIView new];
    view.backgroundColor = UIColor.redColor;
    view.frame = CGRectMake(100, 100, 100, 100);
    view.tag = 100;
    [self.view addSubview:view];

    _offsetx = 100;

    self.title = @"1";

    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view viewWithTag:100].transform = CGAffineTransformMakeTranslation(_offsetx, 100);
    _offsetx += 30;


    if (_offsetx > 200) {
        _offsetx = 100;
        [self.view viewWithTag:100].transform = CGAffineTransformMakeTranslation(100,100);
        //CGAffineTransformIdentity;
    }

    NSLog(@"%@",NSStringFromCGRect([self.view viewWithTag:100].frame));
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
