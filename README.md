# app_updater helper

Levure helper that provides auto updates for desktop applications on macOS and Windows. To use this helper in your Levure application add it to the list of `helpers` in the `app.yml` file.

## macOS

The macOS implementation uses an extension the wraps the [Sparkle](https://sparkle-project.org) framework. 

## Windows

The Windows implementation uses an extension that wraps the [WinSparkle](https://winsparkle.org) DLL.

### appcast.xml

Sparkle and WinSparkel both use an `appcast.xml` file to detect updates. You need to copy the file included with this helper into the folder where supporting build files are stored (e.g. `build files`) and customize it. Here are the default contents:

```
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
   <channel>
      <title>APP-NAME Changelog</title>
      <link>[[BUILDPROFILE_AUTOUPDATE_URL]]/appcast.xml</link>
      <description>Most recent changes.</description>
      <language>en</language>
         <item>
            <title>Version [[VERSION]]</title>
            <sparkle:releaseNotesLink>
              [[BUILD_AUTOUPDATE_URL]]/release-notes.html
            </sparkle:releaseNotesLink>
            <pubDate>[[INTERNET_DATE]]</pubDate>
            <enclosure
               url="https://www.your-company.com/download/your-app/1_0/[[BUILD_PROFILE]]/[[MACOS_INSTALLER_NAME]]%20[[VERSION]]-[[BUILD]].dmg"
               sparkle:version="[[BUILD]]"
               sparkle:shortVersionString="[[VERSION]]"
               length="0"
               type="application/octet-stream" />
            <enclosure
               sparkle:os="windows"
               sparkle:installerArguments="[[WIN_INSTALLER_ARGUMENTS]]"
               url="https://www.your-company.com/download/your-app/1_0/[[BUILD_PROFILE]]/[[WINDOWS_INSTALLER_NAME]]%20[[VERSION]]-[[BUILD]].exe"
               sparkle:version="[[BUILD]]"
               sparkle:shortVersionString="[[VERSION]]"
               length="0"
               type="application/octet-stream" />
         </item>
   </channel>
</rss>

```

You need to change the `APP-NAME` string to be the name of your app executable. You may also change the name of the `release-notes.html` file. This is an HTML file that contains the release notes for this update.

## Levure Configuration

There are a couple of configuration options that need to be added to your `app.yml` file. 

In the `build profiles` > `all profiles` > `copy files` section add an `app updater` key that points to the `appcast.xml` and `update.txt` files for your app.

An `app updater` key is also added at the root level. Here you will specify the root url where the appcast.xml and releast-notes.html files will be located. You can also specify command line arguments to pass to the Windows installer. The example shows the arguments you would pass to an installer created with Inno Setup.

```
build profiles:
  all profiles:
    copy files:
      app updater:
        - filename: ../build files/appcast.xml

app updater:
  all profiles:
    root auto update url: https://www.MY-SERVER.com/download/MY-APP/MY-APP-VERSION/auto_update
    windows installer arguments: /SILENT /SP-
```

## Updating Info.plist on macOS

On macOS you will need to customize the Info.plist file and add the following key/value to the &lt;dict&gt; node:

```
<key>SUFeedURL</key>
<string>[[SUFeedURL]]</string>
```

During the packaging process Levure will replace `[[SUFeedURL]]` with the appcast.xml url.

## Packaging your application

When you package an application an `update` folder will be added to the output folder (sits alongside a `macos` or `windows` folder). The `update` folder will contain the appcast.xml file.

```
./update/appcast.xml
```

## Uploading your updates

**Important!** Before you upload the `appcast.xml` file make sure you have uploaded your new installers.

After packaging your application you need to upload files to the correct location. Let's assume that the `root auto update url` defined in the `app.yml` file for your app is `http://www.my-server.com/download/my-app/1_0/auto_update`, that you packaged your application for the `release` build profile, and that you packaged version `1.0.0-10` of your application.

On your server the `auto_update` folder should have a `release` folder inside of it. This represents the build profile. Perform the following actions in the order listed:

1. Upload your installers.
2. Upload the `1.0.0-10` folder to the `./auto_update/release` folder.
3. Upload your `release_notes.html` file to the `./auto_update/release` folder.
4. Upload the `appcast.xml` file to the `./auto_update` folder.

You should now have urls similar to the following:

- http://www.my-server.com/download/my-app/1_0/auto_update/release/appcast.xml
- http://www.my-server.com/download/my-app/1_0/auto_update/release/1.0.0-10/release-notes.html
