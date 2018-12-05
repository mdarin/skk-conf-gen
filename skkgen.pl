#!/usr/bin/perl -w
use warnings;
use strict;

# VERSION 0.5

die "Usage: cmd infile\n"
	if (1 > @ARGV);

my $finame = shift(@ARGV);

open my $fin, "<$finame"
	or die "Can't open $finame file:$!";

open my $fout, ">temp.js"
	or die "Can't open temp.txt file: $!";

my $autogen = q(WARNING!AUTOMATICALY GENERATED CODE
DO NO MODIFY THE CODE MANUALY IF YOU DO NOT
EXACTLY KNOW WHAT YOU ARE REALY DOING!
IT IS BETTER TO RECONFIGURE SKK CONFIG FILE
AND RESTART CONFIGIRATOR AGAIN.
CONFIGURATOR VER 0.5);

my $stack = [()];
my $lineno = 1;
my $offset = "\t";
my $level = 1;

# Transitions table
# 		 to 
# from	d	r b m		  
#		d		*	*
#		r		*	*	*
#		b		*	*	*	*
#		m		*	*	*	*

# $trans_table->{$from$to} = sub { ..action..};
# &{$trans_table->{$from$to}} ($from, $to, $content); 
my $empty = '""';
my $from = "";
my $to = "";
my $trans_tab = {
	# [from][to]	
	"d" => sub {  
		# action
		my($from, $to, $content) = @_;  
		print " [$from] -> [$to] START\n";  
		$level++;
		#print $fout ($offset x $level) . "<device [$content]>\n";
		$content = '""'
			unless $content; 
		print $fout ($offset x $level) . " \"$content\" : {\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		push (@$stack, $to); 
		$to;  
	},
	"dd" => sub {  
		my($from, $to, $content) = @_;  
		print " [$from] -> [$to] LOOP\n";
		#print $fout ($offset x $level) . "</device>\n";   
		#print $fout ($offset x $level) . "<device [$content]>\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . "},/*dev*/\n";
		$content = '""'
			unless $content;   
		print $fout ($offset x $level) . " \"$content\" : {\n";
		$to;  
	},
	"dr" => sub {
		my($from, $to, $content) = @_; 
		print " [$from] -> [$to]\n";
		$level++;
		#print $fout ($offset x $level) . "<racks>\n";
		print $fout ($offset x $level) . " \"racks\" : {\n";	
		$level++;
		#print $fout ($offset x $level) . "<rack [$content]>\n";
		$content = '""'
			unless $content;
		print $fout ($offset x $level) . " \"$content\" : {\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		push (@$stack, $to);
		$to;  
	},
	"rd" => sub {
		my($from, $to, $content) = @_;
		print " [$from] -> [$to]\n";
		#print $fout ($offset x $level) . "</rack>\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*rck*/\n";
		$level--;
		#print $fout ($offset x $level) . "</racks>\n";
		print $fout ($offset x $level) . "},/*rcks* \n";
		$level--;
		pop @$stack;
		$to;  
	},
	"rr" => sub {
		my($from, $to, $content) = @_; 
		print " [$from] -> [$to] LOOP\n";
		#print $fout ($offset x $level) . "</rack>\n";
		#print $fout ($offset x $level) . "<rack>\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . "},/*rck*/\n";
		$content = '""'
			unless $content;
		print $fout ($offset x $level) . " \"$content\" : {\n";
		$to;
	},
	"rb" => sub {
		my($from, $to, $content) = @_; 
		print " [$from] -> [$to] LOOP\n";
		$level++;
		#print $fout ($offset x $level) . "<blocks>\n";
		print $fout ($offset x $level) . " \"blocks\" : {\n";
		$level++;
		#print $fout ($offset x $level) . "<block [$content]>\n";
		$content = '""'
			unless $content;
		print $fout ($offset x $level) . " \"$content\" : {\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		push (@$stack, $to);
		$to;
	},
	"br" => sub {
		my($from, $to, $content) = @_;
		print " [$from] -> [$to]\n";
		#print $fout ($offset x $level) . "</block>\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*blck*/\n"; 
		$level--;
		#print $fout ($offset x $level) . "</blocks>\n";
		print $fout ($offset x $level) . "},/*blcks*/\n";
		$level--;
		pop @$stack;
		$to;
	},
	"bb" => sub {
  	my($from, $to, $content) = @_;
		print " [$from] -> [$to] LOOP\n";
		#print $fout ($offset x $level) . "</block>\n";
		#print $fout ($offset x $level) . "<block [$content]>\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*blck*/\n";
		$content = '""'
			unless $content;
		print $fout ($offset x $level) . " \"$content\" : {\n";
		$to;
	},
	"bd" => sub {
  	my($from, $to, $content) = @_;
		print " [$from] -> [$to]\n";
		#print $fout ($offset x $level) . "</block>\n";
		#print $fout ($offset x $level) . "<block [$content]>\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*blck*/\n"; 
		$level--;
		#print $fout ($offset x $level) . "</blocks>\n";
		print $fout ($offset x $level) . "},/*blcks*/\n";
		$level--;
		pop @$stack;
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*rck*/\n";
		$level--;
		#print $fout ($offset x $level) . "</racks>\n";
		print $fout ($offset x $level) . "},/*rcks* \n";
		$level--;
		pop @$stack;
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*dev*/\n";
		$content = '""'
			unless $content;   
		print $fout ($offset x $level) . " \"$content\" : {\n";  
		$to;
	},
	"bm" => sub {
		my($from, $to, $content) = @_; 
		print " [$from] -> [$to]\n";
		$level++;
		#print $fout ($offset x $level) . "<modules>\n";
		print $fout ($offset x $level) . " \"modules\" : {\n";
		$level++;
		#print $fout ($offset x $level) . "<module [$content]>\n";
		$content = '""'
			unless $content;
		print $fout ($offset x $level) . " \"$content\" : {\n";
		
		push (@$stack, $to);
		$to;
	},
	"mb" => sub {
		my($from, $to, $content) = @_;
		print " [$from] -> [$to]\n";
		#print $fout ($offset x $level) . "</module>\n";
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		print $fout ($offset x $level) . "},/*mod*/\n";
		$level--;
		#print $fout ($offset x $level) . "</modules>\n";
		print $fout ($offset x $level) . "},/*mods*/\n";
		$level--;
		pop @$stack;
		#print $fout "--------------------------------------\n";
		print $fout ($offset x $level) . "},/*blck*/\n";
		print $fout ($offset x $level) . " \"$content\" : {\n";
		print $fout ($offset x ($level+1)) . " \"properties\" : {\n";
		&properties ($fout, $level+2);
		print $fout ($offset x ($level+1)) . "},/*prps*/\n";
		$to;
	},
	"mm" => sub {
		my($from, $to, $content) = @_;
		print " [$from] -> [$to] LOOP\n";
		#print $fout ($offset x $level) . "</module>\n";
		#print $fout ($offset x $level) . "<module [$content]>\n";
		$content = '""'
			unless $content;
		#print $fout ($offset x $level) . "$empty\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		
		print $fout ($offset x $level) . " \"functions\" : {\n";
		&functions ($fout, $level+1);
		print $fout ($offset x $level) . "},/*funs*/\n";

		print $fout ($offset x $level) . " \"channels\" : {\n";
		&channels ($fout, $level+1);
		print $fout ($offset x $level) . "},/*chns*/\n";

		print $fout ($offset x $level) . "},/*mod*/\n";
		print $fout ($offset x $level) . " \"$content\" : {\n";
		print $fout ($offset x $level) . " \"properties\" : {\n";
		&properties ($fout, $level+1);
		print $fout ($offset x $level) . "},/*prps*/\n";
		
		print $fout ($offset x $level) . " \"functions\" : {\n";
		&functions ($fout, $level+1);
		print $fout ($offset x $level) . "},/*funs*/\n";

		print $fout ($offset x $level) . " \"channels\" : {\n";
		&channels ($fout, $level+1);
		print $fout ($offset x $level) . "},/*chns*/\n";
		$to;
	},
};


print $fout "/*$autogen*/\n\n";
print $fout "/* CONFIG VERSION 0.4 */\n";
#print $fout ($offset x $level) . "var Config = { \"devices\" : \n";
print $fout "var Config = { \"devices\" : {\n";

while (<$fin>) {
	chomp;
	# пример из книжки
	# my $last_name = $last_name{$someone} || '(No last name)';
	my($tag, $content) = m/(\w)\s+(.+)/;# || ("NO_TAG", "NO_CONTENT");
	($tag, $content) = qw(NO_TAG NO_CONTENT)
		unless $tag;
	next if ($tag eq "NO_TAG");		
	$to = $tag;
	if ($trans_tab->{"$from$to"}) {
		$from = &{$trans_tab->{"$from$to"}} ($from, $to, $content);
	} else {
		print STDERR " error[$lineno]: Unxpected tag: [$tag] in line: \'$tag $content\'!\n";
	}
	$lineno ++;	
}
#
# закрыть пдвал  
#
foreach my $i (1..@$stack) {
	if ("m" eq $stack->[-$i]) {
		#print $fout ($offset x $level) . "</module>\n";
		print $fout ($offset x $level) . "},/*mod*/\n";
		$level--;
		#print $fout ($offset x $level) . "</modules>\n";
		print $fout ($offset x $level) . "},/*mods*/\n";
		$level--;
	} elsif ("b" eq $stack->[-$i]) {
		#print $fout ($offset x $level) . "</block>\n";
		print $fout ($offset x $level) . "},/*blck*/\n";	
		$level--;
		#print $fout ($offset x $level) . "</blocks>\n";
		print $fout ($offset x $level) . "},/*blcks>*/\n";
		$level--;
	} elsif ("r" eq $stack->[-$i]) {
		#print $fout ($offset x $level) . "</rack>\n";
		print $fout ($offset x $level) . "},/*rck*/\n";
		$level--;
		#print $fout ($offset x $level) . "</racks>\n";
		print $fout ($offset x $level) . "},/*rcks*/\n";
		$level--;
	} elsif ("d" eq $stack->[-$i]) {
		#print $fout ($offset x $level) . "</device>\n";
		print $fout ($offset x $level) . "},/*dev*/\n";
		$level--;
	}
}

#print $fout ($offset x $level) . "</devices>\n";
#print $fout "</config>\n";
print $fout ($offset x $level) . "},/*devs*/\n";
print $fout "};/*config*/\n";

close $fout;
close $fin;


sub properties {
	my($fout, $level) = @_;
	print $fout ($offset x $level) . " \"Состояние\" : \"Норама\",\n";
	print $fout ($offset x $level) . " \"Контрольная сумма ПО\" : \"920289\",\n";
	print $fout ($offset x $level) . " \"Дата сборки ПО\" :\"675876387\",\n";
	print $fout ($offset x $level) . " \"Дата сборки ПО\" :\"823745687\",\n";
	print $fout ($offset x $level) . " \"Разрешение управления с пульта\" : \"Запрещено\",\n";
	print $fout ($offset x $level) . " \"Протокол\" :\"Предупреждающий\",\n";
	print $fout ($offset x $level) . " \"Сигнализация\" :\"Отключена\",\n";
	print $fout ($offset x $level) . " \"Модуль обслуживания коммутаций\" :\"mon\",\n";
	print $fout ($offset x $level) . " \"Модуль обслуживания пульта\" :\"Нет\",\n";
	print $fout ($offset x $level) . " \"Уровень протоколирования\" :\"0\", \n";
}


sub functions {
	my($fout, $level) = @_;
	print $fout ($offset x $level) . " \"sey\" : function() { \"Hello yet another cool hacker!\"},\n";
}

sub channels {
	my($fout, $level) = @_;
	print $fout ($offset x $level) . "\"channel name 1\" : {\n";
	print $fout ($offset x $level) . " \"properties\" : {\n";
	&properties ($fout, $level+1);
	print $fout ($offset x $level) . "},/*prps*/},\n";
}

#__END__
#two good samples generated from the book of psalms:
#
#"For, lo, thine enemies, and the horn of David the son of
#thine house hath eaten me up"#
#
#
#"His mouth is full of troubles"


