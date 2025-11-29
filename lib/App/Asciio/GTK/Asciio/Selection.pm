
package App::Asciio::GTK::Asciio ;

use strict ; use warnings ;

use App::Asciio::ZBuffer ;

my %selected_elements ;

#----------------------------------------------------------------------------------------------

sub draw_polygon_selection
{
my ($self, $gc, $character_width, $character_height) = @_ ;

$gc->set_source_rgb(@{$self->get_color('selection_rectangle')});

$gc->move_to($self->{SELECTION_POLYGON}[0][0] * $character_width, $self->{SELECTION_POLYGON}[0][1] * $character_height);
for my $point (@{$self->{SELECTION_POLYGON}})
	{
	$gc->line_to($point->[0] * $character_width, $point->[1] * $character_height);
	}

# draw solid line
$gc->stroke();

$gc->set_dash(0, 1, 4);
$gc->move_to($self->{SELECTION_POLYGON}[0][0] * $character_width, $self->{SELECTION_POLYGON}[0][1] * $character_height);
$gc->line_to($self->{SELECTION_POLYGON}[-1][0] * $character_width, $self->{SELECTION_POLYGON}[-1][1] * $character_height);
$gc->close_path();

# draw dotted line
$gc->stroke();
$gc->set_dash(0);
}

#----------------------------------------------------------------------------------------------

sub draw_rectangle_selection
{
my ($self, $gc, $character_width, $character_height) = @_ ;

my $start_x = $self->{SELECTION_RECTANGLE}{START_X} * $character_width ;
my $start_y = $self->{SELECTION_RECTANGLE}{START_Y} * $character_height ;

my $width   = ($self->{SELECTION_RECTANGLE}{END_X} - $self->{SELECTION_RECTANGLE}{START_X}) * $character_width ;
my $height  = ($self->{SELECTION_RECTANGLE}{END_Y} - $self->{SELECTION_RECTANGLE}{START_Y}) * $character_height; 

if($width < 0)
	{
	$width *= -1 ;
	$start_x -= $width ;
	}
	
if($height < 0)
	{
	$height *= -1 ;
	$start_y -= $height ;
	}
	
$gc->set_source_rgb(@{$self->get_color('selection_rectangle')}) ;
$gc->rectangle($start_x, $start_y, $width, $height) ;
$gc->stroke() ;

delete $self->{SELECTION_RECTANGLE}{END_X} ;
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_enter
{
my ($self) = @_ ;

$self->change_cursor('dot') ;
%selected_elements = () ;
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_escape
{
my ($self) = @_ ;

$self->{SELECTION_POLYGON} = [] ;
$self->change_cursor('left_ptr') ;
}

#-----------------------------------------------------------------------------

sub polygon_selection
{
my ($self, $select_type) = @_ ;

my @polygon_x = map {$_->[0]} @{$self->{SELECTION_POLYGON}} ;
my @polygon_y = map {$_->[1]} @{$self->{SELECTION_POLYGON}} ;
my ($polygon_min_x, $polygon_min_y, $polygon_max_x, $polygon_max_y) = (min(@polygon_x), min(@polygon_y), max(@polygon_x), max(@polygon_y)) ;

my (@elements_to_be_selected, @elements_to_be_inverse_selected) ;

for my $element (@{$self->{ELEMENTS}})
	{
	# :QQ: Strategy for synchronizing rectangular selection. Arrows cannot be selected by default.
	next if(ref($element) =~ /arrow/ && !$self->{DRAG_SELECTS_ARROWS}) ;
	
	# :QQ: This is just to speed up the judgment. If the extreme value rectangle
	#	of the element and the extreme value rectangle of the polygon
	#	selection box do not intersect,
	#	Then this element can be filtered directly to avoid subsequent heavy calculations.
	#	Before doing this, check whether the element was previously in the
	#	selected set. If so, it needs to be removed.
	my ($emin_x, $emin_y, $emax_x, $emax_y) = @{ $element->{EXTENTS} } ;
	if		(($polygon_max_x < $emin_x + $element->{X})
		||	 ($polygon_min_x > $emax_x + $element->{X})
		||	 ($polygon_max_y < $emin_y + $element->{Y})
		||	 ($polygon_min_y > $emax_y + $element->{Y}))
		{
		if(exists($selected_elements{$element}))
			{
			push @elements_to_be_inverse_selected, $element ;
			delete $selected_elements{$element} ;
			}
		# :QQ: There is no need to make the following judgments, just skip directly.
		next ;
		}

	unless(exists $element->{CACHE}{SELECTION_COORDINATES})
		{
		my @element_all_coordinates = map { [split ';'] } keys %{App::Asciio::ZBuffer->new(0, $element)->{coordinates}} ;
		@element_all_coordinates = map{ [reverse @$_]} @element_all_coordinates ;
		$element->{CACHE}{SELECTION_COORDINATES} = \@element_all_coordinates ;
		}

	if(all_points_in_polygon($element->{CACHE}{SELECTION_COORDINATES}, $self->{SELECTION_POLYGON}))
		{
		unless (exists $selected_elements{$element})
			{
			push @elements_to_be_selected, $element ;
			$selected_elements{$element} = 1 ;
			}
		}
	else
		{
		if(exists($selected_elements{$element}))
			{
			push @elements_to_be_inverse_selected, $element ;
			delete $selected_elements{$element} ;
			}
		}
	}

# :QQ: The biggest performance bottleneck of the previous sub was calling select_elements in the element loop.
#	Causes the sub to be called once for each element.
#	Now it only needs to be called once, and the performance is improved exponentially!
$self->select_elements($select_type, @elements_to_be_selected) if (@elements_to_be_selected) ;
$self->select_elements(!$select_type, @elements_to_be_inverse_selected) if (@elements_to_be_inverse_selected) ;
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_motion
{
# $select_type 
# 1: select
# 0: deselect
my ($self, $select_type, $event) = @_;

my ($x, $y) = @{$event->{COORDINATES}}[0,1] ;

($self->{PREVIOUS_X}, $self->{PREVIOUS_Y}) = ($self->{MOUSE_X}, $self->{MOUSE_Y}) ;
($self->{MOUSE_X}, $self->{MOUSE_Y})       = ($x, $y) ;

if($event->{STATE} eq 'dragging-button1' && ($self->{PREVIOUS_X} != $x || $self->{PREVIOUS_Y} != $y))
	{
	if(@{$self->{SELECTION_POLYGON} // []} == 0)
		{
		%selected_elements = () ;
		$self->{SELECTION_POLYGON} = [[$x, $y]];
		
		$self->change_cursor($select_type == 1 ? "dot" : "tcross") ;
		}
	else
		{
		push @{$self->{SELECTION_POLYGON}}, [$x, $y] ;
		$self->polygon_selection($select_type) ;
		$self->update_display() ;
		}
	}

if($event->{STATE} ne 'dragging-button1')
	{
	$self->{SELECTION_POLYGON} = [] ;
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub polygon_selection_button_release
{
my ($self, $event) = @_ ;

$self->{SELECTION_POLYGON} = [] ;
$self->change_cursor('dot') ;
}

#----------------------------------------------------------------------------------------------

sub all_points_in_polygon
{
my ($points, $polygon) = @_;

for my $point (@$points)
	{
	return 0 unless point_in_polygon($point, $polygon);
	}

return 1;
}

#-----------------------------------------------------------------------------

sub point_in_polygon 
{
# determine whether the point is inside the polygon through the ray method
# https://en.wikipedia.org/wiki/Point_in_polygon

my ($point, $polygon) = @_;

my ($point_x, $point_y) = @$point;
my $is_inside = 0;
my $vertex_num = scalar(@$polygon);

for
	(
	my $current_index = 0, my $previous_index = $vertex_num - 1; 
	$current_index < $vertex_num; 
	$previous_index = $current_index++
	) 
	{
	my ($current_vertex_x, $current_vertex_y) = @{$polygon->[$current_index]};
	my ($previous_vertex_x, $previous_vertex_y) = @{$polygon->[$previous_index]};
	
	if ((($current_vertex_y > $point_y) != ($previous_vertex_y > $point_y)) &&
		($point_x < ($previous_vertex_x - $current_vertex_x) * ($point_y - $current_vertex_y) / 
					($previous_vertex_y - $current_vertex_y) + $current_vertex_x)) 
		{
		$is_inside = !$is_inside;
		}
	}

return $is_inside;
}

#-----------------------------------------------------------------------------

1 ;

