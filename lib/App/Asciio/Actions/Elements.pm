package App::Asciio::Actions::Elements ;

use strict ;
use warnings ;
use Encode ;
use utf8 ;

use File::Slurp ;
use File::HomeDir ;

use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Multiwirl ;

#----------------------------------------------------------------------------------------------

sub add_element
{
my ($self, $name_and_edit) = @_ ;

$self->create_undo_snapshot() ;

$self->deselect_all_elements() ;

my ($name, $edit) = @{$name_and_edit} ;

my $element = $self->add_new_element_named($name, $self->{MOUSE_X}, $self->{MOUSE_Y}) ;

$element->edit($self) if $edit;

$self->select_elements(1, $element);

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub make_unicode
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

for my $element (@{$self->{ELEMENTS}}) 
	{
	if($element->isa('App::Asciio::stripes::editable_box2'))
		{
		App::Asciio::Actions::Box::change_box_type($self, { ELEMENT => $element, TYPE => 'unicode' }, 0) ;
		}
	
	if($element->isa('App::Asciio::stripes::section_wirl_arrow'))
		{
		App::Asciio::Actions::Multiwirl::change_arrow_type($self, { ELEMENT => $element, TYPE => 'unicode' }, 0) ;
		}
	}

$self->update_display() ;
}

#----------------------------------------------------------------------------------------------

sub add_help_box
{
my ($self) = @_ ;

$self->create_undo_snapshot() ;

my $help_path = File::HomeDir->my_home() . '/.config/Asciio/help_box' ;

if(-e $help_path)
	{
	my $help_text = read_file($help_path, {bin_mode => ':utf8'});
	
	Encode::_utf8_on($help_text);
	$help_text =~ s/\t/$self->{TAB_AS_SPACES}/g;
	$help_text =~ s/\r//g;
	
	my $new_element = new App::Asciio::stripes::editable_box2
						({
						TEXT_ONLY => $help_text,
						TITLE => '',
						EDITABLE => 0,
						RESIZABLE => 0,
						}) ;
	
	@$new_element{'X', 'Y', 'SELECTED'} = ($self->{MOUSE_X}, $self->{MOUSE_Y}, 0) ;
	$self->add_elements($new_element) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

1 ;

