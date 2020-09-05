# GetTaxonomyRanks
Get all the taxonomic ranks above the target TaxId.

</br>

## このアプリケーションについて

すべての系統分類の各階層（種・属・科など）にはTaxId（NCBI taxonomy databaseで管理されている）が割り振られており，生物種の識別に広く利用されています．このアプリケーションは下位分類（ex.種）の**特定のTaxIdからその上位分類の全て（種，属，科～）のTaxIdまたはその学名を取得することができるコンソールアプリケーション**です．入出力は具体例を参考にしてください．

</br>

## 具体例

##### 入力
下位分類（種）のTaxIdとしてArabidopsis thalianaの90284を入力とします．仮にこのTaxIdがNCBI taxonomy database で更新されて現在は使われていなかったとしてもこのアプリケーション実行中に更新することができます．複数のTaxIdを入力ファイルに記述することで一度にまとめて取得することも可能です．

入力例 : ` TaxId_1 3702`

##### 出力
その上位分類である種，科，目...最上位分類までを得ることができます．|の左側は分類群のTaxId、右側は分類階級です．</br>
出力例 : ` TaxId_1	3702|species	3701|genus	980083|tribe	3700|family ...`

それぞれのデリミタ「|」の左側のTaxIdを学名に変更して出力することも可能です．</br>
出力例 : ` TaxId_1	Arabidopsis thaliana|species	Arabidopsis|genus	Camelineae|tribe	Brassicaceae|family ...`
</br>

## 使用方法

このアプリケーションはWindowsを対象としています．
1. `launch.bat`をダブルクリックして実行します．
2. 基本的にはプロンプトに従って入力していきます．

</br>

## 使用例
launch.batを実行してプロンプトに表示される内容を例にとって説明します．使用法でも示していますが基本的にプロンプト表示に従えばいいので参考程度に利用していただけたらと思います．
***

#### 1. nodes/names.dmpの所持の可否
`Do you have node.dmp and names.dmp? [y/n] : n `

nodes.dmpおよびnames.dmpはncbiのFTPに置かれているtaxdmp.zipを解凍して得ることができます．ここではローカル環境に保存されていないものとして`n`を入力します．持っている場合は当該ディレクトリまでのパスをセットします．
</br>

#### 2. 入力ファイルのセット

```
 //...略
 input your file that describes your uniqueID & TaxonomyID

   Example :
   --------------------
   AAA00001.1   112233
   AAB00002.1   112234
   ...
   --------------------

 Input your filename : ./test/input.txt
 ```

次に入力のファイルパスを入力します．
入力ファイルの内容はコマンドウィンドウ上で示されている通りです．左側に一意のID，右側には上位分類群を知りたい下位分類のTaxIdを記述します．デリミタ（区切り文字）はタブ，もしくはカンマをサポートしています．

</br>


#### 3. デリミタ（区切り文字）の選択

```
 //...省略
 Input your filename :  ./test/input.txt

 OK.


 =========================================
 Select the delimiter you use in your file
 In this example case, the delimiter is 1 .

  1.  Tab
  2.  ,

 Select the number : 1
```

今回はタブ区切りであるため`1`を入力します．

#### 4. 出力ファイルの名前を入力
```
 //...省略
 Enter the output filename : output1.txt

```
ファイル名を入力します．名前は任意で構いませんが，拡張子まで入力する必要があります．

</br>

#### 5. 結果の確認
ここまででoutput1.txtには`id_1	90284|species	90283|genus	404319|family...	131567|no rank`と正しく出力されているのが確認できます．
</br>

#### 6. 手順4で出力されている「TaxId|分類階級」を「学名|分類階級」に変換
```
//...省略
Enter the output filename : output1.txt

 input OK.



 running...
 ========
   Done!
 ========


 ==================================================================

 Each TaxonomyID can be converted to Scientific name.
 Do you want to do that? (create new file) [y/n] : y
```
変換する場合は`y`を選択します．

</br>

#### 7. 出力ファイル名を入力
```
 //...省略
 Enter the output filename : output2.txt
```

</br>

#### 8. 結果の確認

output2.txtの中身を確認すると`id_1	Pylaisiadelpha tenuirostris|species	Pylaisiadelpha|genus ... cellular organisms|no rank	`と正しく出力していることが確認できます．
