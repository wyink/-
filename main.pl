use strict;
use warnings;

use lib './lib';

use Input;
use Taxonomy;
use BimUtils;
use DownloadUtils;


### 1. node.dmpおよびnames.dmpを配置したディレクトリへのパスをセット
#	   ローカルPCに保存されていない場合はNCBIからダウンロードする.
my $dir = Input::set_data();

### 2. AccessionID	TaxonomyIDが記述されたファイルをセットしてTaxonomyオブジェクトを生成
my ($inputfile,$delimiter) = Input::input_file();

my $taxobj = Taxonomy->new(
		accession_taxid_file => $inputfile,		# AccessionID/TaxonomyIDを記述したファイル
		delimiter_of_accession_and_taxid => $delimiter,	# $inputfileで使用しているデリミタ
		nodes_dmp_file => "${dir}/nodes.dmp",		# nodes.dmpのパス	  
		names_dmp_file => "${dir}/names.dmp" 		# names.dmpのパス
	);

#実行中
print " running...\n" ;


### 3. AccessionIDに対応するTaxonの全階層を出力
$taxobj->hierarchy_printer(
		'output_taxID.txt', 	#全階層をtaxidで出力するファイル名
		'true',		   	#taxidを学名に変換して出力する場合true,しない場合はfalse
		'output_sciname.txt'  	#trueを選択した場合の出力ファイル名
	); 

#old_taxID.txtがディレクトリに出力されていない場合は成功
#出力されている場合は以下を参照してください.

#<!----WARNING-----!>
#old_taxID.txtが同一ディレクトリに出力されている場合は手動でtaxidを更新する必要があります.
#以下の=pod/=cutを外して下記の通りに更新してください.

=pod

### 4. accession_taxid_fileにカラムを追加して新しいtaxidを追加する
# 	   example. //AccessionID	old_taxID	new_taxID
# 	   -----------------------------
# 	   AAA00001.1	112233	223344
# 	   AAB00001.1	112234	221166
# 	   ...
# 	   -----------------------------
# 	このファイルへのパスを$new_taxid_fileに代入する.


### 5.taxidを更新
$taxobj->update_taxid_accession_file(
		'2_renewed_taxid_new.txt',	#上記の通りにあなたが上書きしたファイル名
		'updated_acc_taxid.txt' 	#更新されたAccessionIDと対応するtaxidのテキストファイル名
	);

### 6. 手順3を再び行う.
#   全く同じファイル名にすることで更新前のtaxID
#	で作成されたファイルを上書きすることができる.
#----以下は手順3と全く同じ-------------------------------------------------------------

$taxobj->hierarchy_printer(
		'output_taxID.txt', 	#全階層をtaxidで出力するファイル名
		'true',		   	#taxidを学名に変換して出力する場合true,しない場合false
		'output_sciname.txt'  	#trueを選択した場合の出力ファイル名
	); 

#-------------------------------------------------------------------------------------
#old_taxid.txtが更新されていなければすべてのAccessionIDについて
#タクソン情報を出力に成功したことを意味する.

=cut

exit;
