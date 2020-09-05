use strict;
use warnings;

use lib './lib';

use Input;
use Taxonomy;
use BimUtils;
use DownloadUtils;



### node.dmp/names.dmpを配置したディレクトリへのパスをセット
### ローカル環境に存在しない場合はNCBIからダウンロードする.
my $dir = Input::set_data();

### uniqueID,TaxonomyIDが記述されたファイルをセット
my ($inputfile,$delimiter) = Input::input_file();

my $taxobj = Taxonomy->new(
		accession_taxid_file => $inputfile,
		delimiter_of_accession_and_taxid => $delimiter,
		nodes_dmp_file => "${dir}/nodes.dmp",
		names_dmp_file => "${dir}/names.dmp"
	);

### 全階層をtaxidで出力するファイル名の入力
my $taxid_outfile = Input::taxid_outfile();


my $return_code = '';
### AccessionIDに対応するTaxonの全階層を出力
$return_code = $taxobj->hierarchy_printer(
		$taxid_outfile
	);

### 返却値がtrueの場合は更新前のtaxidが含まれている
if ($return_code eq 'true'){
	
	### taxidを更新するかどうかの判断
	my $bool = Input::ask_update();
	if($bool eq 'true'){
		### merged.dmpをダウンロード
		DownloadUtils::download_merged();

		### 入力ファイルのtaxIDを更新
		$taxobj->update_taxid_accession_file();

		### 再出力
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

### Finished!
my $fin =<<'EOS';

 ========
   Done!
 ========

EOS
print $fin;

### taxidを学名に変換して出力する場合true,しない場合はfalse
my $isToSciname = Input::isToSciname();


### taxidを学名に変換して出力する場合のファイル名
if($isToSciname eq 'true'){
	my $taxon_outfile = Input::taxon_outfile();
	$taxobj->toScie_name(
		$taxid_outfile,  
		$taxon_outfile   
	);
}

print $fin;

exit;
