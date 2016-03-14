//
//  ViewController.m
//  insLogin
//
//  Created by __zimu on 16/3/14.
//  Copyright © 2016年 ablecloud. All rights reserved.
//

#import "ViewController.h"


#define CLIENT_ID @"1428ca5adba34e46a2b4124af2f5d595"
#define CLIENT_SECRET @"4b0913b916854b28b5c02d3f2e136e85"
#define REDIRECT_URI @"http://www.baidu.com"

@interface ViewController () <UIWebViewDelegate, NSURLConnectionDelegate>
@property (nonatomic, strong) NSMutableData *data;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self testWIthCode:@"code"];
}


- (void)testWIthCode:(NSString *)code {
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=1428ca5adba34e46a2b4124af2f5d595&redirect_uri=http://www.baidu.com&response_type=%@", code];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
                           

   UIWebView *web = [[UIWebView alloc] initWithFrame:self.view.bounds];
   web.delegate = self;
   [web loadRequest:request];
   [self.view addSubview:web];
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"开始加载");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"加载完毕");
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {

    NSString *urlString = request.URL.absoluteString;
    if ([urlString hasPrefix:@"http://www.baidu.com"]) {
        NSRange range = [urlString rangeOfString:@"http://www.baidu.com/?code="];
        NSString *code = [urlString substringFromIndex:range.length];
        NSLog(@"code == %@", code);
        NSLog(@"------------------再次发送");
        [self loginForToken:code];
    }
    
    
    return YES;
}


- (void)loginForToken:(NSString *)code {
    
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/access_token"];
    NSLog(@"urlString:%@", urlString);
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    
    
    NSDictionary *params = @{
                             @"client_id": CLIENT_ID,
                             @"client_secret": CLIENT_SECRET,
                             @"grant_type": @"authorization_code",
                             @"redirect_uri": REDIRECT_URI,
                             @"code": code
                             };
    
    NSString *str = [NSString stringWithFormat:@"client_id=%@&client_secret=%@&grant_type=authorization_code&redirect_uri=%@&code=%@", CLIENT_ID, CLIENT_SECRET, REDIRECT_URI, code];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:NULL];
    request.HTTPBody = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark - 代理方法
// 所有的代码是一样的
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
    NSLog(@"%@", challenge.protectionSpace);
    
    // 判断是否是信任服务器证书
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        
        // 创建凭据
        NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        
        // 发送信任告诉服务器
        [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    }
}

// 接收到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // 清空数据
    [self.data setData:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 拼接数据
    [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"接收到的数据%@", [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]);
}

- (NSMutableData *)data {
    if (_data == nil) {
        _data = [NSMutableData data];
    }
    return _data;
}

@end
