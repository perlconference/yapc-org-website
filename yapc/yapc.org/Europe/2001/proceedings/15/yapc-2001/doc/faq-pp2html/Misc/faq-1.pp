
// vim: set filetype=pp2html:


=Sharing Images

\QST

How can I share images and TreeApplet sources between several presentations
or documents?

\ANS

Use the \C<--image_dir> option to specify where the images should be
copied to and the \C<--image_ref> option to define how the images
should be referenced in the <IMG> tags in HTML.

\B<Example:>

  --target_dir /usr/local/httpd/htdocs/my_present
  --image_dir  /usr/local/httpd/htdocs/images
  --image_ref  /images

  --applet_dir  /usr/local/httpd/htdocs/applet
  --applet_ref  /applet

\DSC

Normally the images (for example bullet gifs) and TreeApplet files
are copied to the
target directory where your slides are created. This is the default
because the intention is, to get a self-contained directory which
contains all needed files. If you have many presentations, this
may be a waste of space. You may wish to share the images and
TreeApple files.

The usage of the \C<--image_dir> options causes pp2html to copy
the images to the \C<images> directory.
This is only done, if the source is newer than the target. So normally
the images remain untouched, if you always use the same images.
The \C<--image_ref> option should be used to specify the absolute or relative pathname
which must be used to reference the images in the <IMG> tags in the
HTML files.

In the above example the --image_ref option specifies a symbolic name
(beginning with a slash) which is mapped to a physical directory in the
configuration file of the webserver. (/usr/local/httpd/htdocs/images
in this case.)

This is the same for the TreeApplet files, using the
\C<--applet_dir> and \C<--applet_ref> options.

