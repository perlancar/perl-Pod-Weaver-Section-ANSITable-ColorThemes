package Pod::Weaver::Section::ColorThemes::ANSITable;

# DATE
# VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::AddTextToSection';
with 'Pod::Weaver::Role::Section';

sub weave_section {
    my ($self, $document, $input) = @_;

    my $filename = $input->{filename} || 'file';

    my $pkg_p;
    my $pkg;
    my $short_pkg;
    if ($filename =~ m!^lib/(.+/ColorTheme/.+)$!) {
        $pkg_p = $1;
        $pkg = $1; $pkg =~ s/\.pm\z//; $pkg =~ s!/!::!g;
        $short_pkg = $pkg; $short_pkg =~ s/.+::ColorTheme:://;
    } else {
        $self->log_debug(["skipped file %s (not a ColorTheme module)", $filename]);
        return;
    }

    local @INC = @INC;
    unshift @INC, 'lib';
    require $pkg_p;
    #require Text::ANSITable;

    my $text = "Below are the color themes included in this package:\n\n";
    {
        no strict 'refs';
        my $color_themes = \%{"$pkg\::color_themes"};
        for my $style (sort keys %$color_themes) {
            my $spec = $color_themes->{$style};
            $text .= "=head2 $short_pkg\::$style\n\n";
            $text .= "$spec->{summary}.\n\n" if $spec->{summary};
            $text .= "$spec->{description}\n\n" if $spec->{description};
        }
    }

    $self->add_text_to_section($document, $text, 'COLOR THEMES');
}

no Moose;
1;
# ABSTRACT: Add a COLOR THEMES section for ANSITable ColorTheme module

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [ColorThemes::ANSITable]


=head1 DESCRIPTION
