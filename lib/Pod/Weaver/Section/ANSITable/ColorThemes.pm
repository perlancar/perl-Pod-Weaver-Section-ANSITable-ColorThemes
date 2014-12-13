package Pod::Weaver::Section::ANSITable::ColorThemes;

# DATE
# VERSION

use 5.010001;
use Moose;
with 'Pod::Weaver::Role::Section';

use List::Util qw(first);
use Moose::Autobox;

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
    require Text::ANSITable;

    my $text;
    {
        no strict 'refs';
        my $color_themes = \%{"$pkg\::color_themes"};
        $text = "";
        for my $style (sort keys %$color_themes) {
            my $spec = $color_themes->{$style};
            $text .= "=head2 $short_pkg\::$style\n\n";
            $text .= "$spec->{summary}.\n\n" if $spec->{summary};
            $text .= "$spec->{description}\n\n" if $spec->{description};
        }
    }

    $document->children->push(
        Pod::Elemental::Element::Nested->new({
            command  => 'head1',
            content  => 'INCLUDED COLOR THEMES',
            children => [
                map { Pod::Elemental::Element::Pod5::Ordinary->new({ content => $_ })} split /\n\n/, $text
            ],
        }),
    );
    $self->log(["Inserted INCLUDED COLOR THEMES POD section to file %s", $filename]);
}

no Moose;
1;
# ABSTRACT: Add an INCLUDED COLOR THEMES section for ANSITable ColorTheme module

=for Pod::Coverage weave_section

=head1 SYNOPSIS

In your C<weaver.ini>:

 [ANSITable::ColorThemes]


=head1 DESCRIPTION
