use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name       => 'Face::Client',
    license           => 'perl',
    dist_author       => q{Arnaud (Arhuman) ASSAD <arhuman@gmail.com>},
    dist_version_from => 'lib/Face/Client.pm',
    build_requires    => {
        'JSON'         => 0,
        'REST::Client' => 0,
        'Test::More'   => 0,
    },
    requires           => { 'perl' => 5.006, },
    add_to_cleanup     => ['Face-Client-*'],
    create_makefile_pl => 'traditional',
    meta_merge         => {
        resources => {
            repository  => q[https://github.com/arhuman/Face-Client],
            bugtracker  => q[https://github.com/arhuman/Face-Client/issues],
        },
        keywords     => [qw[face recognition rest api]],
        generated_by => q[Arnaud (Arhuman) ASSAD <arhuman@gmail.com>]
    },
);

$builder->create_build_script();
