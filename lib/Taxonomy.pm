package Taxonomy;

use strict;
use warnings;
use BimUtils;

sub new {
	my $class = shift ;
	my $self = { @_ } ;
	bless $self,$class;
	$self->init();  
	return $self;
}

sub init {
	my $self = shift;

=pod
	Description
	-----------
	メンバ変数を初期化する

	Member
	------
	accession_taxid_file : 
		入力ファイルのパス　(カラムはuniqueIDとTaxonomyID)

	delimiter_of_accession_and_taxid : 
		上記のファイルのカラム間で使用しているデリミタ

	x_sci_del : 
		taxidと学名またはtaxonと学名を結びつける際に利用するデリミタ

	x_sci_del_regex : 
		x_sci_delの正規表現用のパターン

	old_taxid_hash : 
		更新前taxidが入力に含まれていた場合に値が追加される連想配列
	
	ac_tx_hash : 
		入力ファイルに含まれるAccessionIDとtaxidを結びつけた連想配列
	
=cut

	$self->{accession_taxid_file} //= 'none';
	$self->{delimiter_of_accession_and_taxid} //='none';
	$self->{nodes_dmp_file} //='none';
	$self->{names_dmp_file} //='none';
	$self->{x_sci_del_regex} = '\|';
	$self->{x_sci_del} = "|";

	
	my %old_taxid_hash = ();
	$self->{old_taxid_hash} = \%old_taxid_hash;

	$self->{ac_tx_hash} = BimUtils->hash_key_del_val(
		$self->{accession_taxid_file},
		$self->{delimiter_of_accession_and_taxid}
	);

	#指定の引数が入力されたかどうかの確認
	foreach my $t (keys %$self){
		if ($self->{$t} eq 'none'){
            #print "$t\n";
			print "Argument Error\n" ;
			exit;
		}
        
	}

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
	my $out_file_name = shift;

=pod
	Description
	------------
	taxidをscientificname(学名)に変換して出力.

	Parameters
	----------
	$original_file : 
		変換前のファイル（タクソンに対応するのがtaxid）のパス

	$out_file_name : 
		taxid/タクソンを学名/タクソンに変換して出力するファイルパス

=cut

	#names.dmpファイルからtaxIDと学名を連想配列で紐づける.
	my $hash_ref = name_dmp_parser($self);

	#taxid/タクソンのファイルから上記で紐づけた連想配列を利用し、
	# 学名/タクソンに変換して出力する.
	open my $FH,"<",${original_file} or die "Can't open the original_file!\n";
	open my $OFH,">",${out_file_name} or die "Can't create the ${out_file_name}\n" ;
	my $del1 = $self->{x_sci_del};
	my $delr = $self->{x_sci_del_regex};
	my ($accessionID,$taxid,$taxon,$tmp) = ('','','','');
	my $del2 = $self->{delimiter_of_accession_and_taxid};
	my @list = (); # (taxid/taxon taxid/taxon ...);
	while(my $line=<$FH>){
		chomp $line;
		($accessionID,@list)=split/$del2/,$line;
		$tmp = '' ;		
		foreach $_(@list){
			($taxid,$taxon)=split/$delr/,$_;
			$tmp .= $hash_ref->{$taxid}.${del1}.${taxon}.${del2};
		}
		print $OFH ${accessionID}.${del2}.$tmp."\n";
	}
	close $FH;
	close $OFH;

}

sub name_dmp_parser {
	my $self = shift;

=pod
	Description
	-----------
	names.dmpファイルからtaxIDと学名を連想配列で紐づける.

	Return
	------
	\%hash : 
		taxIDをキー、学名を値とする連想配列の参照

=cut

	open my $FH,"<",$self->{names_dmp_file} or die "Can't open names.dmp\n";
	my %hash=(); #hash{taxid}=対応するタクソンの学名
	my @node=();#(taxID,タクソンの学名,'識別子(scientific nameやtype material')
	my $names_dmp_del = '\|';
	while(my $line=<$FH>){
		chomp $line;
		@node = split/${names_dmp_del}/,$line;
		@node = map{$_ =~s/\t//g;$_}@node[0,1,3];
		if($node[2] eq 'scientific name'){
			$hash{$node[0]} = $node[1];
			next;
		}
	}
	close $FH;

	return \%hash;
}

sub node_dmp_parser {
	my $self = shift;

=pod
	Description
	-----------
	nodes.dmpファイルをパース

	Returns
	------
	$hash_ref : 
		keyは系統の親のtaxid,valueは文字列（"親taxid|子taxid|タクソン"）

=cut

	my %hash=();#%hash =(Parent_taxid=>"Parent_taxid|Child_taxid|Taxon(genus,sfamily...)");
	my $nodes_file_del = '\t\|\t';
	my ($prID,$chID,$taxon)=('','',''); # 1,1,no rank
	my $del1 = $self->{x_sci_del};
	open my $FH,"<",$self->{nodes_dmp_file} or die "Can't open nodes.dmp file\n";
	while(my $line=<$FH>){
		chomp $line;
		($prID,$chID,$taxon,@_)=split/${nodes_file_del}/,$line;
		$hash{$prID}= join($del1,($prID,$chID,$taxon));
	}
	close $FH;

	return \%hash;
}

sub hierarchy_printer {
	my $self = shift ;
	my $out_file1_name 	= shift // 'outA.txt' ;

=pod
	Description
	-----------
	AFI19405.1	80325|species	4015|genus	4014|family	41937|order	91836|no rank...
	AccessionID 最下層のtaxid|対応するタクソンから最上層のtaxid|対応するタクソンを出力する.

	Parameters
	-----------
	$out_file1_name : 
		Descriptionで述べた内容を出力するファイル名
	
	Return
	------
	$return_code :
		未更新のtaxidが存在する場合は"true"、存在しない
		場合は"false"を返却する.
		
=cut

	#nodes.dmpの解析
	my $node_parsed_href = &node_dmp_parser($self);
	open my $OFH,">",${out_file1_name} or die "Can't open ${out_file1_name}\n" ;

	foreach my $accessionID (keys %{$$self{ac_tx_hash}}){
		my $taxID = $self->{ac_tx_hash}->{$accessionID} ;

		#子の最下層までループして出力する
		my ($prID,$chID,$taxon,$out)=('','','','');
		my @outList = () ;
		my ($delr,$del1) = ($self->{x_sci_del_regex},$self->{x_sci_del});
		my $del2 = $self->{delimiter_of_accession_and_taxid} ;
		while(1){
			if(exists $node_parsed_href->{$taxID}){
				($prID,$chID,$taxon)=split/$delr/,$node_parsed_href->{$taxID};
				push @outList,join($del1,($prID,$taxon)) ;
			}else{
				$self->{old_taxid_hash}->{$accessionID} = $taxID;
				last;
			}
			$taxID = $chID;
			if($chID == 1){
				$out = join($del2,@outList) ;
				print $OFH ${accessionID}.${del2}.${out}."\n";
				@outList = ();
				last;
			}
		}
	}
	close $OFH;

	#未更新のtaxidが存在する場合は$self->{old_taid_hash}に登録
	my $return_code = 'false';
	my $temp = $self->{old_taxid_hash};
	if(scalar(keys %$temp)){
		$return_code = 'true';
	}

	return $return_code;
}

sub update_taxid_accession_file {
	my $self	= shift;

=pod
	Description
	-----------
	$self->{old_taxid_hash} に含まれている未更新のtaxonomyID
	からmerged.dmpを利用して更新後のtaxonomyIDを取得する。更新
	前のtaxidを値として保持するメンバ変数($self->{ac_tx_hash})
	の値を更新後のtaxonomyID に変更する.

=cut

	#merged.dmpより，更新taxidリストを作成
	#update = (old_taxid->new_taxid);
	my $func = sub {};#chompは行わない
	my $update = BimUtils->hash_key_del_val(
			"./data/merged.dmp",
			'\s\|\s',
			$func
		);

	#更新前taxIDのハッシュのリファレンス($self->{old_taxid_hash})
	#を$updateを利用して更新する.
	my ($old_taxid,$new_taxid) = ('','') ;
	foreach my $accid(keys %{$$self{old_taxid_hash}}){
		$old_taxid = $self->{old_taxid_hash}->{$accid};
		$new_taxid = $update->{$old_taxid};
		$self->{ac_tx_hash}->{$accid} = $new_taxid;
	}

}

1;
