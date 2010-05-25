# NOTE: Derived from blib/lib/Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 137 "blib/lib/Storable.pm (autosplit into blib/lib/auto/Storable/_store.al)"
# Internal store to file routine
sub _store {
	my $xsptr = shift;
	my $self = shift;
	my ($file, $use_locking) = @_;
	logcroak "not a reference" unless ref($self);
	logcroak "too many arguments" unless @_ == 2;	# No @foo in arglist
	local *FILE;
	open(FILE, ">$file") || logcroak "can't create $file: $!";
	binmode FILE;				# Archaic systems...
	if ($use_locking) {
		if ($^O eq 'dos') {
			logcarp "Storable::lock_store: fcntl/flock emulation broken on $^O";
			return undef;
		}
		flock(FILE, LOCK_EX) ||
			logcroak "can't get exclusive lock on $file: $!";
		truncate FILE, 0;
		# Unlocking will happen when FILE is closed
	}
	my $da = $@;				# Don't mess if called from exception handler
	my $ret;
	# Call C routine nstore or pstore, depending on network order
	eval { $ret = &$xsptr(*FILE, $self) };
	close(FILE) or $ret = undef;
	unlink($file) or warn "Can't unlink $file: $!\n" if $@ || !defined $ret;
	logcroak $@ if $@ =~ s/\.?\n$/,/;
	$@ = $da;
	return $ret ? $ret : undef;
}

# end of Storable::_store
1;
