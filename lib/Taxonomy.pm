package Taxonomy;

use strict;
use warnings;
use BimUtils;

sub new {
	my ($class,%args) = @_ ;
	my $self = {%args} ;
	$self->{accession_taxid_file} //= 'none';
	$self->{delimiter_of_accession_and_taxid} //='none';
	$self->{nodes_dmp_file} //='none';
	$self->{names_dmp_file} //='none';

	my %old_taxid_hash = ();
	$self->{old_taxid_hash} = \%old_taxid_hash;

	$self->init();
	#指定の引数が入力されたかどうかの確認
	foreach $_ (keys %$self){
		if ($self->{$_} eq 'none'){
			print "Argument Error\n" ;
			exit;
		}
	}
	return bless $self,$class;
}

sub init {
	my $self = '';
	my $self->{ac_tx_hash} = BimUtils->hash_key_del_val(
			$self->{accession_taxid_file},
			$self->{delimiter_of_accession_and_taxid}
		);
}

sub accession_taxid_file_setter {
	my $self = shift;
	my $new_accession_taxid_file = shift ;
=pod
	Description
	-----------
	メンバ変数のaccession_taxid_fileをセットする関数
	&update_taxid_accession_file()で変更する際に使用する

	Parameters
	----------
	$new_accession_taxid_file: 
	accession_taxid_fileの変更後の値

=cut
	$self->{accession_taxid_file} = $new_accession_taxid_file ;
}

sub accession_taxid_file_getter {
	my $self = shift ;
=pod
	Description
	-----------
	メンバ変数のaccession_taxid_fileを返却する関数

	Returns
	-------
	$self->accession_taxid_file:
	メンバ変数の$accession_taxid_fileの値を返却する
	
=cut
	return $self->{accession_taxid_file};
}

sub toScie_name {
	my $self 	   = shift;
	my $original_file  = shift;
	my $ndp_delr 	   = shift;
	my $ndp_del        = shift;
	my $original_del   = shift;
	my $out_file3_name = shift;

=pod
	Description
	------------
	taxidをscientificname(学名)に変換して出力.

	Parameters
	----------
	$original_file : 変換前のファイル（タクソンに対応するのがtaxid）のパス

	$ndp_delr: taxidと対応するタクソンとのデリミタの正規表現

	$ndp_del : taxidと対応するタクソンとのデリミタ

	$original_del  : AccessionIDに対応する全てのtaxid/タクソンを結びつけるデリミタ

	$out_file3_name : taxid/タクソンを学名/タクソンに変換して出力するファイルパス

=cut

	#names.dmpファイルからtaxIDと学名を連想配列で紐づける.
	open my $FH,"<",$self->{names_dmp_file} or die "Can't open names.dmp\n";
	my %hash=(); #hash{taxid}=対応するタクソンの学名
	my @node=();#(taxID,タクソンの学名,'識別子(scientific nameやtype material')
	my $nodes_dmp_del = '\|';
	while(my $line=<$FH>){
		chomp $line;
		@node = split/${nodes_dmp_del}/,$line;
		@node = map{$_ =~s/\t//g;$_}@node[0,1,3];
		if($node[2] eq 'scientific name'){
			$hash{$node[0]} = $node[1];
			next;
		}
	}
	close $FH;

	#taxid/タクソンのファイルから上記で紐づけた連想配列を利用し、
	# 学名/タクソンに変換して出力する.
	open $FH,"<",${original_file} or die "Can't open the original_file!\n";
	open my $OFH,">",${out_file3_name} or die "Can't create the ${out_file3_name}\n" ;
	my ($accessionID,$taxid,$taxon) = ('','','');
	my @list = (); #@list =(taxid/taxon taxid/taxon ...);
	while(my $line=<$FH>){
		chomp $line;
		($accessionID,@list)=split/${original_del}/,$line;
		print $OFH ${accessionID}.${original_del};
		foreach $_(@list){
			($taxid,$taxon)=split/${ndp_delr}/,$_;
			print $OFH $hash{$taxid}.${ndp_del}.${taxon}.${original_del};
		}
		print $OFH "\n";	
	}
	close $FH;
	close $OFH;

}

sub node_dmp_parser {
	my $self = shift;

=pod
	Description
	-----------
	nodes.dmpファイルをパース

	Returns
	------
	$hash_ref : keyは系統の親のtaxid,valueは文字列（"親taxid|子taxid|タクソン"）

=cut

	my %hash=();#%hash =(Parent_taxid=>"Parent_taxid|Child_taxid|Taxon(genus,sfamily...)");
	my $nodes_file_del = '\t\|\t';
	my ($prID,$chID,$taxon)=('','',''); # 1,1,no rank
	my ($ndp_delr,$ndp_del)=('\|',"|");
	open my $FH,"<",$self->{nodes_dmp_file} or die "Can't open nodes.dmp file\n";
	while(my $line=<$FH>){
		chomp $line;
		($prID,$chID,$taxon,@_)=split/${nodes_file_del}/,$line;
		$hash{$prID}= join($ndp_del,($prID,$chID,$taxon));
	}
	close $FH;

	return ($ndp_delr,$ndp_del,\%hash);
}

sub hierarchy_printer {
	my $self = shift ;
	my $out_file1_name 	= shift // 'outA.txt' ;
	my $isScientific_output = shift //  'false' 	;
	my $acc_tax_ref = shift // 'false' ;#update時に使用

=pod
	Description
	-----------
	AFI19405.1	80325|species	4015|genus	4014|family	41937|order	91836|no rank...
	AccessionID 最下層のtaxid|対応するタクソンから最上層のtaxid|対応するタクソンを出力する.

	Parameters
	-----------
	$out_file1_name : Descriptionで述べた内容を出力する.

	$isScientific_output :  デフォルトではtaxIDと対応するタクソンの組み合わせ
				で出力するがこのtaxIDを学名に変換して出力するかどうか.
				trueで出力、falseで出力しない.
	

=cut

	#my $old_taxid_hash_ref = $self->{old_taxid_hash} ;# taxidが更新されていないAcccessionIDを管理.			　

	#$acc_tax_ref = {"accessionID"=>"taxID"}を作成する
	if($acc_tax_ref eq 'false'){
		$acc_tax_ref= BimUtils
				->hash_key_del_val(
						$self->{accession_taxid_file},
						$self->{delimiter_of_accession_and_taxid}
					);
	}

	#nodes.dmpの解析
	my ($ndp_delr,$ndp_del,$node_parsed_href) = &node_dmp_parser($self);
	open my $OFH,">",${out_file1_name} or die "Can't open ${out_file1_name}\n" ;

	my $output_del = "\t" ;#outfile1_name(出力ファイル)で使用するデリミタ
	foreach my $accessionID (keys %${acc_tax_ref}){
		my $taxID = $acc_tax_ref->{$accessionID} ;

		#子の最下層までループして出力する
		my ($prID,$chID,$taxon)=('','','');
		my @outList = () ;
		my $out = '';
		while(1){
			if(exists $node_parsed_href->{$taxID}){
				($prID,$chID,$taxon)=split/${ndp_delr}/,$node_parsed_href->{$taxID};
				push @outList,join($ndp_del,($prID,$taxon)) ;#"$prID|$taxon"
			}else{
				$self->{old_taxid_hash}->{$accessionID} = $taxID;
				last;
			}
			$taxID = $chID;
			if($chID == 1){
				$out = join($output_del,@outList) ;
				print $OFH "${accessionID}\t${out}\n";
				@outList = ();
				last;
			}
		}
	}
	close $OFH;

	#更新されていないtaxidが存在する場合はリストで出力する.
	my $return_code = 'false';
	my $temp = $self->{old_taxid_hash};
	if(scalar(keys %$temp)){
		update_taxid_accession_file(
				$self,
				$acc_tax_ref
			);
		$return_code = 'true';
	}



	#taxidを学名に変換したファイルを出力する(オプションを選択した場合)
	my $out_file2_name = '';
	if($isScientific_output eq 'true'){
		#$out_file2_name : $isScieitific_outputが真の際に出力するファイル名
		print "\n" ;
		print "\n" ; 
		print " Enter the output filename : " ;

		$out_file2_name 	= <STDIN>;

		chomp($out_file2_name);
		
		print "\n";
		print " input OK.\n" ;
		print "\n";
		print " converting...";

		&toScie_name(
				$self,
				$out_file1_name,  #変換前のファイル（タクソンに対応するのがtaxid）のパス
				$ndp_delr,		  #taxidと対応するタクソンとのデリミタの正規表現
				$ndp_del,		  #taxidと対応するタクソンとのデリミタ
				$output_del,	  #AccessionIDに対応する全てのtaxid/タクソンを結びつけるデリミタ
				$out_file2_name   #taxid/タクソンを学名/タクソンに変換して出力するファイルパス
			);
	}
	return ($return_code,$acc_tax_ref,$out_file2_name);
}

sub update_taxid_accession_file {
	my $self	= shift;
	my $acc_tax_ref =	shift;

=pod
	Description
	-----------
	古いtaxidを新しいtaxidで置き換えてtaxid_accession_fileを
	再出力し,これをTaxonomyオブジェクトのメンバ変数にsetする.

	Parameters
	----------
	$acc_tax_ref : hash_ref = {'AccessionID'=>'taxonomyID'}

=cut


	#更新前・更新後は同じデリミタを使用する.
	my $delimiter = $self->{delimiter_of_accession_and_taxid}; 

=pod
	#AcccessionIDと変更後のtaxIDを連想配列で紐づけ
	open my $FH,"<",$new_taxid_file or die "Can't open the ${new_taxid_file}\n";
	my %acc_new = () ; #$hash{AccessionID} = newTaxiD
	my ($accessionID,$newTaxid)=('','') ;
	while(my $line=<$FH>){
		chomp $line;
		($accessionID,$_,$newTaxid) = split/${delimiter}/,$line;
		$acc_new{$accessionID} = $newTaxid;
	}
	close $FH;
=cut

=pod
	#AccessionIDと変更前のtaxIDを連想配列で紐づける際、
	my $acc_tax_ref= BimUtils
		->hash_key_del_val(
				$self->{accession_taxid_file},
				$self->{delimiter_of_accession_and_taxid}
			);
	my %acc_old = %{$acc_tax_ref}; #(AccessionID=>before_updated_taxID);
=cut

	#merged.dmpより，更新taxidリストを作成
	#update = (old_taxid->new_taxid);
	my $update = BimUtils->hash_key_del_val("./data/merged.dmp",'\s\|\s');
	
	#更新前taxIDのハッシュのリファレンス($self->{old_taxid_hash})
	#を$updateを利用して更新する.
	my ($old_taxid,$new_taxid) = ('','') ;
	foreach my $accid(keys %{$$self{old_taxid_hash_ref}}){
		$old_taxid = $self->{old_taxid_hash}->{$accid};
		$new_taxid = $update->{$old_taxid};

		#update %acc_tax
		$acc_tax_ref->{$accid} = $new_taxid;
	}

	hierarchy_printer()
	return $acc_tax_ref;

=pod	
	#更新後のAccessionID・taxidを出力する
	open my $OFH,">",${new_accession_taxid_file_path} or 
						die "Can't create new_accession_taxid_file\n";
	foreach my $acID (keys %acc_old){
		if(exists $acc_new{$acID}){
			print $OFH "${acID}\t$acc_new{$acID}\n";
		}else{
			print $OFH "${acID}\t$acc_old{$acID}\n";
		}
	}
	close $OFH;
=cut

	#メンバ変数(accession_taxid_file)を更新する
	#&accession_taxid_file_setter($self,${new_accession_taxid_file_path});

}

1;
