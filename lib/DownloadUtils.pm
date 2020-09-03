package DownloadUtils;

use strict;
use warnings;
use LWP::Simple;
use Archive::Zip;

sub download {

	#ファイルの保存場所を確保
	my $todir  = './data' ;
	unless(-d $todir){
		mkdir $todir;
	}
	
	#taxdmp.zipを$setdir直下に保存する.	
	my $ftp_url = 'https://ftp.ncbi.nih.gov/pub/taxonomy/taxdmp.zip' ;
	_fetch_from_ftp($ftp_url,$todir);

	#taxdmp.zipを解凍してnode.dmpとnames.dmpを取り出す
	print " decompressing now...\n" ;
	_decompress("${todir}/taxdmp.zip",$todir,1);

}

sub download_merged {

	#ファイルの保存場所を確保
	my $todir  = './data' ;
	unless(-d $todir){
		mkdir $todir;
	}
	
	if(-f "${todir}/taxdmp.zip"){
		#Do not download from NCBI .
	}else{
		#taxdmp.zipを$setdir直下に保存する.	
		my $ftp_url = 'https://ftp.ncbi.nih.gov/pub/taxonomy/taxdmp.zip' ;
		_fetch_from_ftp($ftp_url,$todir);
	}

	#taxdmp.zipを解凍してmerged.dmpを取り出す
	print " decompressing now...\n" ;
	_decompress("${todir}/taxdmp.zip",$todir,2);

}

sub _fetch_from_ftp {
	my $url = shift; #ncbiのftpのurl
	my $todir = shift; #ダウンロードしたファイルの保存場所
	getstore($url,"${todir}/taxdmp.zip") ;
}

sub _decompress {
	my $zipfile = shift; #解凍するzipファイル
	my $todir   = shift; #解凍したnames.dmp,nodes.dmpの保存場所
	my $filek   = shift; #1->names.dmp/node.dmp 2->merged.dmp;

	my $zip = Archive::Zip->new($zipfile);	
	my @members  = $zip->memberNames();

	#node.dmpとnames.dmp,またはmerged.dmp のみ
	foreach $_(@members){
		if($filek==1){
			if($_=~/^names\.dmp$/ || $_=~/^nodes.dmp$/){
				$zip->extractMember($_,"${todir}/$_");
			}
		}elsif($filek==2){
			if($_=~/^merged\.dmp$/){
				$zip->extractMember($_,"${todir}/$_");
			}
		}
	}
}

1;
