
package App::Asciio::GTK::Asciio::Pen ;

use App::Asciio::Actions::Elements ;
use App::Asciio::ZBuffer ;
use App::Asciio::String qw(unicode_length) ;
use App::Asciio::stripes::dot ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::String ;
use App::Asciio::Geometry qw(interpolate) ;

use utf8;

use strict ; use warnings ;

use List::Util qw(max min) ;
use List::MoreUtils qw(any first_value);

my @dot_elements_to_insert ;

my $overlay_element ;

my @pen_chars = ('?') ;
my @last_points;

my $char_index = 0 ;
my $char_num ;
my $is_eraser = 0 ;
my $last_char_lenth = 1;

my %direction_map = (
    'right'  => 'down',
    'down'   => 'static',
    'static' => 'right',
) ;

my %simulate_mouse_type_map = (
	'right' => 'right_triangle',
	'down'  => 'down_triangle',
	'static'=> 'rectangle',
) ;

my $mouse_emulation_move_direction = 'static' ;

my $pen_mode_enable = 0 ;
my $pen_show_mapping_location = 'left' ;

#----------------------------------------------------------------------------------------------
sub pen_switch_show_mapping_help_location
{
my ($asciio) = @_ ;

$pen_show_mapping_location = ($pen_show_mapping_location eq 'left') ? 'right' : 'left' ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_draw_mouse_cursor
{
my ($gc, $emulation_mouse_type, $character_width, $character_height, $start_x, $start_y) = @_ ;

if($emulation_mouse_type eq 'right_triangle')
	{
	$gc->move_to($start_x, $start_y);
	$gc->line_to($start_x + $character_width, $start_y + $character_height / 2);
	$gc->line_to($start_x, $start_y + $character_height);
	$gc->close_path();
	$gc->fill() ;
	$gc->stroke() ;
	}
elsif($emulation_mouse_type eq 'down_triangle')
	{
	$gc->move_to($start_x + $character_width / 2, $start_y + $character_height);
	$gc->line_to($start_x, $start_y);
	$gc->line_to($start_x + $character_width, $start_y);
	$gc->close_path();
	$gc->fill() ;
	$gc->stroke() ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_show_mapping_help
{
my ($asciio, $gc) = @_;

if ($pen_mode_enable && (scalar keys %{$asciio->{PEN_MODE_CHARS_SETS}->[0]}))
	{
	my ($prompt_background, $prompt_foreground) = ($asciio->get_color("prompt_background"), $asciio->get_color("prompt_foreground")) ;
	my $cache_key = $asciio->{PEN_MODE_CHARS_SETS}->[0] . '-' . $prompt_background . '-' . $prompt_foreground ;

	my $pen_randering_cache = $asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$cache_key} ;

	my ($window_width, $window_height) = $asciio->{ROOT_WINDOW}->get_size() ;
	my ($scroll_bar_x, $scroll_bar_y)  =
		($asciio->{SC_WINDOW}->get_hadjustment()->get_value(),
		$asciio->{SC_WINDOW}->get_vadjustment()->get_value()) ;

	my ($overlay_location_x, $overlay_location_y) = ($scroll_bar_x, $scroll_bar_y) ;

	unless (defined $pen_randering_cache)
		{
		my $dummy_surface = Cairo::ImageSurface->create('argb32', 1, 1);
		my $dummy_context = Cairo::Context->create($dummy_surface);

		my $current_mapping_group = $asciio->{PEN_MODE_CHARS_SETS}->[0];

		my $layout = Pango::Cairo::create_layout($dummy_context);
		my $font_family = "sarasa mono sc, $asciio->{FONT_FAMILY}" ;
		my $font_description = Pango::FontDescription->from_string("$font_family 12") ;
		$layout->set_font_description($font_description);

		my $keyboard_ascii = get_us_keyboard_layout($current_mapping_group, $asciio->{PEN_MODE_KEYBOARD_LAYOUT}, $asciio->{PEN_MODE_KEYBOARD_KEYS}) ;
		$layout->set_text($keyboard_ascii);

		# my ($text_w, $text_h) = $layout->get_pixel_size();
		my ($ink_rect, $logical_rect) = $layout->get_extents() ;
		my $text_w = $ink_rect->{width}  / Pango::SCALE ;
		my $text_h = $ink_rect->{height} / Pango::SCALE ;

		my $surface = Cairo::ImageSurface->create('argb32', $text_w, $text_h);
		my $gco     = Cairo::Context->create($surface);

		# background
		$gco->set_source_rgba(@{$prompt_background}) ;
		$gco->rectangle(0, 0, $surface->get_width(), $surface->get_height());
		$gco->fill ;

		my $layout2 = Pango::Cairo::create_layout($gco);
		$layout2->set_font_description($font_description);
		$layout2->set_text($keyboard_ascii);

		$gco->set_source_rgba(@{$prompt_foreground});
		$gco->move_to(0, 0) ;
		Pango::Cairo::show_layout($gco, $layout2);

		$asciio->{CACHE}{PEN_CHARS_MAPPING_RENDERING_CACHE}{$cache_key}
			= $pen_randering_cache = $surface ;
		}

	my $width  = $pen_randering_cache->get_width() ;

	if ($pen_show_mapping_location eq 'right')
		{
		$overlay_location_x = max($scroll_bar_x, $scroll_bar_x + $window_width - $width) ;
		}

	$gc->set_source_surface($pen_randering_cache, $overlay_location_x, $overlay_location_y) ;
	$gc->paint ;
	$gc->stroke();
	}
}

#----------------------------------------------------------------------------------------------
sub pen_switch_next_character_sets
{
my ($asciio) = @_ ;

push @{$asciio->{PEN_MODE_CHARS_SETS}}, shift @{$asciio->{PEN_MODE_CHARS_SETS}} ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_switch_previous_character_sets
{
my ($asciio) = @_ ;

unshift @{$asciio->{PEN_MODE_CHARS_SETS}}, pop @{$asciio->{PEN_MODE_CHARS_SETS}} ;
$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_set_overlay
{
my ($asciio) = @_;

if($is_eraser)
	{
	$overlay_element = Clone::clone(App::Asciio::stripes::dot->new({TEXT => ' ', NAME => 'dot'})) ;
	}
else
	{
	$overlay_element = Clone::clone($dot_elements_to_insert[$char_index]) ;
	}

$asciio->set_element_position($overlay_element, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;

}

#----------------------------------------------------------------------------------------------

sub pen_create_clone_elements
{
my ($asciio, @chars) = @_ ;

@dot_elements_to_insert = ();
$char_index = 0 ;

for my $char (@chars)
	{
	push @dot_elements_to_insert, Clone::clone(App::Asciio::stripes::dot->new({TEXT => $char, NAME => 'dot'})) ;
	}
$char_num = $#dot_elements_to_insert + 1;
}

#----------------------------------------------------------------------------------------------
sub pen_get_overlay
{
my ($asciio, $UI_type, $gc, $widget_width, $widget_height, $character_width, $character_height) = @_;
$asciio->set_element_position($overlay_element, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;

$overlay_element ;
}

#----------------------------------------------------------------------------------------------
sub pen_custom_mouse_cursor
{
my ($asciio) = @_ ;

$asciio->change_cursor(($is_eraser) ? 'icon' : 'xterm') ;
}

#----------------------------------------------------------------------------------------------
sub pen_set_overlays_sub
{
my ($asciio) = @_ ;

if($is_eraser || ($asciio->{SIMULATE_MOUSE_TYPE} eq 'rectangle'))
	{
	pen_set_overlay($asciio) ;
	$asciio->set_overlays_sub(\&pen_get_overlay) ;
	}
else
	{
	$asciio->set_overlays_sub(undef) ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_change_char
{
my ($asciio) = @_;
pen_enter($asciio, undef, 1, $mouse_emulation_move_direction) ;
}

#----------------------------------------------------------------------------------------------
sub pen_eraser_switch
{
my ($asciio) = @_ ;

$is_eraser ^= 1 ;

pen_custom_mouse_cursor($asciio) ;
pen_set_overlays_sub($asciio) ;
$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub eraser_enter
{
my ($asciio) = @_ ;

$is_eraser = 1 ;

pen_enter($asciio, undef, 1) ;
}

#----------------------------------------------------------------------------------------------
sub pen_enter_then_move_mouse
{
my ($asciio, $chars) = @_ ;

$asciio->create_undo_snapshot() ;
pen_enter($asciio, $chars, undef, $mouse_emulation_move_direction, 1) ;
}

#----------------------------------------------------------------------------------------------
sub toggle_mouse_emulation_move_direction ()
{
my ($asciio) = @_ ;

$mouse_emulation_move_direction = $direction_map{$mouse_emulation_move_direction} ;
$asciio->{SIMULATE_MOUSE_TYPE} = $simulate_mouse_type_map{$mouse_emulation_move_direction} ;
$asciio->update_display() ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_enter
{
my ($asciio) = @_ ;

$asciio->{MOUSE_TOGGLE} = 1 ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
$asciio->{SIMULATE_MOUSE_TYPE} = $simulate_mouse_type_map{$mouse_emulation_move_direction} ;
pen_enter($asciio) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_escape
{
my ($asciio) = @_ ;

$asciio->{MOUSE_TOGGLE} = 0 ;
pen_escape($asciio) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_space
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [$last_char_lenth, 0] 
		: [0, $last_char_lenth]) ;
}


#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left_tab
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [-4, 0] 
		: [0, -4]) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right_tab
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

App::Asciio::Actions::Mouse::mouse_move(
	$asciio, 
	$mouse_emulation_move_direction eq 'right' 
		? [4, 0] 
		: [0, 4]) ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-$last_char_lenth, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right
{
my ($asciio) = @_ ;

App::Asciio::Actions::Mouse::mouse_move($asciio, [$last_char_lenth, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_up
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_down
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 1]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_up_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, -4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_down_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [0, 4]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_right_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#---------------------------------------------------------------------------------------------
sub pen_mouse_emulation_move_left_quick
{
my ($asciio) = @_ ;
App::Asciio::Actions::Mouse::mouse_move($asciio, [-4, 0]) ;
$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#----------------------------------------------------------------------------------------------
sub pen_enter
{
my ($asciio, $chars, $no_selected_elements, $mouse_move_direction, $is_key_char) = @_;

$pen_mode_enable = 1;

# custom mouse cursor
pen_custom_mouse_cursor($asciio) ;

my @get_chars ;

if(defined $chars)
	{
	if($is_key_char && exists $asciio->{PEN_MODE_CHARS_SETS}->[0]->{$chars->[0]})
		{
		@pen_chars = $asciio->{PEN_MODE_CHARS_SETS}->[0]->{$chars->[0]} ;
		}
	else
		{
		@pen_chars = @{$chars} ;
		}
	}
else
	{
	if($asciio->get_selected_elements(1) && (!defined $no_selected_elements))
		{
		my $select_elements_zbuffer = App::Asciio::ZBuffer->new(0, $asciio->get_selected_elements(1)) ;
		for my $key (sort {
			my ($ay, $ax) = split /;/, $a;
			my ($by, $bx) = split /;/, $b;
			$ay <=> $by || $ax <=> $bx
			} keys %{$select_elements_zbuffer->{coordinates}})
			{
			my $value = $select_elements_zbuffer->{coordinates}{$key};
			next if $value =~ /^\s*$/;
			push @get_chars, $value;
			}
		}
	else
		{
		my $current_point = $asciio->{MOUSE_Y} . ';' . $asciio->{MOUSE_X} ;
		my ($first_element) = first_value {$asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y})} reverse @{$asciio->{ELEMENTS}} ;
		my $current_char ;
		if($first_element)
			{
			$current_char = App::Asciio::ZBuffer->new(0, $first_element)->{coordinates}{$current_point} // ' ' ;
			}
		else
			{
			$current_char = ' ' ;
			}
		push @get_chars, $current_char unless $current_char =~ /^\s*$/ ;
		}
	@pen_chars = @get_chars if @get_chars ;
	}

pen_create_clone_elements($asciio, @pen_chars) ;

pen_set_overlays_sub($asciio) ;

if(defined $chars)
	{
	pen_add_or_delete_element($asciio, $mouse_move_direction) ;
	}
else
	{
	$asciio->update_display ;
	}
}

#----------------------------------------------------------------------------------------------

sub pen_escape
{
my ($asciio, $is_eraser_escape) = @_;

$is_eraser = 0 if $is_eraser_escape ;

$asciio->set_overlays_sub(undef);
$asciio->change_cursor('left_ptr');

$pen_mode_enable = 0 ;

$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub pen_mouse_motion
{
my ($asciio, $event) = @_;

my ($x, $y) = @{$event->{COORDINATES}}[0,1] ;

($asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}) = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ;
($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($asciio->{PREVIOUS_X} != $x || $asciio->{PREVIOUS_Y} != $y))
	{
	$asciio->set_overlays_sub(undef);
	my @points = interpolate(
		$asciio->{PREVIOUS_X}, $asciio->{PREVIOUS_Y}, $x, $y,
		sub { $is_eraser ? 1 : unicode_length($pen_chars[($char_index+shift) % $char_num - 1]) },
		1,
		\@last_points
		);
	
	for my $point (@points)
		{
		next if any { $_->[0] == $point->[0] && $_->[1] == $point->[1] } @last_points ;
		($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = @$point ;
		pen_add_or_delete_element($asciio) ;
		}
	@last_points = @points ;
	}

if($event->{STATE} ne 'dragging-button1')
	{
	@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]);
	pen_set_overlays_sub($asciio) ;
	}
$asciio->update_display ;
}

#----------------------------------------------------------------------------------------------
sub pen_add_or_delete_element
{
my ($asciio, $mouse_move_direction) = @_ ;
if($is_eraser)
	{
	pen_delete_element($asciio) ;
	}
else
	{
	pen_add_element($asciio, $mouse_move_direction) ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_emulation_press_enter_key
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE})
{
if($mouse_emulation_move_direction eq 'right')
	{
	($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[0], $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[1] + 1) ;
	}
else
	{
	($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) = ($asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[0] + 1, $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}->[1]) ;
	}
$asciio->update_display() ;
}

$asciio->{MOUSE_EMULATION_FIRST_COORDINATE} = undef ;
}

#----------------------------------------------------------------------------------------------
sub pen_add_element
{
my ($asciio, $mouse_move_direction) = @_ ;

my $add_dot = Clone::clone($dot_elements_to_insert[$char_index]) ;
$last_char_lenth = unicode_length($pen_chars[$char_index]) ;

@$add_dot{'X', 'Y', 'SELECTED'} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}, 0) ;

# If there are one or more dot elements below the current coordinate, delete it.
# :TODO: It’s more time consuming here
pen_delete_element($asciio, 1) ;

$asciio->add_elements($add_dot);
$char_index = ($char_index + 1) % $char_num ;
@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]);

@{$asciio->{MOUSE_EMULATION_FIRST_COORDINATE}} = ($asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) unless(defined $asciio->{MOUSE_EMULATION_FIRST_COORDINATE}) ;

mouse_move_forward($asciio) if($mouse_move_direction) ;

$asciio->update_display() ;
}

#----------------------------------------------------------------------------------------------
sub pen_delete_element
{
my ($asciio, $dot_delete_only) = @_ ;

my @elements ;

if($dot_delete_only)
	{
	@elements = grep { ( ref($_) eq 'App::Asciio::stripes::dot' )  
					   && ( $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) ) } reverse @{$asciio->{ELEMENTS}} ;
	}
else
	{
	@elements = grep { $asciio->is_over_element($_, $asciio->{MOUSE_X}, $asciio->{MOUSE_Y}) } reverse @{$asciio->{ELEMENTS}} ;
	}

if(@elements)
	{
	$asciio->delete_elements(@elements) ;

	@last_points = ([$asciio->{MOUSE_X}, $asciio->{MOUSE_Y}]) ;
	$asciio->update_display();
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_move_forward
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if($mouse_emulation_move_direction eq 'down')
	{
	$asciio->{MOUSE_Y}++ ;
	}
else
	{
	$asciio->{MOUSE_X} += $last_char_lenth ;
	}
}

#----------------------------------------------------------------------------------------------
sub mouse_move_backward
{
my ($asciio) = @_ ;

return if $mouse_emulation_move_direction eq 'static' ;

if($mouse_emulation_move_direction eq 'down')
	{
	$asciio->{MOUSE_Y}-- ;
	}
else
	{
	$asciio->{MOUSE_X}-- ;
	}
}

#----------------------------------------------------------------------------------------------
sub pen_back_delete_element
{
my ($asciio, $dot_delete_only) = @_ ;

mouse_move_backward($asciio) ;
pen_delete_element($asciio, $dot_delete_only) ;
}

#----------------------------------------------------------------------------------------------

1 ;

