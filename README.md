# Cape

## Installation

## Support

- OSX 10.9

## Usage

## Tutorial

Edit _Routes.plist_ or Create _~/.cape_.

### Examples

_Routes.plist_

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <array>
        <dict>
            <key>enable</key>
            <false/>
            <key>url</key>
            <string>https://slack.com/api/files.upload</string>
            <key>method</key>
            <string>POST</string>
            <key>name</key>
            <string>file</string>
            <key>parameters</key>
            <dict>
                <key>token</key>
                <string>xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx</string>
                <key>channels</key>
                <string>yyyyyyyy</string>
                <key>title</key>
                <string>Screenshot.png</string>
            </dict>
        </dict>
        <dict>
            <key>enable</key>
            <false/>
            <key>url</key>
            <string>https://slack.com/api/files.upload</string>
            <key>method</key>
            <string>POST</string>
            <key>name</key>
            <string>file</string>
            <key>parameters</key>
            <dict>
                <key>token</key>
                <string>xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx</string>
                <key>channels</key>
                <string>yyyyyyyy</string>
                <key>title</key>
                <string>Screenshot.png</string>
            </dict>
        </dict>
    </array>
</plist>
```

_~/.cape_

```
[
{
    "enable": true,
    "url": "https://slack.com/api/files.upload",
    "method": "POST",
    "name": "file",
    "parameters": {
        "token": "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx",
        "channels": "yyyyyyyyy",
        "title": "Screenshot.png"
    }
},
{
    "enable": false,
    "url": "https://example.com/api/upload",
    "method": "POST",
    "name": "image",
    "parameters": {
        "token": "your access token"
    }
}
]
```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

Shintaro Kaneko <kaneshin0120@gmail.com>
