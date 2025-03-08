# reels_demo

Tiktok like reels viewer and editor made in flutter

## How to use

Use below flutter and dart version
`Flutter version: 3.29.0 - Stable Channel`
`Dart version: 3.7.0`

Clone the repository using: `https://github.com/Ashwin1002/Reels-Demo.git`

### Android setup

Inside `app/build.gradle`
`ndk version: "27.0.12077973"`
`min sdk: 24`

Inside `AndroidManifest.xml`,

```
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### IOS setup

Inside `Podfile`, update the line:

```
platform :ios, '13.0'
```
