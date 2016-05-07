//
//  ViewController.m
//  应用内支付例子
//
//  Created by chen xiaosong on 16/5/7.
//  Copyright © 2016年 chen xiaosong. All rights reserved.
//
@import StoreKit;

#import "ViewController.h"

@interface ViewController ()

@end

static NSString * const productId = @"com.hellosns.tomatoclock.removead";

#define Settings [NSUserDefaults standardUserDefaults]

@interface ViewController ()<SKProductsRequestDelegate,SKPaymentTransactionObserver>
{
    SKProductsRequest *productsRequest;
}

@property (strong, nonatomic) SKProduct *product;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)payBtnPressed:(id)sender {
    if ([SKPaymentQueue canMakePayments])
    {
        SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:productId]];
        request.delegate = self;
        [request start];
    }
}


- (IBAction)recoverBtnPressed:(id)sender {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

// fetch product list
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    
    NSArray *products = response.products;
    if (products.count != 0) {
        self.product = products[0];
        SKPayment *payment = [SKPayment paymentWithProduct:self.product];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }

    products = response.invalidProductIdentifiers;
    for (SKProduct *product in products) {
        NSLog(@"%@", product);
    }
    
}

#pragma mark -
#pragma mark SKPaymentTransactionObserver methods
-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Done with payment successfully");
                [Settings setBool:TRUE forKey:@"adsRemoved"];
                [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
                
            case SKPaymentTransactionStateFailed:
                NSLog(@"Pay failed");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;

            case SKPaymentTransactionStateRestored:
                [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
                break;
            default:
                break;
        }
    }
}

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        if(SKPaymentTransactionStateRestored){
            NSLog(@"Transction restored");
            [transaction.payment.productIdentifier isEqualToString:productId];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
            break;
        }
        
    }
}

@end
