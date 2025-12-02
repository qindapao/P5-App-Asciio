
package App::Asciio::String ;

require Exporter ;
@ISA = qw(Exporter) ;
@EXPORT = qw(
	unicode_length
	make_vertical_text
	get_us_keyboard_layout
	) ;

#-----------------------------------------------------------------------------

use strict ; use warnings ;
use utf8 ;

use App::Asciio::Markup ;

#-----------------------------------------------------------------------------

use Memoize ;
memoize('unicode_length') ;

#-----------------------------------------------------------------------------

sub unicode_length
{
my ($string) = @_ ;

$string = $USE_MARKUP_CLASS->delete_markup_characters($string) ;

my $east_asian_double_width_chars_cnt = grep {$_ =~ /\p{EA=W}|\p{EA=F}/} split('', $string) ;
my $nonspacing_chars_cnt = grep {$_ =~ /\p{gc:Mn}/} split('', $string) ;

return length($string) + $east_asian_double_width_chars_cnt - $nonspacing_chars_cnt ;
}

#-----------------------------------------------------------------------------

sub make_vertical_text
{
my ($text) = @_ ;

my @lines = map{[split '', $_]} split "\n", $text ;

my $vertical = '' ;
my $found_character = 1 ;
my $index = 0 ;

while($found_character)
	{
	my $line ;
	$found_character = 0 ;
	
	for(@lines)
		{
		if(defined $_->[$index])
			{
			$line.= $_->[$index] ;
			$found_character++ ;
			}
		else
			{
			$line .= ' ' ;
			}
		}
	
	$line =~ s/\s+$//; 
	$vertical .= "$line\n" if $found_character ;
	$index++ ;
	}

return $vertical ;
}

#-----------------------------------------------------------------------------
sub get_us_keyboard_layout
{
my ($keyboard_char_map, $keyboard_layout, $keyboard_keys) = @_ ;

# US keyboard
my @default_keys = qw(
	~ ! @ # $ % ^ & * ( ) _ +
	` 1 2 3 4 5 6 7 8 9 0 - =
	Q W E R T Y U I O P { } |
	q w e r t y u i o p [ ] \
	A S D F G H J K L : "
	a s d f g h j k l ; '
	Z X C V B N M < > ?
	z x c v b n m , . /
	) ;

my $default_keyboard_layout = <<END ;
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───────┐
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│BS     │
│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│       │
├───┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─┴─┬─────┤
│ Tab │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s  │
│     │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s  │
├─────┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴┬──┴─────┤
│  CL  │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│ Enter  │
│      │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│        │
├──────┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴──┬┴────────┤
│  Shift  │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│  Shift  │
│         │*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│*%s│         │
└─────────┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴─────────┘
END

$keyboard_keys     ||= \@default_keys ;
$keyboard_layout ||= $default_keyboard_layout ;

my @keyboard_keys_values = map {
	my $key   = $_ ;
	my $char  = $keyboard_char_map->{$key} // '' ;
	my $unicode_len = unicode_length($char);
	my $mapped = $unicode_len == 2 ? $char
		: $unicode_len == 1 ? " $char"
		: "  $char" ;
	($key, $mapped) ;
} @$keyboard_keys ;

$keyboard_layout =~ s/\*/%s/g ;
return sprintf($keyboard_layout, @keyboard_keys_values) ;
}

#-----------------------------------------------------------------------------

1 ;
