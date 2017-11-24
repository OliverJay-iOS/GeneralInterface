#import "ApexJs.h"

@interface ApexJs ()

@property (nonatomic,strong) NSMutableArray *startupMessageQueue;

- (void)_flushMessageQueueFromWebView:(UIWebView *)webView;
- (void)_doSendMessage:(NSString*)message toWebView:(UIWebView *)webView;

@end

@implementation ApexJs

@synthesize delegate = _delegate;
@synthesize startupMessageQueue = _startupMessageQueue;

+ (id)javascriptBridgeWithDelegate:(id <ApexJsDelegate>)delegate {
    ApexJs* bridge = [[ApexJs alloc] init];
    bridge.delegate = delegate;
    bridge.startupMessageQueue = [[NSMutableArray alloc] init];
    return bridge;
}

- (void)dealloc {
    _delegate = nil;
}

- (void)sendMessage:(NSString *)message toWebView:(UIWebView *)webView {
    if (self.startupMessageQueue) { [self.startupMessageQueue addObject:message]; }
    else { [self _doSendMessage:message toWebView: webView]; }
}

- (void)_doSendMessage:(NSString *)message toWebView:(UIWebView *)webView {
    message = [message stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\\n"];
    message = [message stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    message = [message stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"ApexJs._handleMessageFromObjC('%@');", message]];
}

- (void)_flushMessageQueueFromWebView:(UIWebView *)webView {
    NSString *messageQueueString = [webView stringByEvaluatingJavaScriptFromString:@"ApexJs._fetchQueue();"];
    NSArray* messages = [messageQueueString componentsSeparatedByString:MESSAGE_SEPARATOR];
    [self.delegate javascriptBridge:self receivedMessage:messages fromWebView:webView];
}

#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *js = [NSString stringWithFormat:@";(function() {"
//        "if (window.ApexJs) { return; };"
        "var _readyMessageIframe,"
        "     _sendMessageQueue = [],"
        "     _receiveMessageQueue = [],"
        "     _MESSAGE_SEPERATOR = '%@',"
        "     _CUSTOM_PROTOCOL_SCHEME = '%@',"
        "     _QUEUE_HAS_MESSAGE = '%@';"
        ""
        "function _createQueueReadyIframe(doc) {"
        "     _readyMessageIframe = doc.createElement('iframe');"
        "     _readyMessageIframe.style.display = 'none';"
        "     doc.documentElement.appendChild(_readyMessageIframe);"
        "}"
        ""
        "function _sendMessage(message,data) {"
        "     _sendMessageQueue.push(message);"
        "     _sendMessageQueue.push(data);"
        "     _readyMessageIframe.src = _CUSTOM_PROTOCOL_SCHEME + '://' + _QUEUE_HAS_MESSAGE;"
        "};"
        ""
        "function _fetchQueue() {"
        "     var messageQueueString = _sendMessageQueue.join(_MESSAGE_SEPERATOR);"
        "     _sendMessageQueue = [];"
        "     return messageQueueString;"
        "};"
        ""
        "function _setMessageHandler(messageHandler) {"
        "     if (ApexJs._messageHandler) { return alert('ApexJs.setMessageHandler called twice'); }"
        "     ApexJs._messageHandler = messageHandler;"
        "     var receivedMessages = _receiveMessageQueue;"
        "     _receiveMessageQueue = null;"
        "     for (var i=0; i<receivedMessages.length; i++) {"
        "         messageHandler(receivedMessages[i]);"
        "     }"
        "};"
        ""
        "function _handleMessageFromObjC(message) {"
        "     if (_receiveMessageQueue) { _receiveMessageQueue.push(message); }"
        "     else { ApexJs._messageHandler(message); }"
        "};"
        ""
        "window.ApexJs = {"
        "     setMessageHandler: _setMessageHandler,"
        "     sendMessage: _sendMessage,"
        "     _fetchQueue: _fetchQueue,"
        "     _handleMessageFromObjC: _handleMessageFromObjC"
        "};"
        ""
        "var doc = document;"
        "_createQueueReadyIframe(doc);"
        "var readyEvent = doc.createEvent('Events');"
        "readyEvent.initEvent('ApexJsReady');"
        "doc.dispatchEvent(readyEvent);"
        ""
        "})();",
        MESSAGE_SEPARATOR,
        CUSTOM_PROTOCOL_SCHEME,
        QUEUE_HAS_MESSAGE];
    
//    NSLog(@"[webView stringByEvaluatingJavaScriptFrom =%@ ",[webView stringByEvaluatingJavaScriptFromString:@"typeof ApexJs"]);
    
    if (![[webView stringByEvaluatingJavaScriptFromString:@"typeof ApexJs == 'object'"] isEqualToString:@"true"])
    {
        [webView stringByEvaluatingJavaScriptFromString:js];
//        [webView stringByEvaluatingJavaScriptFromString:@"sendMessage('4')"];
//        [webView stringByEvaluatingJavaScriptFromString:@"sendMessage('4','234')"];
    }
    
    for (id message in self.startupMessageQueue) {
        [self _doSendMessage:message toWebView: webView];
    }

    self.startupMessageQueue = nil;
    
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSLog(@"url host =%@,%@,%@",url.host,[url scheme],request);
    
//    NSRange range = [[request.URL absoluteString] rangeOfString:@"ApexJs.sendMessage("];
//    if(range.length > 0){
//        int loc = range.location + range.length;
//        range = [[request.URL absoluteString] rangeOfString:@","];
//        NSString * targetString = [[request.URL absoluteString] substringWithRange:NSMakeRange(loc, range.location - loc)];
//        NSLog(@"targetstirng =%@,%i,%@",targetString,loc,NSStringFromRange(range));
//        
//        if([targetString intValue] == CODE_SHOW_ME_POINT){
//            [[DiDiManager Instance]->loanMainVC->me_RedCycleButton setHidden:NO];
//        }
//        if([targetString intValue] == CODE_HIDDEN_ME_POINT){
//            [[DiDiManager Instance]->loanMainVC->me_RedCycleButton setHidden:YES];
//        }
//        if([targetString intValue] == CODE_CALL_RETURN_VERSION){
//            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//            NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
//            [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:setVersionDate('%@');", [NSString stringWithFormat:@"{versionName:%@,osVersion:%@}",appCurVersion,[[UIDevice currentDevice] osVersion]]]];
//            
//            //        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"javascript:setVersionDate('%@');", [NSString stringWithFormat:@"{versionName:%@,osVersion:%@}",appCurVersion,[[UIDevice currentDevice] osVersion]]]]]];
//        }
//        
//        return NO;
//    }
    if (![[url scheme] isEqualToString:CUSTOM_PROTOCOL_SCHEME]) {
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        {
            return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
        return YES;
    }
    
    if ([[url host] isEqualToString:QUEUE_HAS_MESSAGE]) {
        [self _flushMessageQueueFromWebView: webView];
    }
    else {
        NSLog(@"ApexJs: WARNING: Received unknown WebViewJavascriptBridge command %@://%@", CUSTOM_PROTOCOL_SCHEME, [url path]);
    }
    
    return NO;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

@end
