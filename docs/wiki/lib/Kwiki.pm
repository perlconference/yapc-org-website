package Kwiki;
use Spoon 0.22 -Base;
our $VERSION = '0.38';

const config_class => 'Kwiki::Config';

sub process {
    my $hub = $self->load_hub(@_);
    $hub->registry->load;
    $hub->add_hooks;
    $hub->pre_process;
    my $html = $hub->process;
    if (defined $html) {
        $hub->headers->print;
        $self->utf8_encode($html);
        # With mod_perl < 1.27 and Perl >= 5.8.0, STDOUT does not get
        # tied to Apache.pm properly.
        exists $ENV{MOD_PERL}
          ? Apache->request->print($html)
          : print $html;
    }
    close STDOUT unless $self->using_debug;
    $hub->post_process;
    return $self;
}

__DATA__

=head1 NAME

Kwiki - The Kwiki Wiki Building Framework

=head1 SYNOPSIS

    > kwiki -new cgi-bin/my-kwiki

    Kwiki software installed! Point your browser at this location.

=head1 NOTE

If you are impatient (don't worry, that's a good thing!) read
L<Kwiki::Command> to get the details on how to install and configure a
new Kwiki wiki in record time.

=head1 DESCRIPTION

A Wiki is a website that allows its users to add pages, and edit any
existing pages. It is one of the most popular forms of web
collaboration. If you are new to wiki, visit
http://c2.com/cgi/wiki?WelcomeVisitors which is possibly the oldest
wiki, and has lots of information about how wikis work.

Kwiki is a Perl wiki implementation based on the Spoon application
architecture and using the Spiffy object orientation model. The major
goals of Kwiki are that it be easy to install, maintain and extend.

All the features of a Kwiki wiki come from plugin modules. The base
installation comes with the bare minimum plugins to make a working
Kwiki. To make a really nice Kwiki installation you need to install
additional plugins. Which plugins you pick is entirely up to you.
Another goal of Kwiki is that every installation will be unique.
When there are hundreds of plugins available, this will hopefully
be the case.

=head1 CGI::Kwiki

Kwiki is the successor of the popular CGI::Kwiki software. It is a
complete refactoring of that code. The new code has a lovely plugin API
and is much cleaner and extendable on all fronts.

There is currently no automated way to upgrade a CGI::Kwiki installation
to Kwiki. It's actually quite easy to do by hand. Instructions on how to
do it are here: http://www.kwiki.org/?KwikiMigrationByHand

=head1 DOCUMENTATION

All of the future Kwiki module documentation is being written at
the http://doc.kwiki.org/ wiki. Check there for the latest doc, and
help improve it. Each successive release of Kwiki will include the
latest doc from that site.

=head1 CREDITS

I am currently employed by Socialtext, Inc. They make high quality
social software for enterprise deployment. Socialtext has a bold new
vision of building their products over Open Source software and
returning the generic source code to the community. This results in a
win/win effect for both entities. You get this shiny new wiki framework,
and Socialtext can take advantage of your plugins and bug fixes. 

The Kwiki project would not be where it is now without their support. I
thank them.

Of particular note, Dave Rolsky and Chris Dent are two current
Socialtext employees that have made significant contributions to Kwiki.

 ---

Iain Truskett was probably the most active Kwiki community hacker before
his untimely death in December 2003. The underlying foundation of Kwiki
has been named "Spoon" in his honor. Rest in peace Spoon.

 ---

Ian (what's with all these Iai?ns??) Langworth has become a new Kwiki
warrior. He helped a lot with the maiden release. Expect a lot of
plugins to come from him! Thanks Ian.

 ---

Finally, big props to all the folks on http://www.kwiki.org and
irc://irc.freenode.net/#kwiki. Thanks for all the support!

=head1 SEE ALSO

Kwiki::Command

=head1 AUTHOR

Brian Ingerson <INGY@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2004. Brian Ingerson. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See http://www.perl.com/perl/misc/Artistic.html

=cut
