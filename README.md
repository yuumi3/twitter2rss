# twitter2rss

## Description

TwitterのListに登録されたユーザーのTweetをRSSフィードに変換するプログラム

- このプログラムの実行には apache/nginx等の動くサーバーが必用です
- またサーバーにはRuby2.4以降(bundlerも)がインストールされている必用があります
- twitter2rss.rbコマンドの起動はcronで行います

## Install

- twitter2rss.rb内のTwitterAPIを使うためのkey/secretやその他情報を設定
- `bundle install --path bundle`
- crontab に定期的にtwitter2rss.rbコマンド起動を設定

crontabの例

```
30 * * * *  cd /home/yuumi3/tools/twitter2rss; bundle exec ./twitter2rss.rb
```



## License

[MIT License](http://www.opensource.org/licenses/MIT).

markup_tweet.rb は [yayugu/twitterGoodRSS](https://github.com/yayugu/twitterGoodRSS) のものを利用しています、ありがとうございます。
