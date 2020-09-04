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
my $running =<<'EOS';

 running...
EOS

chomp($running);
print $running;

#全階層をtaxidで出力するファイル名
my $taxid_outfile = Input::taxid_outfile();

#taxidを学名に変換して出力する場合true,しない場合はfalse
my $isToSciname = Input::isToSciname();

my $return_code = '';
### 3. AccessionIDに対応するTaxonの全階層を出力
$return_code = $taxobj->hierarchy_printer(
		$taxid_outfile
	);

#返却値がtrueの場合は更新前のtaxidが含まれている
if ($return_code eq 'true'){
	
	#taxidを更新するかどうかの判断
	my $bool = Input::ask_update();
	if($bool eq 'true'){
		#merged.dmpをダウンロード
		DownloadUtils::download_merged();

		#入力ファイルのtaxIDを更新
		$taxobj->update_taxid_accession_file();

		#再出力
		$taxobj->hierarchy_printer(
			$taxid_outfile
		);
		
	}elsif($bool eq 'false'){
		# Do nothing.
		# Safely finished!
	}else{
		print " Fatal error\n";
	}
}

#taxidを学名に変換して出力する場合のファイル名
if($isToSciname eq 'true'){
	my $taxon_outfile = Input::taxon_outfile();
	$taxobj->toScie_name(
		$taxid_outfile,  #変換前のファイルのパス
		$taxon_outfile   #taxid/タクソンを学名/タクソンに変換して出力するファイルパス
	);
}


#Finished!
my $fin =<<'EOS';

 Done!

EOS
print $fin;



=pod

### 4. accession_taxid_fileにカラムを追加して新しいtaxidを追加する


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
