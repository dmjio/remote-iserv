/* Returns file path */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

const char * getPath () {
    NSFileManager * mngr = NSFileManager.defaultManager;
    const char * documents_path = [mngr URLsForDirectory:NSDocumentDirectory
                                               inDomains:NSUserDomainMask]
                            .firstObject.path.UTF8String;
    return documents_path;
}
