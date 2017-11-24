#import <UIKit/UIKit.h>

@class ApexJs;

@protocol ApexJsDelegate <UIWebViewDelegate>

- (void)javascriptBridge:(ApexJs *)bridge receivedMessage:(NSArray *)message fromWebView:(UIWebView *)webView;

@end

@interface ApexJs : NSObject <UIWebViewDelegate>

#define MESSAGE_SEPARATOR @"__wvjb_sep__"
#define CUSTOM_PROTOCOL_SCHEME @"webviewjavascriptbridge"
#define QUEUE_HAS_MESSAGE @"queuehasmessage"


@property (nonatomic, assign) IBOutlet id <ApexJsDelegate> delegate;

/* Create a javascript bridge with the given delegate for handling messages */
+ (id)javascriptBridgeWithDelegate:(id <ApexJsDelegate>)delegate;

/* Send a message to the web view. Make sure that this javascript bridge is the delegate
 * of the webview before calling this method (see ExampleAppDelegate.m) */
- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView;

@end
