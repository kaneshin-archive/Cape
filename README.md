# Cape

## Installation

## Support

- OSX 10.9

## Usage

## Tutorial

```
{
  "data": [{
    "url": "http://example.com/1.0/image",
    "method": "POST",
    "name": "image",
    "data": {
      "token": "YOUR ACCESS TOKEN",
      "image": "{{_FILE_}}"
    }
  },
  {
    "url": "http://example.org/",
    "method": "PUT",
    "name": "img",
    "data": {
      "token": "YOUR ACCESS TOKEN",
      "title": "img.png"
    }
  },
  {
    "url": "https://slack.com/api/files.upload",
    "method": "POST",
    "name": "file",
    "data": {
      "token": "xoxp-xxxxxxxxxx-xxxxxxxxxx-xxxxxxxxxx-xxxxxx",
      "channels": "yyyyyyyyy",
      "title": "img.png"
    }
  }]
}

```

## License

[The MIT License (MIT)](http://kaneshin.mit-license.org/)

## Author

Shintaro Kaneko <kaneshin0120@gmail.com>
