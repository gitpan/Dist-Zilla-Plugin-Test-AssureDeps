use CPAN::Meta;
use List::Util qw/first/;
use Module::Metadata;
use Test::More 0.88;

sub check_dependencies {
	my ($meta, $phase, $type) = @_;

	my $reqs = $meta->effective_prereqs->requirements_for($phase, $type);
	for my $module ($reqs->required_modules) {
		my $version;
		if ($module eq 'perl') {
			$version = $];
		}
		else {
			my $metadata = Module::Metadata->new_from_module($module);
			fail("Module '$module' is not installed"), next if not defined $metadata;
			$version = eval { $metadata->version };
		}
		fail("Missing version info for module '$module'"), next if not $version;
		fail(sprintf 'Version %s of module %s is not in range \'%s\'', $version, $module, $reqs->as_string_hash->{$module}), next if not $reqs->accepts_module($module, $version);
		pass "$module $version is present";
	}
}

my $metafile = first { -e $_ } qw/MYMETA.json MYMETA.yml META.json META.yml/ or BAIL_OUT("No META information provided\n");
my $meta = CPAN::Meta->load_file($metafile);

check_dependencies($meta, $_, 'requires') for qw/configure build runtime/;

if (0) {
	BAIL_OUT("Missing dependencies") if !Test::More->builder->is_passing;
}

done_testing;

