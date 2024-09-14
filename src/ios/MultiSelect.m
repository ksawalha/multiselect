#import "MultiSelect.h"

@implementation MultiSelect

- (void)chooseFiles:(CDVInvokedUrlCommand*)command {
    self.commandDelegate = self.commandDelegate;
    
    NSArray *types = @[@"public.item"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.allowsMultipleSelection = YES;

    [self.viewController presentViewController:picker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for (NSURL *url in urls) {
        NSString *fileName = [url lastPathComponent];
        NSString *fullPath = [url path];
        NSString *fileContent = [self getFileContent:url];
        
        NSDictionary *fileData = @{@"filename": fileName, @"fullPath": fullPath, @"fileContent": fileContent};
        [resultArray addObject:fileData];
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:resultArray];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandCallbackId];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"User cancelled file selection"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.commandCallbackId];
}

- (NSString *)getFileContent:(NSURL *)url {
    NSData *fileData = [NSData dataWithContentsOfURL:url];
    if (fileData) {
        return [fileData base64EncodedStringWithOptions:0];
    }
    return nil;
}

@end
