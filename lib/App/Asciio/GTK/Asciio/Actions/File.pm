
package App::Asciio::GTK::Asciio::Actions::File ;
use utf8;
use Encode qw(decode encode FB_CROAK) ;

use File::Basename ;
use App::Asciio::String ;

use App::Asciio::GTK::Asciio::stripes::image_box ;

#----------------------------------------------------------------------------------------------

sub open_image
{
my ($self, $file_name) = @_;

$file_name = normalize_file_name($file_name) ;
$file_name ||= $self->get_file_name('open') ;

return unless defined $file_name && $file_name ne q[] ;

my $image_data ;

eval
	{
	open my $fh, '<:raw', $file_name or die "Can't open image file $file_name: $!" ;
	local $/ ;
	$image_data = <$fh> ;
	close $fh ;
	} ;

if ($@)
	{
	warn "Failed to read file, $@" ;
	return ;
	}

my ($base_name, $path, $extension) = File::Basename::fileparse($file_name, ('\..*')) ;
$extension =~ s/^\.// ;
my $image_type = lc($extension) ;
$image_type = 'jpeg' if $image_type eq 'jpg' ;

unless ($image_type eq 'png' || $image_type eq 'jpeg')
	{
	warn "Unsupported image type '$image_type'." ;
	return ;
	}

my ($character_width, $character_height) = $self->get_character_size();
my $image_box = App::Asciio::GTK::Asciio::stripes::image_box->new({
	NAME            => 'image_box',
	TEXT_ONLY       => ' ',
	TITLE           => '',
	EDITABLE        => 0,
	RESIZABLE       => 1,
	AUTO_SHRINK     => 0,
	CHARACTER_WIDTH => $character_width,
	CHARACTER_HEIGHT=> $character_height,
	IMAGE           => $image_data,
	IMAGE_TYPE      => $image_type,
	}) ;

return unless defined $image_box ;

$self->add_element_at($image_box, $self->{MOUSE_X}, $self->{MOUSE_Y});
$self->select_elements(1, $image_box);
$self->update_display();
}

#----------------------------------------------------------------------------------------------

1 ;


