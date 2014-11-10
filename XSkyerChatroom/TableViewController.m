//
//  TableViewController.m
//  XSkyerChatroom
//
//  Created by Yin Bo on 14/10/29.
//  Copyright (c) 2014年 <Pantasia Indie>. All rights reserved.
//

#import "TableViewController.h"
#import "SettingViewController.h"
#import "ChatTableViewCell.h"
#import "Theme.h"
#import "BlockedUser.h"
@interface TableViewController ()



@property (strong,nonatomic) NSMutableArray *chats;


@property (nonatomic,strong) ChatboxPopOverController *chatboxVC;

@property (nonatomic,strong) UIView *customView;

@property (nonatomic) NSInteger page;

@property (nonatomic) BOOL  isRefreshed;
@property  (nonatomic) BOOL isLoaded;
@property  (nonatomic) BOOL isChatShowed;

@property (strong,nonatomic) NSString  *chatContents;
@property (strong,nonatomic) NSString *chosenChatID;

@property  (strong,nonatomic) Theme *theme;

@property   (nonatomic) CGSize textSize;

@property   (nonatomic,strong) NSMutableArray *blockedUsers;
@property   (nonatomic) BOOL isBlockedUserRefreshed;
@property  (nonatomic,weak ) ChatTableViewCell *touchedCell;

//Private
@property (nonatomic,weak) NSMutableArray *pmArr;//Store the Private Message, will pass to Private message page


@end


@implementation TableViewController

@synthesize pullTableView;

- (void)setAccess:(AccessControl *)access{
    
    _access = access;
    //NSLog(@"Set Access");
}

- (void) loginForUser: (NSString *) userName withPassword :(NSString *) password{
    
    
    self.access = [[AccessControl alloc]initWithUser:userName password:password];
    
    [self login];
}

- (void) logout{
    NSURL *url1 = [NSURL URLWithString:@"http://www.xbox-skyer.com/login.php"];//Login operation
    NSMutableURLRequest *requestLogout= [[NSMutableURLRequest alloc]initWithURL:url1 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [requestLogout setHTTPMethod:@"POST"];//Set the request method to "Post"
    NSString *str1 = [self.param generateLogoutWithToken:self.access.token];//设置参数
    NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
    [requestLogout setHTTPBody:data1];
     [NSURLConnection sendSynchronousRequest:requestLogout returningResponse:nil error:nil];

    //Logout need to clear the user/pwd stored in keychain
    self.dataTask = nil;
    self.access.hasLogin = NO;
    self.access.isSessionTimeout = NO;
    self.access.token = nil;
    [self.thisSession invalidateAndCancel];
    self.thisSession = nil;
    self.chats=nil;
    requestLogout = nil;
    data1 = nil;
    requestLogout = nil;
    NSUserDefaults *accountDefaults = [NSUserDefaults standardUserDefaults];
    [accountDefaults removeObjectForKey:USER_DEFAULTS_ACCOUNT];
    [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
    
    
}

- (void) login {
    if(self.access){
        NSURL *url1 = [NSURL URLWithString:@"http://www.xbox-skyer.com/login.php"];
        NSMutableURLRequest *requestLogin = [[NSMutableURLRequest alloc]initWithURL:url1 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [requestLogin setHTTPMethod:@"POST"];//Set request method to POST
        NSString *str1 = [self.param generateLoginWithUser:self.access.userName withPassword:self.access.password];
        NSData *data1 = [str1 dataUsingEncoding:NSUTF8StringEncoding];
        [requestLogin setHTTPBody:data1];
        NSData *received1 = [NSURLConnection sendSynchronousRequest:requestLogin returningResponse:nil error:nil];
       // NSString *strResult1 = [[NSString alloc]initWithData:received1 encoding:NSUTF8StringEncoding];

        //NSLog(@"%@",strResult1);

        NSString *result = [self.parse parseHTMLDataForAccess:received1];
        if([result isEqualToString:ACCSEE_LOGIN_FAILED]){
            self.access.isSessionTimeout = NO;
            self.access.hasLogin = NO;
            self.access.token=@"错误的用户名或密码.您已经超出了登录失败限制次数！请等待 15 分钟后重试.";
        }else if([result isEqualToString:ACCSEE_LOGIN_CORRUPT]){
            self.access.isSessionTimeout = YES;
            self.access.hasLogin = NO;
            [self login];
        }else{
            NSArray *arr = [result componentsSeparatedByString:@"|"];
            if([arr count]>1){
//                if([ACCSEE_LOGIN_RETRY_TOO_MANY isEqualToString:arr[0]]){
//                    
//                }else if([ACCSEE_LOGIN_AUTH_FAILED isEqualToString:arr[0]]){
//                    
//                }
                self.access.token = arr[1];
                self.access.hasLogin = NO;
                self.access.isSessionTimeout = NO;
            }else{
                self.access.isSessionTimeout = NO;
                self.access.hasLogin = YES;
                self.access.token = result;
            }

        }
        
    }
}


-(PostParameter *)param{
    if(!_param){
        _param = [[PostParameter alloc]init];
    }
    return _param;
}

#pragma mark - Session
-(NSURLSession *)thisSession
{
    if(!_thisSession ){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _thisSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        //[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
    }
    return _thisSession;
}



- (NSArray *)parseData
{
    NSArray *result = [[NSArray alloc]init];
    if ([self.target isEqualToString:HTML_REQUEST_TARGET_CURRENT]) {
        result = [self.parse parseXMLDataForCurrentChat:self.data];
        
    }else if([self.target isEqualToString:HTML_REQUEST_TARGET_HISTORY]){
        result = [self.parse parseHTMLDataForHistory:self.data];
    }else if([self.target isEqualToString:HTML_REQUEST_TARGET_PROFILE]){
        result = [self.parse parseHTMLDataForBlockedUsers:self.data];
    }else if([self.target isEqualToString:HTML_REQUEST_TARGET_PRIVATE]){
        result = nil;
    }
    
    return result;

}

#pragma mark - Generate the data
- (ParseChat *)parse
{
    if(!_parse){
        _parse = [[ParseChat alloc]init];
    }
    return _parse;
}
-(NSMutableArray *)chats{
    if(!_chats){
        _chats = [[NSMutableArray alloc]initWithCapacity:50];
    }
    return _chats;
}




//Shall rerite for delegate
- (NSMutableURLRequest *) requestWithURL:(NSURL *)URL forType:(NSString *) type
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.thisUrl];
    if([type isEqualToString:HTML_REQUEST_TYPE_REFRESH]){
        if([self.target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
            //To get curreny chat, use post
            [request setHTTPMethod:@"POST"];
            
            NSString *str = [self.param  generateRefreshWithToken: self.access.token];//Set parameter
            NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:data];
        }else if([self.target isEqualToString:HTML_REQUEST_TARGET_HISTORY]){
            //do nothing
        }
    }else if([type isEqualToString:HTML_REQUEST_TYPE_LOGIN]){
        
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateLoginWithUser:self.access.userName withPassword:self.access.password];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_LOGOUT]){
        
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateLogoutWithToken:self.access.token];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_CHAT]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateChatWithToken:self.access.token withChat:self.chatContents];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_EDIT]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateEditWithToken: self.access.token withChat:self.chatContents forChatID: self.chosenChatID];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_DELETE]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateDeleteWithToken:self.access.token forChatID:self.chosenChatID];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
        
    }else if([type isEqualToString:HTML_REQUEST_TYPE_BLOCKED_GET]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateGetBlockedListWithToken:self.access.token];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
    }else if([type isEqualToString:HTML_REQUEST_TYPE_REPORT]){
        [request setHTTPMethod:@"POST"];
        //generate the message
        
        NSString *str = [self.param generatePMToUser:@"dogcom" withContent:[self generateReportContent] withToken:self.access.token];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];

    }
    return request;
}

-(NSString *) generateReportContent{
    ChatData *chat = self.touchedCell.chat;
    AccessControl *accessS = self.access;
    
    NSString *reportS = [NSString stringWithFormat:@"[Date:%@(如没有日期则为当日）][被举报账户:%@][举报内容:\"%@\"][举报人:%@]",chat.dateString,chat.speaker,chat.content,accessS.userName];
    
    return reportS;
    
}

//Overload, for Blacklist operation only
- (NSMutableURLRequest *) requestWithURL:(NSURL *)URL forType:(NSString *) type withUserId: (NSString *) userId
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.thisUrl];
    if([type isEqualToString:HTML_REQUEST_TYPE_BLOCKED_ADD]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateAddBlockedUserWithToken:self.access.token forUserId:userId];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
    }else if([type isEqualToString:HTML_REQUEST_TYPE_BLOCKED_DELETE]){
        [request setHTTPMethod:@"POST"];
        NSString *str = [self.param generateRemoveBlockedUserWithToken:self.access.token forUserId:userId];//Set parameter
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:data];
    }
    
    return request;
}



-(void) setURLwith: (NSString *) target forPage :(NSString *) page
{
    NSMutableString *url = nil;
    if ([target isEqualToString:HTML_REQUEST_TARGET_HISTORY]) {
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/chat.php?do=view_archives&page="];
        [url appendString:page];
        [url appendString:@"&styleid=47"];
    }else if([target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/mgc_cb_evo_ajax.php"];
    }else if([target isEqualToString:HTML_REQUEST_TARGET_LOGIN]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/login.php"];
    }else if([target isEqualToString:HTML_REQUEST_TARGET_PROFILE]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/profile.php"];

    }else if([target isEqualToString:HTML_REQUEST_TARGET_PRIVATE]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/private.php?do=newpm"];
    }else if([target isEqualToString:HTML_REQUEST_TARGET_PRIVATE]){
        url = [[NSMutableString alloc] initWithString:@"http://www.xbox-skyer.com/private.php?folderid=0&styleid=47"];
    }
    
    self.thisUrl = [[NSURL alloc] initWithString:url];
    self.target = target;
}


-(void) setURLwith: (NSString *) target {
    [self setURLwith:target forPage:@"1"];
}
#pragma mark - View Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.pullTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.pullTableView.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];


    //init the setup for pop over controller
    

    self.chatboxVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatboxPopOverController"];
    
    [self setChatboxView];
    
    self.chatboxVC.chatbox.delegate = self;
    //Add the customView to the current view
    
    
    self.pullTableView.pullArrowImage = [UIImage imageNamed:@"blueArrow"];
    self.pullTableView.pullBackgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    //self.pullTableView.pullTextColor = [UIColor grayColor];

    __weak TableViewController *weakSelf = self;
    self.pullTableView.pullDelegate = weakSelf;
    
    self.isChatShowed = NO;
    self.page = 2;
    
    //Set the default Theme
    
    [self generateTheme];
    
    //init the blocked user list

}

- (void) initBlockedUserList{
    [self startRequestDataForBlockedUsersFrom];
    

}
- (void) filterBlockedChats{
    if([self.chats count]>0
       && self.blockedUsers
       && [self.blockedUsers count]>0){
        
        NSMutableArray *tempArr = [[NSMutableArray alloc]initWithCapacity:[ self.chats count]];
        
        for (ChatData *chat in self.chats) {
            BOOL blocked = NO;
            for (BlockedUser *blcoked in self.blockedUsers) {
                if([blcoked.userID isEqualToString:chat.userId]){
                    //Blocked
                    blocked = YES;
                    break;
                }
                
            }
            if(!blocked){
                [tempArr addObject: chat];
            }
        }
         self.chats = nil;
         self.chats = tempArr;
        tempArr = nil;
        self.isBlockedUserRefreshed = NO;
    }
}
- (void) generateTheme{
    self.theme = [[Theme alloc]init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initBlockedUserList];

    self.chats = nil;
    [super viewWillAppear:animated];
    
    //Check if has logged in
    
    if (!self.access || !self.access.hasLogin) {
        //Navigate to Setting page
        [self performSegueWithIdentifier:@"LogoutSegue" sender:self];
        return;
    }
    if(!self.pullTableView.pullTableIsLoadingMore) {
        self.pullTableView.pullTableIsLoadingMore = YES;
        [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:0.0f];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    self.pullTableView.pullTableIsLoadingMore = NO;

}

- (void)viewDidUnload
{
    [self setPullTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma private message


//Get private messages listed

-(void) getPrivateMessages{
    [self startRequestDataFrom:HTML_REQUEST_TARGET_HISTORY forPage:[NSString stringWithFormat:@"%lu",(long)self.page ] forType:HTML_REQUEST_TYPE_REFRESH];

}


#pragma mark - PullTableViewDelegate

- (void)pullTableViewDidTriggerRefresh:(PullTableView *)pullTableView
{
    [self performSelector:@selector(refreshTable) withObject:nil afterDelay:1.0f];
    
//#warning add the refresh the private messages here
//    Query
//    
//    1. http://www.xbox-skyer.com/private.php?folderid=0&styleid=47
//    2. PUT
//    3. do=procee&securitytoken=%@
//    4. First 50 record only // maybe only retrieve the latest 50
//    
//        Delete
//        1.http://www.xbox-skyer.com/private.php?folderid=0
//        2.Post
//        3.securitytoken=1415524351-b6a7a32eafde90b89edda42be6c53939cc72b57d&do=managepm&s=&folderid=0&dowhat=delete&pmid=627079&pm[627079]=
//            
//            detail
//            securitytoken=1415524351-b6a7a32eafde90b89edda42be6c53939cc72b57d&do=showpm&pmid=628098
//            
//    New
//            exists
//    Report
//             securitytoken=&private.php?do=report&amp;pmid=628098
//            
//            reply
//    securitytoken=&private.php?do=newpm&amp;pmid=628098
//    
//    Private message page, just the simple table view list 
}

- (void)pullTableViewDidTriggerLoadMore:(PullTableView *)pullTableView
{
    [self performSelector:@selector(loadMoreDataToTable) withObject:nil afterDelay:1.0f];
//#warning add the refresh the private messages here

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) refreshTable
{
    /*
     
     Code to actually refresh goes here.
     
     */
    [self startRequestDataFrom:HTML_REQUEST_TARGET_HISTORY forPage:[NSString stringWithFormat:@"%lu",(long)self.page ] forType:HTML_REQUEST_TYPE_REFRESH];

    if (!self.tempData || [self.tempData length] ==0) {
        [self startRequestDataFrom:HTML_REQUEST_TARGET_HISTORY forPage:[NSString stringWithFormat:@"%lu",(long)self.page ] forType:HTML_REQUEST_TYPE_REFRESH];

    }
    self.pullTableView.pullLastRefreshDate = [NSDate date];
    self.pullTableView.pullTableIsRefreshing = NO;
    
    self.isRefreshed = YES;
    self.isLoaded = NO;
    self.page++;

}

- (void) loadMoreDataToTable
{
    /*
     
     Code to actually load more data goes here.
     
     */
    
    
    [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
    if (!self.chats || [self.chats count] ==0) {
        self.access.isSessionTimeout = YES;
        [self login];
        [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
        
    }

    self.isRefreshed = NO;
    self.isLoaded = YES;
    self.pullTableView.pullTableIsLoadingMore = NO;
    
    self.isBlockedUserRefreshed = NO;
}


#define HEIGHT_PATCH_4_0_INCH 35
#define HEIGHT_PATCH_9_7_INCH 420
#define HEIGHT_PATCH_7_9_INCH 330
#define HEIGHT_PATCH_3_5_INCH 0
#define HEIGHT_PATCH_4_7_INCH 120
#define HEIGHT_PATCH_5_5_INCH 180



- (void) keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    CGRect newTextViewFrame = self.view.bounds;
    CGFloat keyboardTop =  keyboardSize.height;
    CGRect keyboardRect = [value CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

    if (newTextViewFrame.size.height == 1024) {
        //Ipad
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_9_7_INCH;
    }else if (newTextViewFrame.size.height == 480) {
        //Iphone 4/4s
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y-40+HEIGHT_PATCH_3_5_INCH;
    }else if (newTextViewFrame.size.height == 568) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_4_0_INCH;
    }else if (newTextViewFrame.size.height == 667) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_4_7_INCH;
    }else if (newTextViewFrame.size.height == 736) {
        //Iphone 5/5s, ipod touch
        newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y+HEIGHT_PATCH_5_5_INCH;
    }
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = newTextViewFrame;
    [UIView commitAnimations];

}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    
    NSValue *animationDurationValue = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = self.view.bounds;
    
    [UIView commitAnimations];

    
}

- (void) setChatboxView{
    self.customView = self.chatboxVC.view; //<- change to where you want it to show.
    
    //Set the customView properties
    self.customView.alpha = 0.0;
    self.customView.layer.cornerRadius = 5;
    self.customView.layer.borderWidth = 1.5f;
    self.customView.layer.masksToBounds = YES;
    
    self.customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    CGRect viewFrame = self.view.frame;
    [self.customView setFrame:CGRectMake(0, CGRectGetHeight(viewFrame)-50-44-10, CGRectGetWidth(viewFrame), 50)];

}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        //NSLog(@"Ready to speak: %@",textView.text);
        self.chatContents = textView.text;
        [self sendMessage];
        self.isChatShowed = NO;
        textView.text = @"";

        return NO;
    }
    return YES;
}


- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    NSDictionary *userInfo = [notification userInfo];
    
     //Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
     //Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = 216;
    //NSLog(@"%f",keyboardTop);
    CGRect newTextViewFrame = self.view.bounds;
    newTextViewFrame.size.height = keyboardTop - self.view.bounds.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = newTextViewFrame;
    [UIView commitAnimations];
}

- (IBAction)showChat:(id)sender {
    //Display the customView with animation

    if(!self.isChatShowed){
        [self.customView removeFromSuperview];
        [self setChatboxView];
        [self.view.superview addSubview:self.customView];
        [self.view.superview bringSubviewToFront: self.customView];
        
        __weak TableViewController *weakSelf = self;

        [UIView animateWithDuration:0.4 animations:^{
            [self.customView setAlpha:1.0];
        } completion:^(BOOL finished) {
            weakSelf.isChatShowed = YES;

        }];
    
    }else{
        __weak TableViewController *weakSelf = self;
        [UIView animateWithDuration:0.4 animations:^{
            [self.customView setAlpha:0.0];
        } completion:^(BOOL finished) {
            weakSelf.isChatShowed = NO;
        [weakSelf.customView removeFromSuperview];
        }];

        

    }
    
    
    

}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    self.customView.frame = self.view.bounds;
    
    [UIView commitAnimations];
}










- (void)reloadView{
    [self filterBlockedChats];

    [self.pullTableView reloadData];
    if (self.isRefreshed) {
        [self appearAtTop];
    }else{
        [self appearAtBottom];
    }

    if (self.access.hasLogin) {
        self.navigationController.toolbarHidden = NO;
    }else{
        self.navigationController.toolbarHidden = YES;
    }

}

- (void) startRequestDataFrom: (NSString *) target forType: (NSString *) type{
    [self startRequestDataFrom:target forPage:@"" forType:type];
}



- (void) startRequestDataFrom: (NSString *) target forPage : (NSString *) page forType: (NSString *) type{
    [self setURLwith:target forPage:page];

    __weak TableViewController *weakSelf = self;

    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:type] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"response.expectedContentLength %lld", response.expectedContentLength);
         weakSelf.tempData = [[NSMutableData alloc]init];
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
            
            [weakSelf.tempData appendBytes:bytes length:byteRange.length];
        }];
        weakSelf.data = weakSelf.tempData;
        if ([target isEqualToString:HTML_REQUEST_TARGET_HISTORY]) {
            [weakSelf insertCells:[weakSelf parseData]];
        }else if([target isEqualToString:HTML_REQUEST_TARGET_CURRENT]){
            [weakSelf appendCells:[weakSelf parseData]];
        }else if([target isEqualToString:HTML_REQUEST_TARGET_PROFILE]){
            [weakSelf refreshBlockedUserList:[weakSelf parseData]];
        }
        
        [weakSelf.tempData setLength:0];
        weakSelf.data = nil;

        [weakSelf reloadView];
        
    }];
    [self.dataTask resume];
}

- (void) startRequestDataForBlockedUsersFrom{
    NSURL *url2 = [NSURL URLWithString:@"http://www.xbox-skyer.com/profile.php"];
    NSMutableURLRequest *requestLogin2 = [[NSMutableURLRequest alloc]initWithURL:url2 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [requestLogin2 setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    NSString *str2 = [NSString stringWithFormat: @"do=ignorelist&styleid=47&securitytoken=%@",self.access.token];
    NSData *data2 = [str2 dataUsingEncoding:NSUTF8StringEncoding];
    [requestLogin2 setHTTPBody:data2];
    NSData *received2 = [NSURLConnection sendSynchronousRequest:requestLogin2 returningResponse:nil error:nil];
    [self refreshBlockedUserList:[ self.parse parseHTMLDataForBlockedUsers:received2]];

    }

- (void) refreshBlockedUserList:(NSArray *) blockedUsers{
    if(!self.blockedUsers || [self.blockedUsers count] ==0){
        self.blockedUsers = [NSMutableArray arrayWithArray: blockedUsers];
    }else if(!blockedUsers || [blockedUsers count]== 0){
        self.blockedUsers = nil;
        self.blockedUsers = [[NSMutableArray alloc]init];
    }else{
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        //Find removed
        for (BlockedUser *currentBlockedUser in self.blockedUsers) {
            
            BOOL exists = NO;
            for ( BlockedUser *newBlockedUser in blockedUsers) {
                if ([newBlockedUser isEqual:currentBlockedUser]) {
                    //Do nothing, found a match
                    exists = YES;
                    break;
                }else{
                    
                }
            }
            
            if (exists) {
                [tempArr addObject:currentBlockedUser];
            }
        }

        //Find new
        for (BlockedUser *newBlockedUser in blockedUsers) {

            BOOL exists = NO;
            for ( BlockedUser *currentBlockedUser in self.blockedUsers) {
                if ([newBlockedUser isEqual:currentBlockedUser]) {
                    //Do nothing, found a match
                    exists = YES;
                    break;
                }else{
                    
                }
            }
            
            if (!exists) {
                [tempArr addObject:newBlockedUser];
            }
        }
        
        self.blockedUsers = nil;
        self.blockedUsers = tempArr;
    }
    self.isBlockedUserRefreshed = YES;
}


- (void) appendCells:(NSArray *) result{
    
    if(!self.chats || [self.chats count]==0){
        //Append directly when initialize
        [self.chats addObjectsFromArray:result];
    
    }else{
        //Compare the chatid, append the newly added chats
        ChatData *latestChat = [self.chats lastObject];
        
        ChatData *newLastChat = [result lastObject];
        if(![newLastChat newerThan:latestChat]){
            return;//no updates
        }
        for (ChatData *chat in result) {
            if([chat newerThan:latestChat]){
                [self.chats addObject:chat];
            }
        }
    }
}

- (void) insertCells:(NSArray *) result{
    if(!self.chats || [self.chats count]==0){
        //Append directly when initialize
        [self.chats addObjectsFromArray:[self parseData]];
    }else{
        //Compare the chatid, append the newly added chats
        ChatData *oldestCurrentChat = [self.chats firstObject];
        
        
        //Reverse enmueator
        NSEnumerator *enumerator = [result reverseObjectEnumerator];
        ChatData *chat;
        while ((chat = [enumerator nextObject]) != nil) {
            if([chat olderThan:oldestCurrentChat]){
                [self.chats insertObject: chat atIndex:0];
                oldestCurrentChat = [self.chats firstObject];
            }
        }
    }

}
- (void) blockUser: (NSString *) userID : (NSString*) userM{
    if (userID) {
        
        __weak TableViewController *weakSelf = self;
        [self setURLwith:HTML_REQUEST_TARGET_PROFILE];
        
        self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_BLOCKED_ADD withUserId:userID] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            
           // NSString *str1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            //NSLog(@"%@",str1);
            
            BlockedUser *blockedUser = [[BlockedUser alloc]initWithUserId:userID withUserName:userM];
            [weakSelf.blockedUsers addObject:blockedUser];
            weakSelf.isBlockedUserRefreshed = YES;
            [weakSelf performSelector:@selector(delayMethod) withObject:nil afterDelay:0.6f];

            [weakSelf reloadView];
        }];
        [self.dataTask resume];
        
        
    }
    
}

- (void) deleteChat{
    
    __weak TableViewController *weakSelf = self;
    
    [self setURLwith:HTML_REQUEST_TARGET_CURRENT];
    ChatTableViewCell *cell = self.touchedCell;
    self.chosenChatID = cell.chat.chatId;
    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_DELETE] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        //Remove the chat by chat id
        for (ChatData *chat in self.chats) {
            if ([weakSelf.chosenChatID isEqualToString:chat.chatId]) {
                [self.chats removeObject:chat];
                break;
            }
        }
        
        [weakSelf performSelector:@selector(delayMethod) withObject:nil afterDelay:0.6f];
        
        [weakSelf reloadView];
    }];
    [self.dataTask resume];
}

- (void) alertWithMessage: (NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

//Can change to Send PM
- (void) reportChat{
    
    __weak TableViewController *weakSelf = self;
    
    [self setURLwith:HTML_REQUEST_TARGET_PRIVATE];
    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_REPORT] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        [weakSelf performSelector:@selector(delayMethod) withObject:nil afterDelay:0.6f];
        
        //Send alert
        [self alertWithMessage:@"举报已经发送至管理员，管理员核实后将会及时处理，谢谢您为维持一个良好环境的努力"];
        
    }];
    [self.dataTask resume];
}




- (void) sendMessage{
    [self setURLwith:HTML_REQUEST_TARGET_CURRENT];
    __weak TableViewController *weakSelf = self;

    self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_CHAT] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        //NSLog(@"%lld", response.expectedContentLength);
        weakSelf.tempData = [[NSMutableData alloc]init];
        
        [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
         
        [weakSelf.tempData appendBytes:bytes length:byteRange.length];  }];
        weakSelf.data = weakSelf.tempData;
        if ([weakSelf.tempData length] != 112) {
            self.access.isSessionTimeout = YES;
            
        }
        
    }];
    [self.dataTask resume];

    
    if(self.access.isSessionTimeout){
        [self login];
        self.dataTask = [self.thisSession dataTaskWithRequest:[self requestWithURL:self.thisUrl forType:HTML_REQUEST_TYPE_CHAT] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         
            
        }];
        [self.dataTask resume];

    }

    [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.6f];

}
- (void)delayMethod {
    [self startRequestDataFrom:HTML_REQUEST_TARGET_CURRENT forType:HTML_REQUEST_TYPE_REFRESH];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self logout];
}

#pragma mark - Table view data source

-(CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    textRect.size  = CGSizeMake(textRect.size.width, textRect.size.height);
    //Contains both width & height ... Needed: The height
    return textRect.size;
}


#pragma mark Table view methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.chats count];
}


- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if (action == @selector(copy:)) {
        
        [UIPasteboard generalPasteboard].string = [self.chats  objectAtIndex:indexPath.row];
        
    }
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"chat";
    ChatTableViewCell *cell = (ChatTableViewCell*)[tableView  dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[ChatTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:identifier];
    }

    //self.textSize = textSize;
    ChatData *chat = [self.chats objectAtIndex:indexPath.row];
    
    NSString *speaker = [NSString stringWithFormat:@"%@",chat.speaker];
    cell.textLabel.text = speaker;
    cell.detailTextLabel.text = chat.content;
    cell.chat  = chat;
    
    //Set Cell color
    cell.backgroundColor = [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0];
    
    //cell.imageView.image = [UIImage imageNamed:@"Set"];

    //Attach gesture
    //Tap for Name
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    [cell addGestureRecognizer:tap];


    
    //Long Press for content
    UILongPressGestureRecognizer *longpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];

    [cell addGestureRecognizer:longpress];

    //self.pullTableView.contentSize.height+textSize.height;
    return cell;
}

- (void)tap:(UITapGestureRecognizer *)recognizer {
    
   if(recognizer.state == UIGestureRecognizerStateEnded) {
       if ([self.chatboxVC.chatbox isFirstResponder]) {
           self.chatboxVC.chatbox.text = @"";
           [self.chatboxVC.chatbox resignFirstResponder];
           self.isChatShowed = NO;
           return;
       }
       ChatTableViewCell *cell = (ChatTableViewCell *)recognizer.view;
       NSString *user = cell.textLabel.text;
       
       NSString *copy = [NSString stringWithFormat: @"@%@: ",user];
       //self.chatContents = copy;
       self.chatboxVC.chatbox.text = copy;
       
       [self showChat:cell];
       [self.chatboxVC.chatbox becomeFirstResponder];

   }

}


- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        ChatTableViewCell *cell = (ChatTableViewCell *)recognizer.view;
        self.touchedCell = cell;
        NSString *chatUserName = [cell.textLabel.text uppercaseString];
        NSString *currentUserName = [self.access.userName uppercaseString];
        
        [cell becomeFirstResponder];
        
        if([chatUserName isEqualToString:currentUserName]){

            UIMenuItem *reply = [[UIMenuItem alloc] initWithTitle:@"回复"action:@selector(reply:)];
            UIMenuItem *quote = [[UIMenuItem alloc] initWithTitle:@"引用"action:@selector(quote:)];
            UIMenuItem *remove = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(remove:)];
            UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报"action:@selector(report:)];


            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:reply, quote,remove,report,nil]];
            
        }else {
            
            UIMenuItem *reply = [[UIMenuItem alloc] initWithTitle:@"回复"action:@selector(reply:)];
            UIMenuItem *quote = [[UIMenuItem alloc] initWithTitle:@"引用"action:@selector(quote:)];
            UIMenuItem *block = [[UIMenuItem alloc] initWithTitle:@"屏蔽"action:@selector(block:)];
            UIMenuItem *report = [[UIMenuItem alloc] initWithTitle:@"举报"action:@selector(report:)];
            
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:reply, quote, block,report,nil]];
 
        }
        
        [[UIMenuController sharedMenuController] setTargetRect:cell.frame inView:cell.superview];
        [[UIMenuController sharedMenuController] setMenuVisible:YES animated:YES];
    }
}


- (void)reply:(id)sender {
    //NSLog(@"Cell was replied");

    
    NSString *copy = [NSString stringWithFormat: @"@%@: ",self.touchedCell.textLabel.text];
    //self.chatContents = copy;
    self.chatboxVC.chatbox.text = copy;
    
    [self showChat:nil];
    [self.chatboxVC.chatbox becomeFirstResponder];

    
}

- (void)quote:(id)sender {
    //NSLog(@"Cell was quoted");
    
    
    
    NSString *copy = [NSString stringWithFormat: @"\"@%@: %@\"",self.touchedCell.textLabel.text,self.touchedCell.detailTextLabel.text];
    //self.chatContents = copy;
    self.chatboxVC.chatbox.text = copy;
    
    [self showChat:nil];
    [self.chatboxVC.chatbox becomeFirstResponder];
    
}

- (void)block:(id)sender {
    //NSLog(@"Cell was blocked");
    
    [self blockUser:[self getUserID:self.touchedCell.textLabel.text] :self.touchedCell.textLabel.text];
}

- (void)report:(id)sender {
    //NSLog(@"Cell was reported");
    [self reportChat];
}
- (void)remove:(id)sender {
    //NSLog(@"Cell was removed");
    [self deleteChat];
    
}


- (NSString *) getUserID: (NSString *)userName{
    
    for (ChatData *chat in self.chats) {
        if ([[chat.speaker uppercaseString] isEqualToString:[userName uppercaseString]]) {
            return chat.userId;
        }
    }
    return nil;
    
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#define FONT_SIZE 13.0f
#define CELL_CONTENT_WIDTH 240.0f
#define CELL_CONTENT_MARGIN 10.0f
-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath

{


    ChatData *chat = [self.chats objectAtIndex:indexPath.row];
    
    CGSize size = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2), MAXFLOAT);
    
    CGSize textSize = [self frameForText:chat.content sizeWithFont:[UIFont systemFontOfSize:FONT_SIZE] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];

    //self.pullTableView.contentSize = CGSizeMake(self.pullTableView.contentSize.width, textSize.height+self.pullTableView.contentSize.height);
    //[self tableView:tableView cellForRowAtIndexPath:indexPath];
    return textSize .height+20;
    
}

- (void) appearAtBottom{
    
    
    CGFloat contentHeight = self.pullTableView.contentSize.height;
    CGFloat frameHeight = self.pullTableView.frame.size.height;
    
    if (contentHeight > frameHeight)
    {
        CGPoint offset = CGPointMake(0, contentHeight - frameHeight+44);
        [self.pullTableView setContentOffset:offset animated:NO];
    }
    
    
}

- (void) appearAtTop{
    CGFloat contentHeight = self.pullTableView.contentSize.height;
    CGFloat frameHeight = self.pullTableView.frame.size.height;
    
    if (contentHeight > frameHeight)
    {
        CGPoint offset = CGPointMake(0,-60);
        [self.pullTableView setContentOffset:offset animated:NO];
    }
    
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

 //n a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if( [[segue identifier] isEqualToString:@"ShowSet"] ) {
        SettingViewController * setView = segue.destinationViewController;
        
        setView.access = self.access;
        setView.blockedUsers = self.blockedUsers;
    }
    
}


@end
