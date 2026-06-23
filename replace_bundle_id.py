import os

files_to_update = [
    "Shared.xcconfig",
    "LinphoneApp.xcodeproj/project.pbxproj",
    "GoogleService-Info.plist",
    "Linphone/Info.plist",
    "Linphone/Linphone.entitlements",
    "scripts/run-mdm-tests.sh",
    "msgNotificationService/msgNotificationService.entitlements",
    "linphoneExtension/ShareViewController.swift",
    "msgNotificationService/GoogleService-Info.plist",
    "linphoneExtension/linphoneExtension.entitlements"
]

base_dir = "/home/son/Project/softphoneZlink_ios"

for file_path in files_to_update:
    full_path = os.path.join(base_dir, file_path)
    if os.path.exists(full_path):
        with open(full_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace org.linphone.phone with com.zlink.softphone
        new_content = content.replace("org.linphone.phone", "com.zlink.softphone")
        
        with open(full_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {file_path}")
    else:
        print(f"File not found: {file_path}")
