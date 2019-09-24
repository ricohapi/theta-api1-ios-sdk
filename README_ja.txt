==================================================
 README for "RICOH THETA SDK for iOS"

 Version :0.3.0
==================================================

このファイルはRICOH THETA SDK for iOSに関する説明文書です。
lib-ricoh-thetaとlib-r-exifはiOS用のアプリケーションを作成するためのライブラリです。
ricoh-theta-sample-for-iosは上記のライブラリを利用したサンプルアプリケーションです。
なお、この文書は既にiOSの開発者登録済でiOSのアプリケーションを開発することができる状態であることを前提としています。

----------------------------------------

* この文書に含まれる内容

    * 利用規約
    * アーカイブに含まれているファイルに関して
    * 開発に必要な環境に関して
    * 使い方に関して
    * 最新の情報に関して
    * トラブルシューティング
    * 商標について
    * 更新履歴

----------------------------------------

* 利用規約

    同梱されている、LICENSE.txt(LICENSE_ja.txt)に記載されています。
    RICOH THETA SDKをご使用になられた時点で、この規約に合意したものとみなします。

----------------------------------------

* アーカイブに含まれているファイルに関して

    README.txt                           	：このファイルです(英語)
    README_ja.txt                        	：このファイルです(日本語)
    LICENSE.txt                          	：規約に関するファイルです(英語)
    LICENSE_ja.txt                     		：規約に関するファイルです(日本語)
    ricoh-theta-sample-for-ios
    ┣ ricoh-theta-sample-for-ios       	：サンプルアプリケーションのソースです
    ┣ ricoh-theta-sample-for-ios.xcodeproj	：サンプルアプリケーションのオブジェクトです
    ┗ doc                           	    ：サンプルアプリケーション関するドキュメントです
    lib
    ┣ lib-ricoh-theta                  	：RICOH THETAの操作に関するライブラリです
    ┣ lib-r-exif                       	：RICOH THETAで撮影した全天球イメージのEXIF情報の取得ができるライブラリです
    ┣ lib-ricoh-theta_serializer      		：lib-ricoh-thetaの利用を行いやすくしたライブラリです
    ┗ doc                              	：ライブラリに関するドキュメントです

----------------------------------------

* 開発に必要な環境に関して

    [ RICOH THETAについて ]
      以下の条件を満たすRICOH THETA専用のライブラリです。

      * ハードウェア
          RICOH THETA (2013年発売モデル)
          RICOH THETA (型番：RICOH THETA m15)
      * ファームウェア
          バージョン 1.21 以上
          (ファームウェアの確認およびアップデート方法はこちらです： https://theta360.com/ja/support/manual/content/pc/pc_05.html )


    [ サンプルアプリケーションの開発環境について ]
      サンプルアプリケーションは以下の条件で動作確認済みです。

      * 動作確認環境
          iPhone 5s
      * 開発・ビルド環境
          Xcode 6.0.1

----------------------------------------

* 使い方に関して

    [ サンプルアプリケーションを動かす場合 ]
        1. ricoh-theta-sample-for-iosをXcodeから開いて実行してください、iOS端末にサンプルアプリケーションが登録されます
        2. RICOH THETAをiOS端末とWi-Fiで接続してください
            (使用説明書、カメラとスマートフォンを接続する：https://theta360.com/ja/support/manual/content/prepare/prepare_06.html)
        3. サンプルアプリケーションを操作する事ができます

    [ 自分のアプリケーションでRICOH THETA SDKを利用する場合 ]
        1. 自分のアプリケーションにlib内のlib-ricoh-theta、lib-r-exif、lib-ricoh-theta_serializerをコピーしてください
        2. frameworkとdylibを追加してください、ライブラリ利用時に必要なものはそれぞれのライブラリフォルダ内のREADMEに記載されています
           OpenGL ESを使用する場合には必要に応じてGLKit、OpenGLES frameworkを追加してください
        3. サンプルアプリケーションや後述の情報をもとに実装をしてください

    [ より詳しい情報に関して ]
        同梱されているライブラリの内容やドキュメント、およびWEB上のドキュメントをご確認ください。

        https://developers.theta360.com/ja/docs/

----------------------------------------

* 最新の情報に関して

    最新の情報はWEBサイト「RICOH THETA Developers」にて公開されています。

    https://developers.theta360.com/

----------------------------------------

* トラブルシューティング

    よくある質問についてはこちらのフォーラム上にまとめてあります。

    https://developers.theta360.com/ja/forums/viewforum.php?f=5

----------------------------------------

* 商標について

    本文書に記載されている商品・サービス名は、各社の商標または登録商標です。

    * iPhone、Xcodeは、Apple Inc.の商標です
    * iOSの商標は、米国Ciscoのライセンスに基づき使用されています
    * Wi-Fiは、Wi-Fi Allianceの商標です

    その他商標は全て、それぞれの所有者に帰属します。

----------------------------------------

* 更新履歴

    2015/02/20 0.3.0 サンプルアプリに全天球ビューア機能を追加
    2014/11/10 0.2.1 import文の不足分追加
    2014/11/06 0.2.0 英語訳反映
    2014/10/28 0.1.0 初回リリース
