//
//  ViewController.m
//  CCPemBuilder
//
//  Created by Carven Chen on 2017/8/8.
//  Copyright © 2017年 com.carven. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () 

@property (weak) IBOutlet NSButton *addBtn;

@property (nonatomic, strong) NSString *fullPath;

@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) NSString *fileName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
        
    [self.addBtn setImage:[NSImage imageNamed:@"main_add_icon"]];
    
}



- (IBAction)addBtnClicked:(NSButton *)sender {
    
    __weak typeof(self) weakSelf = self;
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        //1、选中文件   0、取消选中
        if (result == 1) {
            
            //处理文件路径
            NSURL *elemnet = [[panel URLs] firstObject];
            NSString *fullPath = [elemnet relativePath];
            
            weakSelf.fullPath = fullPath;
            weakSelf.filePath = [fullPath stringByDeletingLastPathComponent];
            
            NSString *fileName_ = fullPath.lastPathComponent;
            weakSelf.fileName = [fileName_ stringByDeletingPathExtension];
            
            //开始处理p12文件
            [weakSelf starthandleP12File];
        }
    }];
}


- (void)starthandleP12File {
    
    [self getP12Password];
}

- (void)getP12Password {
    
    //弹框验证p12文件的密码
    __weak typeof(self) weakSelf = self;
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"请输入p12文件密码"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [alert setAccessoryView:input];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
            
            if (input.stringValue.length > 0) {
                
                NSString *password = input.stringValue;
                
                //生成cer的pem文件
                NSString *cmdStr = [NSString stringWithFormat:@"openssl pkcs12 -clcerts -nokeys -out %@/%@.pem -in %@ -password pass:%@", _filePath, _fileName, _fullPath, password];
                NSLog(@"%@", cmdStr);
                
                //执行命令
                system([cmdStr UTF8String]);
                
                [weakSelf setPemPassword:password];
            }
            
            
        }
    }];
}


- (void)setPemPassword:(NSString *)password {
    
    //弹框验证p12文件的密码
    __weak typeof(self) weakSelf = self;
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"请输入您想设置的pem密码"];
    [alert setAlertStyle:NSAlertStyleCritical];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    input.placeholderString = @"请输入您想设置的pem密码";
    [alert setAccessoryView:input];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            NSLog(@"确定");
            
            if (input.stringValue.length > 0) {
                
                NSString *cmdStr = [NSString stringWithFormat:@"openssl pkcs12 -nocerts -out %@/%@_key.pem -in %@ -passin pass:%@ -passout pass:%@", _filePath, _fileName, _fullPath, password, input.stringValue];
                NSLog(@"%@", cmdStr);
                system([cmdStr UTF8String]);
                
                //选择最终文件的存储位置
                NSSavePanel *panel = [NSSavePanel savePanel];
                [panel setNameFieldStringValue:@"ck.pem"];
                [panel setMessage:@"选择您需要存储的位置"];

                [panel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result){
                    if (result == NSFileHandlingPanelOKButton)
                    {
                        NSString *path = [[panel URL] path];
                        
                        [weakSelf unitPemFile:path];
                    }
                }];
            }
        }
    }];
}

- (void)unitPemFile:(NSString *)savePath {
 
    //合成
    NSString *cmdStr = [NSString stringWithFormat:@"cat %@/%@.pem %@/%@_key.pem > %@", _filePath, _fileName, _filePath, _fileName, savePath];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
    
    
    //删除两个中间文件
    cmdStr = [NSString stringWithFormat:@"rm -rf %@/%@.pem", _filePath, _fileName];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
    
    cmdStr = [NSString stringWithFormat:@"rm -rf %@/%@_key.pem", _filePath, _fileName];
    NSLog(@"%@", cmdStr);
    system([cmdStr UTF8String]);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
