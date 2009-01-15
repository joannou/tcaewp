/* TCAEWP */

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>
#import <Security/AuthorizationTags.h>

@interface TCAEWP : NSObject
{
	AuthorizationRef ref;
}
- (NSString *)execute:(NSString *)command arguments:(NSArray *)arguments;
@end
