# NOTE: Derived from blib/lib/Storable.pm.
# Changes made here will be lost when autosplit again.
# See AutoSplit.pm.
package Storable;

#line 259 "blib/lib/Storable.pm (autosplit into blib/lib/auto/Storable/_retrieve.al)"
# Internal retrieve routine
sub _retrieve {
	my ($file, $use_locking) = @_;
	local *FILE;
	open(FILE, $file) || logcroak "can't open $file: $!";
	binmode FILE;							# Archaic systems...
	my $self;
	my $da = $@;							# Could be from exception handler
	if ($use_locking) {
		if ($^O eq 'dos') {
			logcarp "Storable::lock_store: fcntl/flock emulation broken on $^O";
			return undef;
		}
		flock(FILE, LOCK_SH) || logcroak "can't get shared lock on $file: $!";
		# Unlocking will happen when FILE is closed
	}
	eval { $self = pretrieve(*FILE) };		# Call C routine
	close(FILE);
	logcroak $@ if $@ =~ s/\.?\n$/,/;
	$@ = $da;
	return $self;
}

# end of Storable::_retrieve
1;
