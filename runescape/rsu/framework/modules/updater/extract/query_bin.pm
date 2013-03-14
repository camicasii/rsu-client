package updater::extract::query_bin;
	
# Include Config module for checking system values
use Config;

# Require the files grep module
require rsu::files::grep;

# Require the files copy module
require rsu::files::copy;

# Require the clientdir module
require rsu::files::clientdir;

# Require the extract archive module
require rsu::extract::archive;

# Require the download file module
require updater::download::file;
	
# Get the clientdir
my $clientdir = rsu::files::clientdir::getclientdir();

# Get the current OS
my $OS = "$^O";

sub update
{
	# Get the passed data
	my ($nogui) = @_;
	
	# Make default action be update
	my $install = 0;
	
	# If no gui is requested
	if (defined $nogui && $nogui eq '1')
	{
		# Enable installation
		$install = 1;
	}
	
	# If we are not on windows
	if ($OS !~ /MSWin32/)
	{
		# Get the architecture
		my $arch = $Config{archname};
		
		# If we are not on windows or mac
		if ($OS !~ /(MSWin32|darwin)/)
		{
			# If we are on 64bit
			if ($arch =~ /(x86_64|amd64)/ && $OS =~ /linux/)
			{
				# Use x86_64 as architecture
				$arch = "x86_64";
			}
			# Else if we are on 32bit
			elsif($arch =~ /i\d{1,1}86/ && $OS =~ /linux/)
			{
				# Use i386 as architecture
				$arch = "i386";
			}
			# Else
			else
			{
				# Return to call
				return 0;
			}
			
			# If the file exists or $install is 1 then
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS-$arch") || ($install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS-$arch", $install);
			}
		}
		# Else if we are on MacOSX
		elsif($OS =~ /darwin/)
		{
			# If the file exists or $install is 1 then
			if ((-e "$clientdir/rsu/bin/rsu-query-$OS") || ($install eq '1'))
			{
				# Fetch the binary and install it
				updater::extract::query_bin::fetch("rsu-query-$OS", $install);
			}
		}
	}
}

#
#---------------------------------------- *** ----------------------------------------
#

sub fetch
{
	# Get the passed data
	my ($name, $install) = @_;
	
	# Make a variable that says we will use the gui download
	my $nogui = '0';
	
	# If $install is passed and is 1
	if (defined $install && $install eq '1')
	{
		# Set $nogui to 1 so that we do not have to rely on a gui
		$nogui = $install;
		
		# Download the archive file containing the binary
		updater::download::file::from("https://github.com/HikariKnight/rsu-launcher/archive/$name-latest.tar.gz", "$clientdir/.download/$name-latest.tar.gz", $nogui);
	}
	else
	{
		# Download the archive file containing the new binary in a new process
		system("\"$clientdir/rsu/rsu-query\" rsu.download.file https://github.com/HikariKnight/rsu-launcher/archive/$name-latest.tar.gz \"$clientdir/.download\"");
	}
				
	# Extract the archive
	rsu::extract::archive::extract("$clientdir/.download/$name-latest.tar.gz", "$clientdir/.download/extracted_binary");
	
	# Backup solution
	#system("\"$clientdir/rsu/rsu-query\" rsu.extract.file $name-latest.zip \"$clientdir/.download/extracted_binary\"");
				
	# Locate the binary
	my @binary = rsu::files::grep::rdirgrep("$clientdir/.download/extracted_binary", "\/$name\$");
				
	# Copy the binary
	rsu::files::copy::print_cp($binary[0],"$clientdir/rsu/bin/$name");
}

#
#---------------------------------------- *** ----------------------------------------
#



1; 
