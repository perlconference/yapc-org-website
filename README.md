# What is this?

The documents in this project are the compiled knowledge of how
to run a grass-roots conference. They have been pulled together
by The Perl Foundation to help us from year to year since we always
have new organizers, but they're here to help anyone.

What's the funny mark-up in the files?

These files are written in a markup language called plain old
documentation (POD) format. If you have a computer with perl on it,
you can type >perldoc YAPC.pm and read it. If you don't have
perl, you can probably just try to ignore the markup.

# Updating https://yapc.org

https://yapc.org is being hosted by github pages. 

Changes to files in master/docs will go live to the internet within 10 minutes.

If you feel something is wrong, please open an issue or better yet submit a pull request to this repo.

# Developing

There is an app.psgi file in the `./docs` directory that makes it easier to view the static
pages while editing them. Just cd to the yapc.org directory and run ```plackup```.
