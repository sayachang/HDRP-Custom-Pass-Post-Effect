# HDRP-Custom-Pass-Post-Effect  
HDRP Custom Pass Post Effect

ローマ字の説明は日本語の説明に続けて記載します。  
Ro-ma ji forouzu Japanizu.

エフェクトを確認するために、くつした屋さんのシャオンちゃんをシーンに配置しています。シャオンちゃんがいなければ、これらのポストエフェクトを書こうとは思わなかったことでしょう。スペシャルサンクス！  
Efekuto wo kakunin surutameni, kutsushita ya san no Shaon chan wo shi-n ni haichi shite imasu. Shaon chan ga inakereba, korerano posuto efekuto wo kakou toha omowanakatta koto desyou. Supesharu Sankusu!  
[オリジナル3Dモデル『シャオン』 - くつした屋 / orijinaru 3D moderu Shaon - kutsushita ya](https://booth.pm/ja/items/2048231)

バージョン情報  
Ba-jon jouhou

Unity 2020.1.2f1  
HDRP 8.2.0

---

## 何？  
Howatto?

UnityのHDRPで利用できるカスタムパスで作られたポストエフェクト集です。  
Unity no HDRP de riyou dekiru kasutamu pasu de tukurareta posuto efekuto syuu desu.

## どうなるの？  
Dounaruno?

画像で見ていただくのが早いでしょう。選んだエフェクトを画面全体にかけることができます。  
Gazou de mite itadakunoga hayai desyou. Eranda efekuto wo gamenzentai ni kakeru kotoga dekimasu.

![ポストエフェクト posutoefekuto](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/CustomPassImage.png "posteffect")

## どうやって使うの？  
Douyatte tukauno?

1. HDRPテンプレートでプロジェクトを作成します  
HDRP tenpure-to de purojekuto wo sakusei simasu
1. このリポジトリの内容(Assets以下)をプロジェクトフォルダにコピーします  
kono ripojitori no naiyou(Assets ika)wo purojekuto foruda ni kopi- simasu
1. サンプルシーン(Assets/SampleScene/SampleScene.unity)を開きます  
sanpuru si-n(Assets/SampleScene/SampleScene.unity)wo hirakimasu
1. ヒエラルキーのカスタムパスを選択し、エフェクトのチェックボックスをオン/オフします  
hieraruki- no kasutamu pasu wo sentaku si, efekuto no tyekku bokkusu wo on/ohu simasu

![ヒエラルキー](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/CustomPassGameObject.png "Hierarchy")

## どんなエフェクトがあるの？  
Donna efekuto ga aruno?

### あざやかフィルター  
Azayaka Firuta-

![あざやかフィルター Azayaka Firuta-](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Azayaka.png "Vibrance Filter")

### みずたまトランジション  
Mizutama Toranjishon

![みずたまトランジション Mizutama Toranjishon](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/MizutamaTransition.png "Mizutama Transition")

### RGBハーフトーン  
RGB Ha-fu to-n

![RGBハーフトーン Ha-fu to-n](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Halftone.png "RGB Halftone")

### グレースケール  
Gure- Suke-ru

![グレースケール Gure- Suke-ru](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Grayscale.png "Grayscale")

### CRT風  
CRT fuu

![CRT](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/CRT.png "CRT")

### 桑原フィルター  
Kuwahara Firuta-

![桑原フィルター Kuwahara Firuta-](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/KuwaharaFilter.png "Kuwahara Filter")

### アウトライン  
Auto Rain

![アウトライン Auto rain](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Outline.png "Outline")

### 雨粒  
Amatsubu

![雨粒 Amatsubu](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/RainDrops.png "Rain Drops")

### ソーベルフィルター  
So-beru Firuta-

![ソーベルフィルター So-beru Firuta-](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/SobelFilter.png "Sobel Filter")

### モザイク  
Mozaiku

![モザイク Mozaiku](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Mosaic.png "Mosaic")

### 集中線  
Syuuchuusen

![集中線 Syuuchuusen](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Concentrated.png "Concentrated")

### ネガポジ変換  
Negathibu

![ネガポジ変換 Negathibu](https://raw.githubusercontent.com/sayachang/HDRP-Custom-Pass-Post-Effect/master/Images/Nega.png "Nega")

## リファレンス  
Rifarensu

RGB Halftone  
[RGB Halftone-lookaround.fs](https://editor.isf.video/shaders/234)

CRT風  
[80年代ゲーセン筐体っぽいレトロ調の画面をUnityシェーダーで作る。](https://sayachang-bot.hateblo.jp/entry/2019/12/11/231351)

桑原フィルター  
[Kuwahara Filtering - Shadertoy](https://www.shadertoy.com/view/MsXSz4#)

アウトライン  
[Custom Pass - Unity Manual](https://docs.unity3d.com/Packages/com.unity.render-pipelines.high-definition@8.2/manual/Custom-Pass.html)

雨粒  
[Heartfelt - Shadertoy](https://www.shadertoy.com/view/ltffzl)

ソーベルフィルター  
[Real Toon - Unity AssetStore](https://assetstore.unity.com/packages/vfx/shaders/realtoon-65518)

misc  
[Unityで画像にエフェクト加工するかんたんシェーダーを書く。 - さやちゃんぐbotブログ](https://sayachang-bot.hateblo.jp/entry/2019/02/09/200303)

