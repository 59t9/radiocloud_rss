# radiocloud_rss
T*Sラジオクラウドの番組をMP3抽出するサービスと、それをRSSフィードに仕立ててPodcastで利用可能にするサービス、番組毎のPodcast URLを列挙したホームページから構成されております。コードの構成に定見があるわけでもなく乱筆御容赦。

rbenv + Ruby 2.3.0での動作を確認しています。

$ RACK_ENV=production rbenv exec bundle exec rackup

(上記の起動コマンドだけ書かれてても何のことやらと思っていたけど作る側に回るとこれくらいしか書くことがない…)

本ソフトウェアは59t9が著作権を保持するものの、MITライセンスを採用しています。

https://github.com/59t9/radiocloud_rss/blob/master/LICENSE
