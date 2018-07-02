//
//  ViewController.m
//  ipadtest2
//
//  Created by kench on 2018/5/31.
//  Copyright © 2018年 kench. All rights reserved.
//



#import "ViewController.h"
#import "optionals.h"
#import "AppDelegate.h"
#import "optionalsCell.h"



#import "TableViewAnimationKitHeaders.h"//tableview的动画

#import "VHBoomMenuButton.h"//悬浮按钮
#import "BuilderManager.h"


#import "NSNotificationListener.h"//通知的监听者
#import "NotificationSender.h"//通知的发布者

#import <CoreBluetooth/CoreBluetooth.h>//蓝牙模块manager的代理
#import "bluetoothCell.h"//蓝牙的tableviewcell

#import <AVFoundation/AVFoundation.h> //播放音乐

#import "MBProgressHUD.h"//加载信息的缓冲


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource, UIGestureRecognizerDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,VHBoomDelegate>

@property(nonatomic,strong)UIView *optionview;//候选区的view
//@property(nonatomic,strong)UIScrollView *optionscrollview;//候选区的scroll

@property(nonatomic,strong)NSMutableArray *mainarray;//存储数据的数组

@property(nonatomic,strong)UITableView *maintv;//tableview


@property(nonatomic,strong)UIButton *optionstart;
@property(nonatomic,strong)UIButton *optionend;
@property(nonatomic,strong)UIButton *lighton;
@property(nonatomic,strong)UIButton *lightoff;
@property(nonatomic,strong)UIButton *optiondelay;
@property(nonatomic,strong)UIButton *loopstart;
@property(nonatomic,strong)UIButton *loopend;//几个按钮


@property(nonatomic,strong)NSMutableArray *delnamearray; //删除命令行的时候的一个判断要用的全局可变数组

@property(nonatomic,strong)UIButton *sendarraybtn;//进行数组的校验 校验完成后和蓝牙进行通讯并发送数组
@property(nonatomic,strong)NSMutableArray *sendarray;//再使用蓝牙进行文件传输的时候是所需要传过去的命令的数组

@property(nonatomic,strong)UITextView *infotextview;//将程序有关的信息写入到这个textview里面

@property(nonatomic,strong)UIButton *additionalclear;//程序信息的清除按钮（先放着）

@property(nonatomic,strong)NSArray *pickerds;//pickerview的数据库
@property(nonatomic,strong)UIPickerView *picker;//alertview的选择器
@property(nonatomic,strong)NSString *pickerstr;
//@property(nonatomic,strong)UILabel *cellclicklbl;

@property(nonatomic,strong)UITextView *rightinfotextview;//ß用来显示每个按钮的介绍
@property(nonatomic,strong)UILabel *righttoplabel;//用来显示蓝牙的链接状态


@property(nonatomic,assign)NSInteger index; //用来让长按弹出的alert知道 现在长按的是哪一个cell

@property(nonatomic,strong)VHBoomMenuButton *additionbtn;//小圆点

@property(nonatomic,strong)NSString *collectstr;//收藏到收藏夹的textfield的string
@property(nonatomic,strong)NSMutableArray *collectionarray;//收藏夹array

@property(nonatomic,strong)AVAudioPlayer *player;//播放音乐

@property(nonatomic,strong)UIView *collectionbgview;// 点击收藏夹弹出的背景view
@property(nonatomic,strong)UIView *collectionview;//点击收藏夹弹出的容纳其他控件的view
@property(nonatomic,strong)UITableView *collectiontable;//用来显示收藏的程序
@property(nonatomic,strong)UIButton *collectioncancel;//用来关闭弹出的view

@property(nonatomic,strong)MBProgressHUD *blueprogress;//加载的缓冲

@property(nonatomic,assign)CGPoint startpoint;//用来记录控件的初始位置（startbtn用）
@property(nonatomic,assign)CGPoint stoppoint;//用来记录控件的初始位置（end用）
@property(nonatomic,assign)CGPoint onpoint;//用来记录控件的初始位置（onbtn用）
@property(nonatomic,assign)CGPoint offpoint;//用来记录控件的初始位置（offbtn用）
@property(nonatomic,assign)CGPoint delaypoint;//用来记录控件的初始位置（delaybtn用）
@property(nonatomic,assign)CGPoint loopstartpoint;//用来记录控件的初始位置（loopstart用）
@property(nonatomic,assign)CGPoint loopendpoint;//用来记录控件的初始位置（loopend用）



@property(nonatomic,strong)UIPanGestureRecognizer *PanGestureRecognizer;//添加在试图上拖动的手势（startbtn用）
@property(nonatomic,strong)UIPanGestureRecognizer *stopPanGestureRecognizer;//添加在试图上拖动的手势（end用）
@property(nonatomic,strong)UIPanGestureRecognizer *onPanGestureRecognizer;//添加在试图上拖动的手势（onbtn用）
@property(nonatomic,strong)UIPanGestureRecognizer *offPanGestureRecognizer;//添加在试图上拖动的手势（offbtn用）
@property(nonatomic,strong)UIPanGestureRecognizer *delayPanGestureRecognizer;//添加在试图上拖动的手势（delaybtn用）
@property(nonatomic,strong)UIPanGestureRecognizer *loopstartPanGestureRecognizer;//用来记录控件的初始位置（loopstart用）
@property(nonatomic,strong)UIPanGestureRecognizer *loopendPanGestureRecognizer;//用来记录控件的初始位置（loopend用）


#pragma mark  蓝牙那一块的所有=========
@property(nonatomic,strong)UIView *bgview;//弹出蓝牙框的黑背景
@property(nonatomic,strong)UITableView *bluetable;//蓝牙的tableview

@property(nonatomic,strong)CBCentralManager *bluetoothManager;//蓝牙最主要的中心

@property(nonatomic,strong)NSMutableArray *bluearray;//装载蓝牙的数组
@property(nonatomic,strong)NSMutableArray *adarray;//装在出来rssi等额外的advertise信息的数组

@property (nonatomic,strong)CBPeripheral *myPeripheral; //蓝牙的从设备
@property (nonatomic,strong)CBCharacteristic *myCharacteristic;//蓝牙的charecteristic

//myPeripheral  myCharacteristic用来传array到蓝牙


@end

@implementation ViewController



#pragma mark-懒加载播放音乐的player
 -(AVAudioPlayer *)player
{
         if (_player==nil) {
                 //1.音频文件的url路径
                 NSURL *url=[[NSBundle mainBundle]URLForResource:@"401_1291369504.mp3" withExtension:Nil];
    
              //2.创建播放器（注意：一个AVAudioPlayer只能播放一个url）
                self.player=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:Nil];
             NSLog(@"播放音乐");
        
                 //3.缓冲
                 [self.player prepareToPlay];
             }
        return _player;
     }


#pragma mark   收藏夹array ================
-(NSMutableArray *)collectionarray{
    if (_collectionarray == nil) {
        _collectionarray = [[[NSMutableArray alloc]init]mutableCopy];
    }
    return _collectionarray;
}


#pragma mark 懒加载bluearray 蓝牙的数组 ================
-(NSMutableArray *)bluearray{
    if (_bluearray == nil) {
        _bluearray = [[NSMutableArray alloc]init];
    }
    return _bluearray;
}

#pragma mark 懒加载adarray ================
-(NSMutableArray *)adarray{
    if (_adarray == nil) {
        _adarray = [[NSMutableArray alloc]init];
    }
    return _adarray;
}

#pragma mark pickerds懒加载==============
-(NSArray *)pickerds{
    if (_pickerds == nil) {
        _pickerds = [[NSMutableArray alloc]init];
    }
    return _pickerds;
}

#pragma mark delnamearray懒加载==============
-(NSMutableArray *)delnamearray{
    if (_delnamearray == nil) {
        _delnamearray = [[NSMutableArray alloc]init];
    }
    return _delnamearray;
}

#pragma mark mainarray懒加载==============
-(NSMutableArray *)mainarray{
   // NSLog(@"mainarray懒加载");
    if (_mainarray == nil) {
        _mainarray = [[NSMutableArray alloc]init];
    }
    return _mainarray;
}

#pragma mark sendarray懒加载==============
-(NSMutableArray *)sendarray{
    if (_sendarray == nil) {
        _sendarray = [[NSMutableArray alloc]init];
    }
    return _sendarray;
}

#pragma mark PanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)PanGestureRecognizer{
    if (_PanGestureRecognizer == nil) {
        _PanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragmoved:)];
    }
    return _PanGestureRecognizer;
}

#pragma mark stopPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)stopPanGestureRecognizer{
    if (_stopPanGestureRecognizer == nil) {
        _stopPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(stopdragmoved:)];
    }
    return _stopPanGestureRecognizer;
}

#pragma mark onPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)onPanGestureRecognizer{
    if (_onPanGestureRecognizer == nil) {
        _onPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(ondragmoved:)];
    }
    return _onPanGestureRecognizer;
}

#pragma mark offPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)offPanGestureRecognizer{
    if (_offPanGestureRecognizer == nil) {
        _offPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(offdragmoved:)];
    }
    return _offPanGestureRecognizer;
}

#pragma mark delayPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)delayPanGestureRecognizer{
    if (_delayPanGestureRecognizer == nil) {
        _delayPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(delaydragmoved:)];
    }
    return _delayPanGestureRecognizer;
}

#pragma mark _loopstartPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)loopstartPanGestureRecognizer{
    if (_loopstartPanGestureRecognizer == nil) {
        _loopstartPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(loopstartdragmoved:)];
    }
    return _loopstartPanGestureRecognizer;
}

#pragma mark _loopendPanGestureRecognizer懒加载==============
-(UIPanGestureRecognizer *)loopendPanGestureRecognizer{
    if (_loopendPanGestureRecognizer == nil) {
        _loopendPanGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(loopenddragmoved:)];
    }
    return _loopendPanGestureRecognizer;
}


#pragma mark 隐藏状态栏=================
//隐藏状态栏
-(BOOL)prefersStatusBarHidden{
    return YES;
}

//强制横屏没商量
- (void)setNewOrientation:(BOOL)fullscreen
{
    
    if (fullscreen) {
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }else{
        
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
        
    }
    
}
-(void)orientationcontrol{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;//(以上2行代码,可以理解为打开横屏开关)
    [self setNewOrientation:YES];//调用转屏代码
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self orientationcontrol];//设置横屏
    
    [self createview];
    
    [self createleftbtn];

    [self createmaintv];
    
    [self createaddtionalview];
    
    [self createrightview];
    
   // [self listenbluetoothstate];
    //通知的监听
    
    [self setbackgroundview];//设置背景的view
    
}


#pragma mark 设置背景的view==============
-(void)setbackgroundview{
    UIImageView *mainbgimgview = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    mainbgimgview.image = [UIImage imageNamed:@"guoda"];
    
    [self.view addSubview:mainbgimgview];
    [self.view sendSubviewToBack:mainbgimgview];
    
}


#pragma mark 设置设置各个view的alpha==============
//-(void)setviewalpha:(UIView *)characterview{
//
//    characterview.alpha = 0.7;
//}


#pragma mark 设置左侧栏的view==============
-(void)createview{
    NSLog(@"width = %f",self.view.frame.size.width);
    NSLog(@"height = %f",self.view.frame.size.height);
   
    CGFloat X = 5;
    CGFloat Y = 50;
    CGFloat W = self.view.frame.size.height *0.3 - X;
    CGFloat H = self.view.frame.size.width - Y -5;
    
    
    UIView *topleftview = [[UIView alloc]initWithFrame:CGRectMake(X, 5, W, 40)];
    [self.view addSubview:topleftview];
    topleftview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    topleftview.layer.cornerRadius = 10;
    UILabel *topleftlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, W, 40)];
    topleftlbl.text = @"功能选择区";
    topleftlbl.textAlignment = NSTextAlignmentCenter;
    topleftlbl.font = [UIFont systemFontOfSize:30];
    [topleftview addSubview:topleftlbl];
  
    //[self setviewalpha:topleftview];
  
    
    UIView *leftview = [[UIView alloc]initWithFrame:CGRectMake(X, Y, W, H)];
    [self.view addSubview:leftview];
    leftview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    leftview.layer.cornerRadius = 10;
    self.optionview = leftview;
    //[self setviewalpha:leftview];
    

    
    [self.view sendSubviewToBack:topleftlbl];
    [self.view sendSubviewToBack:topleftview];
}

#pragma mark 设置左侧栏的按钮==============
-(void)createleftbtn{
    NSLog(@"width = %f",self.view.frame.size.width);
    NSLog(@"height = %f",self.view.frame.size.height);
    
    CGFloat margin = 15;

    CGFloat X = 10;
    CGFloat Y = margin;
    CGFloat W = self.optionview.frame.size.width- 20;
    CGFloat H = 80;
    
    UIButton *startbtn = [[UIButton alloc]initWithFrame:CGRectMake(X , Y , W , H)];
    [startbtn setTitle:@"开始" forState:UIControlStateNormal];
    startbtn.backgroundColor = [UIColor greenColor];
    [self.optionview addSubview:startbtn];
    startbtn.layer.cornerRadius = 10;
    startbtn.titleLabel.font = [UIFont systemFontOfSize:30];
    self.optionstart = startbtn;
    

    [startbtn addGestureRecognizer:self.PanGestureRecognizer];
    CGPoint startpoint = startbtn.center;
    self.startpoint = startpoint;
 
 
    
    UIButton *endbtn = [[UIButton alloc]initWithFrame:CGRectMake(X , Y + margin + H, W, H)];
      [endbtn setTitle:@"结束" forState:UIControlStateNormal];
      endbtn.backgroundColor = [UIColor purpleColor];
    [self.optionview addSubview:endbtn];
    [self.optionview bringSubviewToFront:endbtn];
    endbtn.layer.cornerRadius = 10;
    endbtn.titleLabel.font = [UIFont systemFontOfSize:30];
    self.optionend = endbtn;
    [endbtn addGestureRecognizer:self.stopPanGestureRecognizer];
    CGPoint stoppoint = endbtn.center;
    self.stoppoint = stoppoint;
    
    UIButton *on = [[UIButton alloc]initWithFrame:CGRectMake(X ,  Y + margin*2 + H*2, W, H)];
      [on setTitle:@"点亮灯泡" forState:UIControlStateNormal];
    on.backgroundColor = [UIColor orangeColor];
    [self.optionview addSubview:on];
    on.layer.cornerRadius = 10;
    on.titleLabel.font = [UIFont systemFontOfSize:30];
    self.lighton = on;
    
    [on addGestureRecognizer:self.onPanGestureRecognizer];
    CGPoint onpoint = on.center;
    self.onpoint = onpoint;
    

    UIButton *off = [[UIButton alloc]initWithFrame:CGRectMake(X ,  Y + margin*3 + H*3, W, H)];
    [off setTitle:@"关闭灯泡" forState:UIControlStateNormal];
    off.backgroundColor = [UIColor magentaColor];
    [self.optionview addSubview:off];
    off.layer.cornerRadius = 10;
    off.titleLabel.font = [UIFont systemFontOfSize:30];
    self.lightoff = off;
    
    [off addGestureRecognizer:self.offPanGestureRecognizer];
    CGPoint offpoint = off.center;
    self.offpoint = offpoint;
    
    
    
    UIButton *delay = [[UIButton alloc]initWithFrame:CGRectMake(X , Y + margin*4 + H*4  , W, H)];
    [delay setTitle:@"延迟" forState:UIControlStateNormal];
    delay.backgroundColor = [UIColor yellowColor];
    [self.optionview addSubview:delay];
    delay.layer.cornerRadius = 10;
    delay.titleLabel.font = [UIFont systemFontOfSize:30];
    self.optiondelay = delay;
   
    [delay addGestureRecognizer:self.delayPanGestureRecognizer];
    CGPoint delaypoint = delay.center;
    self.delaypoint = delaypoint;
    
    
    UIButton *loopstart= [[UIButton alloc]initWithFrame:CGRectMake(X,  Y + margin*5 + H*5, W, H)];
    [loopstart setTitle:@"循环" forState:UIControlStateNormal];
    loopstart.backgroundColor = [UIColor cyanColor];
    [self.optionview addSubview:loopstart];
    loopstart.layer.cornerRadius = 10;
    loopstart.titleLabel.font = [UIFont systemFontOfSize:30];
    self.loopstart = loopstart;
    
    [loopstart addGestureRecognizer:self.loopstartPanGestureRecognizer];
    CGPoint loopstartpoint = loopstart.center;
    self.loopstartpoint = loopstartpoint;
    
    
    UIButton *loopend= [[UIButton alloc]initWithFrame:CGRectMake(X,  Y + margin*6 + H*6, W, H)];
    [loopend setTitle:@"循环结束" forState:UIControlStateNormal];
    loopend.backgroundColor = [UIColor cyanColor];
    [self.optionview addSubview:loopend];
    loopend.layer.cornerRadius = 10;
    loopend.titleLabel.font = [UIFont systemFontOfSize:30];
    self.loopend = loopend;
    
    loopend.enabled = NO;
    
    
    [loopend addGestureRecognizer:self.loopendPanGestureRecognizer];
    CGPoint loopendpoint = loopend.center;
    self.loopendpoint = loopendpoint;
    
}

#pragma mark dragmoved方法==============
-(void)dragmoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.optionview bringSubviewToFront:self.optionstart];
  //  [self.view sendSubviewToBack:self.additionbtn];
   // [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.optionstart.center = CGPointMake(self.optionstart.center.x + translation.x, self.optionstart.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.optionstart.center)) {
                [self createmainarray:@"systemstart" andname:@"开始"];
                [self.optionstart removeGestureRecognizer:panGestureRecognizer];
                [UIView animateWithDuration:0.3 animations:^{
                    self.optionstart.center = CGPointMake(self.startpoint.x, self.startpoint.y);
                }];
              
            }else{
                [UIView animateWithDuration:0.5 animations:^{
                    self.optionstart.center = CGPointMake(self.startpoint.x, self.startpoint.y);
                }];
            }
        }
    }
 
}

#pragma mark stopdragmoved方法==============
-(void)stopdragmoved:(UIPanGestureRecognizer *)panGestureRecognizer
{

            [self.optionview bringSubviewToFront:self.optionend];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        self.optionend.center = CGPointMake(self.optionend.center.x + translation.x, self.optionend.center.y + translation.y);
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.optionend.center)) {
                [self createmainarray:@"systemend" andname:@"结束"];
                [self.optionend removeGestureRecognizer:panGestureRecognizer];
                [UIView animateWithDuration:0.3 animations:^{
                    self.optionend.center = CGPointMake(self.stoppoint.x, self.stoppoint.y);
                }];
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.optionend.center = CGPointMake(self.stoppoint.x, self.stoppoint.y);
                }];
            }
        }
    }
    
}

#pragma mark ondragmoved方法==============
-(void)ondragmoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.optionview bringSubviewToFront:self.lighton];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.lighton.center = CGPointMake(self.lighton.center.x + translation.x, self.lighton.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.lighton.center)) {
                [self createmainarray:@"lighton1" andname:@"开1号灯"];
               
                [UIView animateWithDuration:0.3 animations:^{
                    self.lighton.center = CGPointMake(self.onpoint.x, self.onpoint.y);
                }];
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.lighton.center = CGPointMake(self.onpoint.x, self.onpoint.y);
                }];
            }
        }
    }
    
}

#pragma mark offdragmoved方法==============
-(void)offdragmoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.optionview bringSubviewToFront:self.lightoff];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.lightoff.center = CGPointMake(self.lightoff.center.x + translation.x, self.lightoff.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.lightoff.center)) {
                [self createmainarray:@"lightoff1" andname:@"关1号灯"];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.lightoff.center = CGPointMake(self.offpoint.x, self.offpoint.y);
                }];
                
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.lightoff.center = CGPointMake(self.offpoint.x, self.offpoint.y);
                }];
            }
        }
    }
    
}

#pragma mark delaydragmoved方法==============
-(void)delaydragmoved:(UIPanGestureRecognizer *)panGestureRecognizer
{
    [self.optionview bringSubviewToFront:self.optiondelay];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.optiondelay.center = CGPointMake(self.optiondelay.center.x + translation.x, self.optiondelay.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.optiondelay.center)) {
                [self createmainarray:@"delayfor1" andname:@"延迟1秒"];
                [UIView animateWithDuration:0.3 animations:^{
                    self.optiondelay.center = CGPointMake(self.delaypoint.x, self.delaypoint.y);
                }];
                
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.optiondelay.center = CGPointMake(self.delaypoint.x, self.delaypoint.y);
                }];
            }
        }
    }
    
}

#pragma mark loopstartdragmoved方法==============
-(void)loopstartdragmoved:(UIPanGestureRecognizer *)panGestureRecognizer{
    [self.optionview bringSubviewToFront:self.loopstart];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.loopstart.center = CGPointMake(self.loopstart.center.x + translation.x, self.loopstart.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.loopstart.center)) {
                [self createmainarray:@"loopfor1" andname:@"循环1次"];
                
                self.loopstart.enabled = NO;//循环开始被拉到tableview里面后 关闭loopstart
                self.loopend.enabled = YES;
                
//                [self.loopstart removeGestureRecognizer:self.loopstartPanGestureRecognizer];
//                [self.loopend addGestureRecognizer:self.loopendPanGestureRecognizer];
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.loopstart.center = CGPointMake(self.loopstartpoint.x, self.loopstartpoint.y);
                }];}else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.loopstart.center = CGPointMake(self.loopstartpoint.x, self.loopstartpoint.y);
                }];
            }
        }
    }
    
}

#pragma mark loopenddragmoved方法==============
-(void)loopenddragmoved:(UIPanGestureRecognizer *)panGestureRecognizer{
    
    [self.optionview bringSubviewToFront:self.loopend];
//    [self.view sendSubviewToBack:self.additionbtn];
//    [self.view sendSubviewToBack:self.maintv];
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint  translation = [panGestureRecognizer translationInView:self.view];
        
        self.loopend.center = CGPointMake(self.loopend.center.x + translation.x, self.loopend.center.y + translation.y);
        
        [panGestureRecognizer setTranslation:CGPointZero inView:self.view];
        
    }else{
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (CGRectContainsPoint(self.maintv.frame, self.loopend.center)) {
                [self createmainarray:@"loopend" andname:@"结束循环"];
                
                self.loopend.enabled = NO;//循环结束被拉到tableview里面后 关闭loopstart
                self.loopstart.enabled = YES;
                
//                [self.loopend removeGestureRecognizer:self.loopstartPanGestureRecognizer];
//                [self.loopstart addGestureRecognizer:self.loopendPanGestureRecognizer];
//
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.loopend.center = CGPointMake(self.loopendpoint.x, self.loopendpoint.y);
                }];}else{
                    [UIView animateWithDuration:0.3 animations:^{
                        self.loopend.center = CGPointMake(self.loopendpoint.x, self.loopendpoint.y);
                    }];
                }
        }
    }
    
}

#pragma mark 把生成一个mainarray抽成一个方法==================
-(void)createmainarray :(NSString *)intomean andname:(NSString *)intoname{
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:intomean forKey:@"mean"];
    [dict setObject:intoname forKey:@"name"];

    
    if (dict) {
        [self.mainarray addObject:dict];
        NSLog(@"mainarray = %@",self.mainarray);
        [self.maintv reloadData];
      

     }


    NSIndexPath *lastindexpath = [NSIndexPath indexPathForRow:self.mainarray.count -1 inSection:0];
    [self.maintv scrollToRowAtIndexPath:lastindexpath atScrollPosition:UITableViewScrollPositionTop animated:NO];//滚动到tableview的最后

    [self starAnimationWithTableView:self.maintv];//开启动画
    
    
}

#pragma mark 设置右边栏rightview==============
-(void)createrightview{
    CGFloat X = self.maintv.frame.size.width +self.maintv.frame.origin.x +5;
    CGFloat Y = self.maintv.frame.origin.y;
    CGFloat W = self.view.frame.size.height - X - 5;
    CGFloat H = self.maintv.frame.size.height ;
    UIView *rightview = [[UIView alloc]initWithFrame:CGRectMake(X, Y, W, H)];
    [self.view addSubview:rightview];
    rightview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    rightview.layer.cornerRadius = 10;
    //[self setviewalpha:rightview];
    
    UIView *righttopview = [[UIView alloc]initWithFrame:CGRectMake(X, 5, W, 40)];
    righttopview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self.view addSubview:righttopview];
    righttopview.layer.cornerRadius = 10;
    UILabel *rightoplbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, W, 40)];
    rightoplbl.text = @"模块信息区";
    rightoplbl.font = [UIFont systemFontOfSize:30];
    rightoplbl.textAlignment = NSTextAlignmentCenter;
    [righttopview addSubview:rightoplbl];
  
    //[self setviewalpha:righttopview];
    
    UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(10, Y+300, W-20, H-360)];
    [rightview addSubview:text];
    text.editable = NO;//转换为不可编辑状态
    text.backgroundColor  = [UIColor lightGrayColor];
    text.text  = [NSString stringWithFormat: @" 在这里显示的是每一个模块的相应介绍，你需要把某一个模块拖到程序执行界面上再点击相应的模块就可以看到这个模块的相应介绍"];
    text.textColor = [UIColor blueColor];
    text.layer.cornerRadius = 10;
    text.font = [UIFont systemFontOfSize:17];
    self.rightinfotextview = text;

    
    

    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, W-20, 120)];
    lbl.text = @"  这里将要显示的是蓝牙模块的连接状态。";
    lbl.lineBreakMode = 0;
    lbl.numberOfLines =0;
    
    lbl.font = [UIFont systemFontOfSize:17];
    lbl.layer.cornerRadius = 10;
    lbl.layer.masksToBounds= YES;
    lbl.textColor = [UIColor blueColor];
    lbl.backgroundColor = [UIColor lightGrayColor];
    [rightview addSubview:lbl];
    self.righttoplabel = lbl;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(textclick)];
    [lbl addGestureRecognizer:tap];
    lbl.userInteractionEnabled = YES;
    
    
    
    [self.view sendSubviewToBack:righttopview];
    [self.view sendSubviewToBack:rightview];
}



#pragma mark 连接到外围蓝牙设备的弹框==============
-(void)textclick{

    if (!self.myPeripheral) {
        UIView *bgview = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        bgview.backgroundColor = [UIColor clearColor];
        [self.view addSubview:bgview];
        
        self.bgview = bgview;
      
        UIView *blackview = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        blackview.backgroundColor = [UIColor blackColor];
        [bgview addSubview:blackview];
        blackview.alpha = 0.5;
        
        CGFloat W =kenscreenwidth*0.5 ;
        CGFloat H =kenscreenheight*0.5;
        CGFloat X = (kenscreenwidth - W)*0.5;
        CGFloat Y =(kenscreenheight - H)*0.5;
        
        UIView *bgmainview =  [[UIView alloc]initWithFrame:CGRectMake(X, Y ,W , H)];
        bgmainview.backgroundColor = [UIColor whiteColor];
        bgmainview.layer.cornerRadius = 10;
       
        [bgview addSubview:bgmainview];
        
        
        UITableView *bluetable = [[UITableView alloc]initWithFrame:CGRectMake(10, 0,bgmainview.frame.size.width *0.6 , H) style:UITableViewStylePlain];
        [bgmainview addSubview:bluetable];
        bluetable.alpha = 1.0;
        bluetable.delegate = self;
        bluetable.dataSource = self;
        bluetable.layer.cornerRadius = 10;
        bluetable.hidden =  YES;
        self.bluetable = bluetable;
        
      
        
        
        UIButton *cancelbtn = [[UIButton alloc]initWithFrame:CGRectMake(X, Y+H+20, W, 40)];
        cancelbtn.layer.cornerRadius = 10;
        [cancelbtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelbtn.backgroundColor = [UIColor redColor];
        [bgview addSubview:cancelbtn];
        [cancelbtn addTarget:self action:@selector(cancelaction) forControlEvents:UIControlEventTouchUpInside];
        
        
        CGFloat btnW = 80;
        CGFloat btnH = 80;
        
        UIButton *linkblue = [[UIButton alloc]initWithFrame:CGRectMake(bluetable.frame.size.width + bluetable.frame.origin.x + 60, bgmainview.frame.size.height*0.5 - btnH*0.5, btnW, btnH)];
        linkblue.backgroundColor = [UIColor redColor];
        [linkblue setTitle:@"搜索" forState:UIControlStateNormal];
        [bgmainview addSubview:linkblue];
        linkblue.layer.cornerRadius = btnW*0.5;
        [linkblue addTarget:self action:@selector(searchbluetooth) forControlEvents:UIControlEventTouchUpInside];
        
        
           [self progressload];//加载动画

    }
    
    
}


#pragma mark 加载中，请稍后==============
-(void)progressload{
    NSLog(@"progressload");
    self.blueprogress = [[MBProgressHUD alloc]initWithView:self.bluetable];
    self.blueprogress.mode = MBProgressHUDModeIndeterminate;
    self.blueprogress.label.text = @"加载中，请稍后~~~";
    self.blueprogress.progress = 1;
    [self.view addSubview:self.blueprogress];
    
}

#pragma mark 取消搜索的按钮方法==========
-(void)cancelaction{
    [self.bgview removeFromSuperview];
    
    self.bluearray = nil;
    self.adarray = nil;
    
}

#pragma mark 搜索蓝牙的按钮方法==========
-(void)searchbluetooth{
 
    //创建中心设备管理器并设置当前控制器视图为代理
    _bluetoothManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    self.bluearray = nil;

    [self.blueprogress showAnimated:YES];//蓝牙的加载动画
    
}


#pragma mark 不是很重要的additionalview==============
-(void)createaddtionalview {
  
    CGFloat X = self.view.frame.size.height *0.3;
    CGFloat Y = 0;
    CGFloat W = 5;
// CGFloat H = self.view.frame.size.height ;
//    UIView *obmview = [[UIView alloc]initWithFrame:CGRectMake(X, Y, W, H)];
//    obmview.backgroundColor = [UIColor lightGrayColor];
//    [self.view addSubview:obmview];
//    [self.view sendSubviewToBack:obmview];
    
    UIView *aboview = [[UIView alloc]initWithFrame:CGRectMake(X + W, Y + self.maintv.frame.size.height + 5+50, self.view.frame.size.height - W - self.optionview.frame.size.width, self.view.frame.size.width - self.maintv.frame.size.height - 5- 50)];
    [self.view addSubview:aboview];
    
    //[self setviewalpha:aboview];
    
    [self.view sendSubviewToBack:aboview];

    UIButton *sendbtn = [[UIButton alloc]initWithFrame:CGRectMake(self.maintv.frame.size.width +5, 0,aboview.frame.size.width - self.maintv.frame.size.width -10, aboview.frame.size.height - 5)];
    [sendbtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    sendbtn.titleLabel.font = [UIFont systemFontOfSize:30];
    sendbtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    sendbtn .layer.cornerRadius = 10;
    [aboview addSubview:sendbtn];
    [sendbtn addTarget:self action:@selector(sendclick) forControlEvents:UIControlEventTouchUpInside];
    self.sendarraybtn = sendbtn;
    
    UITextView *text = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,self.maintv.frame.size.width, aboview.frame.size.height - 5)];
    text.editable = NO;//转换为不可编辑状态
    text.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    NSDate *nowdate = [NSDate date];//获取当前系统时间
    //创建一个日期时间的格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //设置格式
    formatter.dateFormat = @" yyyy-MM-dd HH:mm:ss";
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    NSString *time = [formatter stringFromDate:nowdate];

    text.text  = [NSString stringWithFormat: @"%@    welcome to this app,this app is aim to approve your logical thinking ability and train your brain !",time];
    text.textColor = [UIColor blueColor];
    text.layer.cornerRadius = 10;
    text.font = [UIFont systemFontOfSize:17];
    [aboview addSubview:text];
    self.infotextview = text;
    
//    UIView *mbiview = [[UIView alloc]initWithFrame:CGRectMake( self.maintv.frame.size.width + self.maintv.frame.origin.x , 0, 5, self.view.frame.size.height -aboview.frame.size.height)];
//    mbiview.backgroundColor = [UIColor lightGrayColor];
//   [self.view addSubview:mbiview];
//    [self.view sendSubviewToBack:mbiview];
    
    
    CGFloat addw = 60;
    CGFloat addh = 60;
    VHBoomMenuButton *additionbtn = [[VHBoomMenuButton alloc ]initWithFrame:CGRectMake(self.maintv.frame.origin.x +20, self.maintv.frame.size.height * 0.96, addw, addh )];
    
    additionbtn.buttonEnum = VHButtonHam;
    additionbtn.piecePlaceEnum = VHPiecePlaceHAM_4;
    additionbtn.buttonPlaceEnum = VHButtonPlaceHAM_4;
    //additionbtn.pieceCornerRadius = 1;
    
    
    additionbtn.boomDelegate = self;
    self.additionbtn = additionbtn;
    
    for (int i = 0; i < self.additionbtn.pieceNumber; i++)
    {
        if (i== 0) {
               [self.additionbtn addBuilder:[BuilderManager hamButtonBuilderWithText:@"连接外围设备" withSubText:@"点击可以连接外围设备 请保持蓝牙处于打开状态"]];
        }else if (i == 1){
            [self.additionbtn addBuilder:[BuilderManager hamButtonBuilderWithText:@"播放/ 暂停儿歌" withSubText:@""]];
        }else if (i == 2 ){
                [self.additionbtn addBuilder:[BuilderManager hamButtonBuilderWithText:@"收藏当前程序" withSubText:@"收藏当前程序， 可以在之后进行查看 "]];
        }else{
               [self.additionbtn addBuilder:[BuilderManager hamButtonBuilderWithText:@"查看我收藏程序" withSubText:@"查看已经收藏的程序"]];
        }
    
    }
    [self.view addSubview:self.additionbtn];

}

#pragma mark 大佬的小圆点的代理方法=================
- (void)boomMenuButton:(VHBoomMenuButton *)bmb didClickBoomButtonOfBuilder:(VHBoomButtonBuilder *)builder at:(int)index
{
    NSLog(@"%d",index);
    switch (index) {
        case ( 0):
            [self textclick];//连接到外围设备
            break;
        case ( 1):
          //播放音乐
            if (!_player) {
                
                [self.player play];
                [self.player setNumberOfLoops:1000000]; //设置重复播放
                
            }else{
                
                [self.player stop];
                self.player = nil;
                
                            }
            break;
        case ( 2):
           
            [self addtocollection];//添加到收藏
            break;
        case ( 3):
           //展示收藏
            [self showthecollection];
            break;
        default:
            break;
    }

}

#pragma mark 添加到收藏=================
-(void)addtocollection{
    NSLog(@"main = %@",self.mainarray);
    
    NSMutableArray *drrpcoptyarray = [NSMutableArray array];
    drrpcoptyarray = [self.mainarray mutableCopy];
    
    //NSMutableArray *collectarray = [NSMutableArray array];
    
    if (self.mainarray.firstObject) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"添加到收藏" message:@"请给你的程序起一个名字" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            // 可以在这里对textfield进行定制，例如改变背景色
            
            //self.collectstr = [NSString stringWithFormat:@"%@",login.text];
        }];
        
        UIAlertAction *ok= [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (alert.textFields.firstObject.text) {
                NSString *collector = [NSString stringWithFormat:@"%@",alert.textFields.firstObject.text];
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:collector forKey:@"title"];
                [dict setObject:drrpcoptyarray forKey:@"array"];

                NSLog(@"drrpcoptyarray%@",drrpcoptyarray);
                NSLog(@"mainarray%@",self.mainarray);

                if (dict) {
                     [self.collectionarray addObject:dict];

                }
               
            }
             NSLog(@"收藏夹collectionarray= %@",self.collectionarray);
            
            [[NSUserDefaults standardUserDefaults] setObject:self.collectionarray forKey:@"collection"];//本地数据持久化 将整个collectionarray 保存到本地的userdefault当中
            
            //[self.collectionarray removeAllObjects];
            
        }];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    

    
}

#pragma mark 展示收藏
-(void)showthecollection{
    UIView *collectionbgview =[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    collectionbgview.backgroundColor = [UIColor blackColor];
    collectionbgview.alpha = 0.5;
    [self.view addSubview:collectionbgview];
    self.collectionbgview = collectionbgview;
    
    CGFloat collectionW = kenscreenwidth*0.5;
    CGFloat collectionH = kenscreenheight*0.5;
    UIView *collectionview = [[UIView alloc]initWithFrame:CGRectMake((kenscreenheight- collectionW), (kenscreenwidth- collectionH )*0.25, collectionW, collectionH)];
    collectionview.backgroundColor = [UIColor whiteColor];
    collectionview.layer.cornerRadius =10;
    [self.view addSubview:collectionview];
    self.collectionview = collectionview;
    
    UILabel *collectiontitlelbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, collectionview.frame.size.width, 60)];
    //collectiontitlelbl.backgroundColor = [UIColor lightGrayColor];
    collectiontitlelbl.text = @"请选择你要展示的收藏程序";
    collectiontitlelbl.textAlignment = NSTextAlignmentCenter;
    collectiontitlelbl.font = [UIFont systemFontOfSize:25];
    [collectionview addSubview:collectiontitlelbl];
    
    UITableView *collectiontabl= [[UITableView alloc]initWithFrame:CGRectMake(0, collectiontitlelbl.frame.size.height +20, collectionW, collectionH - collectiontitlelbl.frame.size.height- 30) style:UITableViewStylePlain];
    [collectionview addSubview:collectiontabl];
    //collectiontabl.backgroundColor = [UIColor orangeColor];
    //collectiontabl.hidden = YES;
    self.collectiontable = collectiontabl;
    collectiontabl.delegate = self;
    collectiontabl.dataSource = self;
    
    
    UIButton *collectioncancel = [[UIButton alloc]initWithFrame:CGRectMake(kenscreenheight - collectionW, collectionview.frame.size.height + collectionview.frame.origin.y +10, collectionW, 40)];
    [collectioncancel setTitle:@"返回" forState:UIControlStateNormal];
    collectioncancel.backgroundColor = [UIColor redColor];
    collectioncancel.layer.cornerRadius = 10;
    [self.view addSubview:collectioncancel];
    [collectioncancel addTarget:self action:@selector(collectioncancelclick:) forControlEvents:UIControlEventTouchUpInside];
    self.collectioncancel = collectioncancel;
    
}

-(void)collectioncancelclick: (UIButton *)btn{
    [self.collectionbgview removeFromSuperview];
    [self.collectionview removeFromSuperview];
    [btn removeFromSuperview];
    
}


#pragma mark send按钮的点击事件==============
-(void)sendclick{
    if (self.mainarray) {
        
        for (NSMutableDictionary *dict in self.mainarray) {
            NSString *name = [dict objectForKey:@"mean"];
            NSLog(@"name = %@",name);
            [self.sendarray addObject:name];
        }
        NSLog(@"sendarray = %@",self.sendarray);
        if (self.sendarray) {
            //这一步要校验
            [self checkarray];
            self.sendarray = nil;
        }
    }
    
 
}

#pragma mark sendarray 的校验==============
-(void)checkarray{
    NSUInteger on = 0;
    NSUInteger off = 0;
    if (self.myPeripheral !=nil) {
        if (self.sendarray) {
            if ([self.sendarray.firstObject isEqualToString:@"systemstart"]&&[self.sendarray.lastObject isEqualToString:@"systemend"]) {
                for (NSString *item in self.sendarray) {
                    if ([item containsString:@"on"]) {
                        on++;
                    }
                    if ([item containsString:@"off"]) {
                        off++;
                    }
                }
                if (on == off) {
                    for (NSUInteger i = 0; i< self.mainarray.count; i++) {
                        NSString *str = [self.sendarray objectAtIndex:i];
                        NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
                        [self.myPeripheral writeValue:data forCharacteristic:self.myCharacteristic type:CBCharacteristicWriteWithoutResponse];
                        
                    }
                    
                    [self alertview:@"success" andmessage:@"success"];
                    [self writetolog:@"success"];
                    
                }else{
                    [self alertview:@"程序语法错误" andmessage:@"程序在包含打开小灯的同时要包含关闭小灯"];
                    [self writetolog:@"程序在包含打开某小灯的同时要包含关闭这个小灯"];
                }
            }else{
                [self alertview:@"程序结构错误" andmessage:@"一个程序应该包含在开始和结束内"];
                [self writetolog:@"一个程序应该包含在开始和结束内"];
            }
        }else{
            [self alertview:@"程序结构错误" andmessage:@"一个程序应该包含在开始和结束内"];
            [self writetolog:@"一个程序应该包含在开始和结束内"];
        }
    }else{
        [self alert:@"蓝牙未连接" andmessage:@"请先连接蓝牙"];
        
    }
    
}

#pragma mark sendarray 的校验的alertview==============
-(void)alertview: (NSString *)title andmessage:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    
    [alert addAction:sure];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 最主要的tv==============
-(void)createmaintv{
    
    CGFloat X = self.view.frame.size.height *0.3 +5;
    CGFloat Y =40;
    CGFloat W = self.view.frame.size.height - X- 200;
    CGFloat H = self.view.frame.size.width - Y - 150;
    
    UITableView *tv = [[UITableView alloc]initWithFrame:CGRectMake(X, Y +10 , W, H) ];
    [self.view addSubview:tv];
    tv.dataSource = self;
    tv.delegate = self;//代理数据源
    tv.separatorStyle = UITableViewCellSeparatorStyleNone;//去除掉tableview的分割线
    
    tv.layer.cornerRadius = 10;//圆角矩形
    
    //tv.backgroundColor =[UIColor colorWithWhite:1.0 alpha:0.7];
     tv.alpha = 0.7;
    
    self.maintv = tv;
    
    UIView *toptvview = [[UIView alloc]initWithFrame:CGRectMake(X, 5, W, 40)];
    toptvview.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    toptvview.layer.cornerRadius = 10;
    [self.view addSubview:toptvview];
 //   [self setviewalpha:toptvview];
    
    
    UILabel *toptvlbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, W, 40)];
    toptvlbl.text = @"程序运行区";
    toptvlbl.textAlignment = NSTextAlignmentCenter;
    toptvlbl.font = [UIFont systemFontOfSize:30];
    
    [toptvview addSubview:toptvlbl];
    [self.view sendSubviewToBack:tv];
    [self.view sendSubviewToBack:toptvlbl];
    [self.view sendSubviewToBack:toptvview];
    

}

#pragma mark tableView的动画 ====================
- (void)starAnimationWithTableView:(UITableView *)tableView {
    
    [TableViewAnimationKit springListAnimationWithTableView:tableView];
    
}


#pragma mark 最主要的tv的datasource方法==============

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    if (tableView == self.maintv) {
         return self.mainarray.count;
    }else if (tableView == self.collectiontable){
        
        NSUserDefaults *collect = [NSUserDefaults standardUserDefaults];
        
        NSLog(@"collect = %@",[collect objectForKey:@"collection"]);
        
        NSMutableArray *collectarray = [collect objectForKey:@"collection"];

        return collectarray.count;
    }else{
        return  self.bluearray.count;
    }
    
}


#pragma mark 最主要的tv的datasource方法 以及      长按模块==============
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.maintv) {
        optionals *model = [[optionals alloc ] initWithDict:self.mainarray[indexPath.row]];
        
        optionalsCell *cell = [optionalsCell optionalsCellWithTable:tableView];
        
        cell.optionals =model;
        
        NSMutableDictionary *dict2 = self.mainarray[indexPath.row];
        NSString *select = [dict2 objectForKey:@"name"];
        if (![select isEqualToString:@"开始"]) {
            if (![select isEqualToString:@"结束"]) {
                if (![self isEqual:@"结束循环"]) {
                    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellcongpress:)];
                    longpress.minimumPressDuration = 0.5;
                    [cell.contentView addGestureRecognizer:longpress];
                }
            }
            
        }
        
        return cell;

    }else if (tableView == self.collectiontable){
        
        NSUserDefaults *collect = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *collectionarray = [NSMutableArray array];
        
        collectionarray = [[collect objectForKey:@"collection"] mutableCopy];
        
        
        static NSString *cid= @"cid";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        }
        cell.textLabel.text = [[collectionarray objectAtIndex:indexPath.row] objectForKey:@"title"];
        
        
        return cell;
        
        
        
    }else{
        static NSString *cid = @"cid";
        
        bluetoothCell *cell = [tableView dequeueReusableCellWithIdentifier:cid];
        if (cell == nil) {
            cell = [[bluetoothCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
        }
        CBPeripheral *p = [self.bluearray objectAtIndex:indexPath.row];
        
        if (!p.name) {
            cell.bluelabel.text = @"未知";
            cell.layer.cornerRadius = 20;
        }else{
            cell.bluelabel.text = p.name;
            cell.layer.cornerRadius = 20;
        }
        cell.selectionStyle = UITableViewCellSeparatorStyleNone;
        return cell;
        
    }
    
   
}

#pragma mark 长按动作recognizer ===========================
-(void)cellcongpress:(UILongPressGestureRecognizer *)recognizer{
          CGPoint location = [recognizer locationInView:self.maintv];
    if (recognizer.state == UIGestureRecognizerStateBegan) {

        NSIndexPath *indexpath = [self.maintv indexPathForRowAtPoint:location];
        self.index = indexpath.row;
        NSMutableDictionary *dict2 = self.mainarray[indexpath.row];
        NSString *select = [dict2 objectForKey:@"name"];
        
       if ([select containsString:@"开"]){

            [self cellclickbtnaction:@"请选择你要控制的小灯" andmessage:@"\n\n\n\n"];
            
        }else if ([select containsString:@"关"]){
            
           
            [self cellclickbtnaction:@"请选择你要控制的小灯" andmessage:@"\n\n\n\n"];
            
        }else if ([select containsString:@"延迟"]){
         
            
            [self cellclickbtnaction:@"请选择你要延迟的时间" andmessage:@"\n\n\n\n"];
            
        }else if ([select containsString:@"循环"] && [select containsString:@"次"]){
            
            
            [self cellclickbtnaction:@"请选择你要循环的次数" andmessage:@"\n\n\n\n"];
            
        }
 
    }

}

#pragma mark 点击的tableviewcell的alertview===========
-(void)cellclickbtnaction:(NSString *)title andmessage:(NSString *)message{
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickerbtnclick];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:sure];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
  
    
    UIPickerView *cellpicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 40, 265, 100)];
    cellpicker.delegate = self;
    cellpicker.dataSource = self;
    [alert.view addSubview:cellpicker];
    self.picker = cellpicker;
    
    self.pickerds = @[@"1",@"2",@"3"];//先都设为123
}

#pragma mark 点击cell弹出的alert中的picker的代理和数据源方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.pickerds.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{

    return [self.pickerds objectAtIndex:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 40;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    self.pickerstr = [self.pickerds objectAtIndex:row];
    NSLog(@"pickerstr = %@",self.pickerstr);
}

#pragma mark  点击picker的按钮调用的方法=================
-(void)pickerbtnclick{
    NSDictionary *dict = self.mainarray[self.index];
    NSString *name = [dict objectForKey:@"name"];
    if ([name containsString:@"开"]) {
        
        [self replacearray:@"开" end:@"号"];
    }else if ([name containsString:@"关"]){
        
        [self replacearray:@"关" end:@"号"];
        
    }else if ([name containsString:@"延迟"]){
        
        [self replacearray:@"迟" end:@"秒"];
        
    }else if ([name containsString:@"循环"]){
        
        [self replacearray:@"环" end:@"次"];
    }
    
}

#pragma mark tableview返回行高的方法================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.maintv) {
           return 80;
    }else{
        return 68;
    }
    
}

#pragma mark 选中了某个tableviewcell========================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    //self.index = indexPath.row;
    if (tableView == self.maintv) {
        NSMutableDictionary *dict2 = self.mainarray[indexPath.row];
        NSString *select = [dict2 objectForKey:@"name"];
        NSLog(@"select = %@",select);
        
        [self showinright:select];
    }else if (tableView == self.collectiontable){
        
        NSUserDefaults *collect = [NSUserDefaults standardUserDefaults];
        
        NSMutableArray *collectarray = [[collect objectForKey:@"collection"] mutableCopy];
        
        self.mainarray = [[[collectarray objectAtIndex:indexPath.row] objectForKey:@"array"] mutableCopy];
        
        [self.maintv reloadData];
        [self starAnimationWithTableView:self.maintv];//开启动画
        
//        [self.optionstart addGestureRecognizer:_PanGestureRecognizer];
//        [self.optionend addGestureRecognizer:_stopPanGestureRecognizer];
        
        [self.collectionbgview removeFromSuperview];
        [self.collectionview removeFromSuperview];
        [self.collectioncancel removeFromSuperview];
        
    }else {
        NSMutableDictionary *dict2 = [self.adarray objectAtIndex:indexPath.row];
        
        int kCBAdvDataIsConnectable = [[dict2 objectForKey:@"kCBAdvDataIsConnectable"]intValue];
        NSLog(@"kCBAdvDataIsConnectable = %d",kCBAdvDataIsConnectable);
        if (kCBAdvDataIsConnectable == 0) {
            [self alert:@"连接错误" andmessage:@"抱歉，此蓝牙暂不可连接"];
        }else{
            [self.blueprogress showAnimated:YES];//在进行连接的时候显示动画 第二段动画开始
            
            [self.bluetoothManager connectPeripheral: [self.bluearray objectAtIndex:indexPath.row] options:nil];
        
       }
    
    }
   
}

#pragma mark 点击cell使得右边的信息栏发生改变
-(void)showinright:(NSString *)info{
    if ([info isEqualToString:@"开始"]) {
        self.rightinfotextview.text = @"这是开始模块，开始模块是一个程序最开始要运行的模块，一般一个程序还包括结束模块";
        [self writetolog:@"这是开始模块，开始模块是一个程序最开始要运行的模块，一般一个程序还包括结束模块"];
       // [self disablebtnandtext:@"开始"];
    }else if ([info isEqualToString:@"结束"]){
        self.rightinfotextview.text = @"这是结束模块，结束模块标着程序运行马上停止，所有的功能模块都应该写在结束模块上面";
          [self writetolog:@"这是结束模块，结束模块标着程序运行马上停止，所有的功能模块都应该写在结束模块上面"];
      //  [self disablebtnandtext:@"结束"];
    }else if ([info containsString:@"开"]){
         self.rightinfotextview.text = @"这是开灯模块，开灯模块控制蓝牙小灯的开启，默认开启一号小灯，可以在这个信息栏的上方选择其他小灯，如果程序包含一个开灯模块那么程序必须再包含一个关灯模块";
        [self writetolog:@"这是开灯模块，开灯模块控制蓝牙小灯的开启，默认开启一号小灯，可以在这个信息栏的上方选择其他小灯，如果程序包含一个开灯模块那么程序必须再包含一个关灯模块"];
     //   [self cellclickbtnaction:@"请选择你要控制的小灯" andmessage:@"\n\n\n\n"];
        
    }else if ([info containsString:@"关"]){
        self.rightinfotextview.text = @"这是关灯模块，关灯模块控制蓝牙小灯的关闭，默认关闭一号小灯，可以在这个信息栏的上方选择其他小灯，如果程序包含一个关灯模块那么程序必须再包含一个开灯模块";
        [self writetolog:@"这是关灯模块，关灯模块控制蓝牙小灯的关闭，默认关闭一号小灯，可以在这个信息栏的上方选择其他小灯，如果程序包含一个关灯模块那么程序必须再包含一个开灯模块"];
     //   [self cellclickbtnaction:@"请选择你要控制的小灯" andmessage:@"\n\n\n\n"];
        
    }else if ([info containsString:@"延迟"]){
        self.rightinfotextview.text = @"这是延迟模块，延迟模块可以延迟程序的执行，默认延迟一秒钟，可以在这个信息栏的上方更改延迟时间";
        [self writetolog:@"这是延迟模块，延迟模块可以延迟程序的执行，默认延迟一秒钟，可以在这个信息栏的上方更改延迟时间"];
      //  [self cellclickbtnaction:@"请选择你要延迟的时间" andmessage:@"\n\n\n\n"];
        
    }
 
}

#pragma mark   替换mainarray================
-(void)replacearray :(NSString *)start end:(NSString *)end{
    
//    NSLog(@"xxxxx");
//    NSLog(@"self.index = %ld",(long)self.index);
    
    NSDictionary *dict = self.mainarray[self.index];
    NSString *name = [dict objectForKey:@"name"];
    NSString *mean = [dict objectForKey:@"mean"];
    NSLog(@"name = %@",name);
    NSRange namestartRange = [name rangeOfString:start];
    NSRange nameendRange = [name rangeOfString:end];
    NSRange range = NSMakeRange(namestartRange.location
                                + namestartRange.length,
                                nameendRange.location
                                - namestartRange.location
                                - nameendRange.length);

    NSString *nameresult = [name substringWithRange:range];
    NSString *newname = [name stringByReplacingOccurrencesOfString:nameresult withString:self.pickerstr];
    NSLog(@"newname = %@",newname);
    
    
    NSString *changemean = [mean substringToIndex: mean.length - 1];
    NSString *newmean = [NSString stringWithFormat:@"%@%@",changemean,self.pickerstr];
    
    NSMutableDictionary *newdict = [[NSMutableDictionary alloc]init];
    [newdict setObject:newname forKey:@"name"];
    [newdict setObject:newmean forKey:@"mean"];
    NSLog(@"newdict = %@",newdict);
    [self.mainarray replaceObjectAtIndex:self.index withObject:newdict];
    [self.maintv reloadData];
    [self starAnimationWithTableView:_maintv];
}



#pragma mark  commitEditingStyle删除功能
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (tableView == self.maintv) {
            [self.mainarray removeObjectAtIndex: indexPath.row];
            [self.maintv deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath]
                               withRowAnimation:UITableViewRowAnimationFade];
            
            
            for (NSMutableDictionary *dict in self.mainarray) {

                NSString *name = [dict objectForKey:@"name"];
                NSLog(@"name = %@",name);

                if (![self.delnamearray containsObject:name]) {
                    [self.delnamearray addObject:name];
                }
            }
            NSLog(@"self.delname = %@",_delnamearray);
            BOOL startisbool = [self.delnamearray containsObject:@"开始"];
            if (startisbool == 0) {
                NSLog(@"开始键激活");
                // self.optionstart.enabled = YES;
                [self.optionstart addGestureRecognizer:_PanGestureRecognizer];
            }
            BOOL endisbool = [self.delnamearray containsObject:@"结束"];
            if (endisbool == 0) {
                //self.optionend.enabled = YES;
                [self.optionend addGestureRecognizer:_stopPanGestureRecognizer];
            }

            self.delnamearray = nil;
        }else if (tableView == self.collectiontable){
            NSLog(@"delete collection");
            
            
            NSUserDefaults *collect = [NSUserDefaults standardUserDefaults];
           self.collectionarray = [collect objectForKey:@"collection"];
            
            NSMutableArray *collectarray2 = [NSMutableArray array];
            collectarray2 = [self.collectionarray mutableCopy];
            [collectarray2 removeObjectAtIndex: indexPath.row];
            
            _collectionarray = collectarray2;
            
            [collect removeObjectForKey:@"collection"];
            [collect setObject:collectarray2 forKey:@"collection"];
            
            [self.collectiontable reloadData];
        }
       
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _bluetable) {
        return NO;
    }else{
         return YES;
    }
}
//定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
//修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
//设置进入编辑状态时，Cell不会缩进
- (BOOL)tableView: (UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

//开启向左滑动显示删除功能
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    if (tableView == self.bluetable) {
        return NO;
    }else{
        return YES;
    }
 
}


#pragma mark 监听蓝牙状态的listener===================
//-(void)listenbluetoothstate{
//
//   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi1:) name:@"blue" object:nil];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tongzhi2:) name:@"connect" object:nil];
//
//}
//#pragma mark 监听蓝牙状态的方法===================
//-(void)tongzhi1:(NSNotification *)text{
//    NSLog(@"text = %@",text.userInfo);
//    NSString *str = [text.userInfo objectForKey:@"accident"];
//    [self writetolog:str];
//    self.righttoplabel.text = str;
//}
//
//-(void)tongzhi2:(NSNotification *)text{
//    NSLog(@"text2 = %@",text.userInfo);
//    NSString *str = [text.userInfo objectForKey:@"connectstate"];
//    [self writetolog:str];
//    self.righttoplabel.text = str;
//}

#pragma mark 写入到信息区的方法===================
-(void)writetolog: (NSString *)info{
    
     NSDate *nowdate = [NSDate date];//获取当前系统时间
    //创建一个日期时间的格式化器
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    //设置格式
    formatter.dateFormat = @" yyyy-MM-dd HH:mm:ss";
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8*3600]];
    
    NSString *time = [formatter stringFromDate:nowdate];
    
    self.infotextview.text = [NSString stringWithFormat:@"%@\r\n%@    %@" ,self.infotextview.text,time,info];
    
    [self.infotextview scrollRangeToVisible:NSMakeRange(self.infotextview.text.length, 1)];//infotextview在有新的内容的时候往下滑
}


#pragma mark alertcontroller ================
-(void)alert :(NSString *)title andmessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *shure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:shure];

    [self presentViewController:alert animated:YES completion:nil];

}

-(void)jumpto:(NSString *)jumpurl{
    
    NSURL *url1 = [NSURL URLWithString:jumpurl];
    // iOS10也可以使用url2访问，不过使用url1更好一些，可具体根据业务需求自行选择
    NSURL *url2 = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 11.0, *)) {
        if ([[UIApplication sharedApplication] canOpenURL:url2]){
            [[UIApplication sharedApplication] openURL:url2 options:@{} completionHandler:nil];
        }
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:url1]){
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url1 options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url1];
            }
        }
    }

}
#pragma mark bluetoothManager的第一个代理方法  用来检测蓝牙是否开启 ================
//中心服务器状态更新后
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            NSLog(@"BLE已打开.");
            //扫描外围设备
            //        [central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
          
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"此设备不支持BLE或未打开蓝牙功能，无法作为外围设备.");
              [self jumpto:UIApplicationOpenSettingsURLString];
            break;
    }
}

#pragma mark  发现外围设备====================
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"发现外围设备 = %@",peripheral.services);
    

    
    if (peripheral.name) {
        if (![self.bluearray containsObject:peripheral]) {
            [self.bluearray addObject:peripheral];
            [self.adarray addObject:advertisementData];//两个数组装载的是不同的数组
        }
    }

    
    [self performSelector:@selector(stopscan) withObject:nil afterDelay:2.0f];//实验
    
    
//    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
//  //  CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
//    for (CBService *service in peripheral.services) {
//        if([service.UUID isEqual:serviceUUID]){
//
//            [self.bluetoothManager connectPeripheral:peripheral options:nil];
//
//        }
//    }
    
    
    
}

#pragma mark  发现外围设备后应该停止扫描====================
-(void)stopscan{
    
    //停止扫描
    [self.bluetoothManager stopScan];
    
   // self.bluetv.hidden = NO;
    //NSLog(@"bluearray = %@",self.bluearray);
    
    [self.bluetable reloadData];//重新载入数据
    
    self.bluetable.hidden = NO;
    
    [self starAnimationWithTableView:self.bluetable];//给tableview的生成加一个动画
    
    [self.blueprogress hideAnimated:YES];
    
}

#pragma mark ==========检测是否连接完成=======
//连接成功
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"连接外围设备成功!");
    //设置外围设备的代理为当前视图控制器
    peripheral.delegate=self;
    //外围设备开始寻找服务
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    
}

//连接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"连接外围设备失败!");
}

#pragma mark - CBPeripheral 代理方法
//外围设备寻找到服务后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"已发现可用服务...");
    if(error){
        NSLog(@"外围设备寻找服务过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    //遍历查找到的服务
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    for (CBService *service in peripheral.services) {
        if([service.UUID isEqual:serviceUUID]){
            //外围设备查找指定服务中的特征
            [peripheral discoverCharacteristics:@[characteristicUUID] forService:service];
        }
    }
}

//外围设备寻找到特征后
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"已发现可用特征...");
    if (error) {
        NSLog(@"外围设备寻找特征过程中发生错误，错误信息：%@",error.localizedDescription);
    }
    //遍历服务中的特征
    CBUUID *serviceUUID=[CBUUID UUIDWithString:kServiceUUID];
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    if ([service.UUID isEqual:serviceUUID]) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:characteristicUUID]) {
                //情景一：通知
                /*找到特征后设置外围设备为已通知状态（订阅特征）：
                 *1.调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                 *2.调用此方法会触发外围设备的订阅代理方法
                 */
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                
                self.myPeripheral = peripheral;
                self.myCharacteristic = characteristic;//为全局的特征和服务赋值，可以在穿数据的时候使用
                
            }
        }
    }
}

//特征值被更新后
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"收到特征更新通知...");
    
    [self cancelaction];
    
    self.righttoplabel.text= @"蓝牙已连接";
    self.bluearray = nil;
    self.adarray = nil;
    
    [self writetolog:@"蓝牙已连接"];
    
    [self.blueprogress hideAnimated:YES];//关闭第二段动画
    
    if (error) {
        NSLog(@"更新通知状态时发生错误，错误信息：%@",error.localizedDescription);
    }
    
    //给特征值设置新的值
    CBUUID *characteristicUUID=[CBUUID UUIDWithString:kCharacteristicUUID];
    if ([characteristic.UUID isEqual:characteristicUUID]) {
        if (characteristic.isNotifying) {
            if (characteristic.properties==CBCharacteristicPropertyNotify) {
                NSLog(@"已订阅特征通知.");
                return;
            }else if (characteristic.properties ==CBCharacteristicPropertyRead) {
                //从外围设备读取新值,调用此方法会触发代理方法：-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
                [peripheral readValueForCharacteristic:characteristic];
            }
            
        }else{
            NSLog(@"停止已停止.");
            
            //取消连接
            [self.bluetoothManager cancelPeripheralConnection:peripheral];
        }
    }
}

#pragma mark 连接掉了之后发布一个通知给vc后自动重连
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"已经断开蓝牙");
    
     self.righttoplabel.text= @"蓝牙已断开 正在努力重连中。。。。";
    
    [self writetolog: @"蓝牙已断开 正在努力重连中。。。。"];
    
    [self.bluetoothManager connectPeripheral:peripheral options:nil];
    //尝试重新连接
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
