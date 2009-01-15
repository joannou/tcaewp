#import "TCAEWP.h"

@implementation TCAEWP

- (NSString *)execute:(NSString *)command arguments:(NSArray *)arguments {
	NSString *output = [NSString string];
	
	OSStatus status;
	AuthorizationFlags flags = kAuthorizationFlagDefaults;

	if (ref == NULL) {
		status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, flags, &ref);
		
		if (status != errAuthorizationSuccess)
			return @"TCAEWPFailedAuthorizationCreate";
	}

	do {
		AuthorizationItem items = {kAuthorizationRightExecute, [command length], [command UTF8String], 0};
		AuthorizationRights rights = {1, &items}; 

		flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagExtendRights;
		status = AuthorizationCopyRights(ref, &rights, kAuthorizationEmptyEnvironment, flags, NULL);
		if (status != errAuthorizationSuccess)
			break;

		const unsigned int argumentsCount = [arguments count];
		char *cArguments[argumentsCount + 1];
		int i;
		
		for (i = 0; i < argumentsCount; i++) {
			NSString *theString = [arguments objectAtIndex:i];
			unsigned int stringLength = [theString length];

			cArguments[i] = malloc((stringLength + 1) * sizeof(char));
			snprintf(cArguments[i], stringLength + 1, "%s", [theString UTF8String]);
		}
		cArguments[argumentsCount] = NULL;

		FILE *communicationsPipe = NULL;
		char buffer[64];

		flags = kAuthorizationFlagDefaults;
		status = AuthorizationExecuteWithPrivileges(ref, [command UTF8String], flags, cArguments, &communicationsPipe);
		
		for (i = 0; i < argumentsCount; i++)
			free(cArguments[i]);
			
		if (status == errAuthorizationSuccess) {
			unsigned int location = 0;
			NSRange lineTerminatorRange = {0, 0};
			NSString *line = [NSString string];

			while (1) {
				int bytesRead = read(fileno(communicationsPipe), buffer, sizeof(buffer));

				if (bytesRead < 1)
					break;
				
				output = [output stringByAppendingString:[NSString stringWithCString:buffer length:bytesRead]];
				
				while (location < [output length]) {
					lineTerminatorRange = [output rangeOfString:@"\n" options:0 range:NSMakeRange(location, [output length] - location)];

					if (lineTerminatorRange.location != NSNotFound) {
						line = [line stringByAppendingString:[output substringWithRange:NSMakeRange(location, lineTerminatorRange.location - location)]];
						NSLog(@"Line: %@", line);
						[[NSNotificationCenter defaultCenter] postNotificationName:@"TCAEWPLineNotification" object:self userInfo:[NSDictionary dictionaryWithObject:line forKey:@"line"]];
						line = [NSString string];
						location = lineTerminatorRange.location + 1;
					} else {
						line = [line stringByAppendingString:[output substringFromIndex:location]];
						location = [output length];
					}
				}
			}
					
			fclose(communicationsPipe);
		}
	} while (0);

	if (status)
		return @"TCAEWPFailed";

	return output;
}

@end
