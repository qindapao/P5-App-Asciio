package App::Asciio::Actions::Clipboard ;
use strict ;
use warnings ;

#----------------------------------------------------------------------------------------------

use utf8;
use Encode;
use List::Util qw(min max) ;
use List::MoreUtils qw(first_value) ;
use MIME::Base64 ;
use Clone ;

use Sereal qw(
	get_sereal_decoder
	get_sereal_encoder
	looks_like_sereal
	) ;

use Sereal::Encoder qw(SRL_SNAPPY SRL_ZLIB SRL_ZSTD) ;

use App::Asciio::stripes::image_box ;


#----------------------------------------------------------------------------------------------

# Windows -> MSWin32
# Linux -> linux
# macOS -> darwin
sub read_clipboard_raw_text
{
my @sources = $^O eq 'MSWin32'
	? ('powershell -Command "Get-Clipboard"')
	: ('xsel -b -o', 'xsel -p -o');

for my $cmd (@sources)
	{
	my $data = qx{$cmd};
	my $decoded = MIME::Base64::decode_base64($data);
	return $data if looks_like_sereal($decoded);
	}

return '';
}

#----------------------------------------------------------------------------------------------

sub read_plain_text_from_clipboard
{
# 'primary' or 'clipboard'
my ($mode) = @_;

if ($^O eq 'MSWin32')
	{
	my $text = qx{powershell -Command "Get-Clipboard"};
	return defined($text) ? $text : '';
	}
else
	{
	my $opt = $mode eq 'primary' ? '-p' : '-b';
	return qx{xsel $opt -o};
	}
}

#----------------------------------------------------------------------------------------------

sub write_clipboard_raw_text
{
my ($text) = @_;

if ($^O eq 'MSWin32')
	{
	open my $POWERSHELL, "|-", "powershell", "-Command",
		"[Console]::InputEncoding = [System.Text.Encoding]::UTF8; \$input | Set-Clipboard"
		or die "Can't open PowerShell";
	binmode($POWERSHELL, ":encoding(UTF-8)");
	print $POWERSHELL $text;
	close $POWERSHELL;
	}
else
	{
	for my $opt ('-b', '-p') {
		local $SIG{PIPE} = sub { die "xsel pipe broke for $opt" };
		open my $CLIP, "| xsel -i $opt" or die "Can't write to clipboard $opt";
		binmode($CLIP, ":encoding(UTF-8)");
		print $CLIP $text;
		close $CLIP;
	}
	}
}

#----------------------------------------------------------------------------------------------

sub windows_read_clipboard_image
{
my $ps_command = <<'END_PS';
$img = Get-Clipboard -Format Image;
if ($img) {
    $ms = New-Object System.IO.MemoryStream;
    $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png);
    $ms.Position = 0;
    $bytes = $ms.ToArray();
    [Convert]::ToBase64String($bytes)
}
END_PS

my $base64 = `powershell -Command "$ps_command"`;
$base64 =~ s/\s+//g;
return (undef, undef) unless $base64;

my $image = decode_base64($base64);
return ($image, 'png');
}

#----------------------------------------------------------------------------------------------

sub copy_to_clipboard
{
my ($self) = @_ ;

my $cache = $self->{CACHE} ;
$self->invalidate_rendering_cache() ;

my @selected_elements = $self->get_selected_elements(1) ;

unless(@selected_elements)
	{
	delete $self->{CLIPBOARD} ;
	return ;
	}

my %selected_elements = map { $_ => 1 } @selected_elements ;

my @connections =
	grep 
		{
		exists $selected_elements{$_->{CONNECTED}} && exists $selected_elements{$_->{CONNECTEE}}
		} 
		$self->get_connections_containing(@selected_elements)  ;

my $elements_and_connections =
	{
	ELEMENTS =>  \@selected_elements,
	CONNECTIONS => \@connections ,
	};

$self->{CLIPBOARD} = Clone::clone($elements_and_connections) ;
$self->{CACHE} = $cache ;
}

#----------------------------------------------------------------------------------------------

sub insert_from_clipboard
{
my ($self, @args) = @_ ;

my ($x_offset, $y_offset) ;

if(@args)
	{
	($x_offset, $y_offset) = 'ARRAY' eq $args[0] ? $args[0]->@* : @args ;
	}

if(defined $self->{CLIPBOARD}{ELEMENTS} && @{$self->{CLIPBOARD}{ELEMENTS}})
	{
	$self->create_undo_snapshot() ;
	
	$self->deselect_all_elements() ;
	
	unless(defined $x_offset)
		{
		my $min_x = min(map {$_->{X}} @{$self->{CLIPBOARD}{ELEMENTS}}) ;
		$x_offset = $min_x - $self->{MOUSE_X} ;
		}
	
	unless(defined $y_offset)
		{
		my $min_y = min(map {$_->{Y}} @{$self->{CLIPBOARD}{ELEMENTS}}) ;
		$y_offset = $min_y  - $self->{MOUSE_Y} ;
		}
	
	my %new_group ;
	
	for my $element (@{$self->{CLIPBOARD}{ELEMENTS}})
		{
		@$element{'X', 'Y'}= ($element->{X} - $x_offset, $element->{Y} - $y_offset) ;
		
		if(exists $element->{GROUP} && scalar(@{$element->{GROUP}}) > 0)
			{
			my $group = $element->{GROUP}[-1] ;
			
			unless(exists $new_group{$group})
				{
				$new_group{$group} = {'GROUP_COLOR' => $self->get_group_color()} ;
				}
				
			pop @{$element->{GROUP}} ;
			push @{$element->{GROUP}}, $new_group{$group} ;
			}
		else
			{
			delete $element->{GROUP} ;
			}
		}
	
	my $clipboard = Clone::clone($self->{CLIPBOARD}) ;
	
	$self->add_elements_no_connection(@{$clipboard->{ELEMENTS}}) ;
	$self->add_connections(@{$clipboard->{CONNECTIONS}}) ;
	
	$self->update_display() ;
	}
}

#----------------------------------------------------------------------------------------------

sub import_elements_from_system_clipboard
{
my ($self, @args) = @_;

my $elements_base64 = read_clipboard_raw_text();
my $elements_serial = MIME::Base64::decode_base64($elements_base64);

unless (looks_like_sereal($elements_serial))
	{
	print STDERR "Clipboard data is invalid or not Sereal!\n";
	return;
	}

$self->{CLIPBOARD} = Clone::clone(get_sereal_decoder()->decode($elements_serial));
insert_from_clipboard($self, @args);
}

#----------------------------------------------------------------------------------------------

sub serialize_selected_elements
{
my ($self) = @_ ;

copy_to_clipboard($self) ;

my $export_elements = Clone::clone($self->{CLIPBOARD}) ;
my $encoder         = get_sereal_encoder({compress => SRL_ZLIB}) ;
my $serialized      = $encoder->encode($export_elements) ;
my $base64          = MIME::Base64::encode_base64($serialized, "\n") ;
}

sub export_elements_to_system_clipboard
{
my ($self) = @_;

my $serialized_elements = serialize_selected_elements($self);
write_clipboard_raw_text($serialized_elements);
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_ascii
{
my ($self) = @_;

my $ascii_buffer = $self->transform_elements_to_ascii_buffer(
	$self->get_selected_elements(1)
);

write_clipboard_raw_text($ascii_buffer);
}

#----------------------------------------------------------------------------------------------

sub export_to_clipboard_as_markup
{
my ($self) = @_;

my $markup_buffer = $self->transform_elements_to_markup_buffer(
	$self->get_selected_elements(1)
	);

write_clipboard_raw_text($markup_buffer);
}

#----------------------------------------------------------------------------------------------

sub import_from_system_clipboard_to_image_box
{
my ($self) = @_ ;

$self->create_undo_snapshot();

$self->deselect_all_elements() ;

my ($image, $image_type);

if ($^O eq 'MSWin32')
	{
	($image, $image_type) = windows_read_clipboard_image();
	}
else
	{
	# libjpeg8-dev libjpeg9-dev
	my %commands = (
		'png'  => [ 'xclip -selection clipboard -t image/png -o',  'xclip -selection primary -t image/png -o'  ],
		'jpeg' => [ 'xclip -selection clipboard -t image/jpeg -o', 'xclip -selection primary -t image/jpeg -o' ],
	);

	my $type = `xclip -selection clipboard -t TARGETS -o` ;
	$type = `xclip -selection primary -t TARGETS -o` if $type !~ /image/ ;

	$image_type = first_value { $type =~ /$_/ } keys %commands;
	my $use_commands = $commands{$image_type} if $image_type;

	for (@{$use_commands // []})
	{
		$image = qx~$_~ ;
		last if($image ne '') ;
	}
	}

if (!defined $image || $image eq '') {
	print STDERR "no image found!\n\e[m" ;
    return;
}

my ($character_width, $character_height) = $self->get_character_size() ;

my $image_box = new App::Asciio::stripes::image_box
		({
		NAME => 'image_box',
		TEXT_ONLY => ' ',
		TITLE => '',
		EDITABLE => 0,
		RESIZABLE => 1,
		AUTO_SHRINK => 0,
		CHARACTER_WIDTH => $character_width,
		CHARACTER_HEIGHT => $character_height,
		IMAGE => $image,
		IMAGE_TYPE => $image_type,
		});

$self->add_element_at($image_box, $self->{MOUSE_X}, $self->{MOUSE_Y});

$self->select_elements(1, $image_box);

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub import_ascii_element_from_source
{
my ($self, $source, $type) = @_;

my $ascii = read_plain_text_from_clipboard($source);

$ascii = decode("utf-8", $ascii);
$ascii =~ s/\r//g;
$ascii =~ s/\t/$self->{TAB_AS_SPACES}/g;

my $element = $self->add_new_element_named("Asciio/$type", $self->{MOUSE_X}, $self->{MOUSE_Y});
$element->set_text('', $ascii);
$self->select_elements(1, $element);

$self->update_display();
}

#----------------------------------------------------------------------------------------------

sub import_from_clipboard_to_box  { my ($self) = @_; import_ascii_element_from_source($self, 'clipboard', 'box'); }
sub import_from_clipboard_to_text { my ($self) = @_; import_ascii_element_from_source($self, 'clipboard', 'text'); }
sub import_from_primary_to_box    { my ($self) = @_; import_ascii_element_from_source($self, 'primary',   'box'); }
sub import_from_primary_to_text   { my ($self) = @_; import_ascii_element_from_source($self, 'primary',   'text'); }

#----------------------------------------------------------------------------------------------


1 ;

