wwdc2014-videos
===============

Download WWDC2014 videos under current directory. It will skip already downloaded files.

Usage
```
ruby wwdc2014-videos.rb -q "Preferred Quality (HD or SD)"
```

If you specify HD as preferred quality, but there is no corresponding HD video, it will download SD video (if there is one).

Requirement
* httparty
* nokogiri

NOTE : You have to be logged in to developer.apple.com before starting this script (I believe)
