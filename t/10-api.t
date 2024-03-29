#!/usr/bin/perl 

use strict; 
use warnings; 

use Test::More; 
use Face::Client; 
use JSON;
use Data::Dumper;


unless ( $ENV{FACE_API_KEY} && $ENV{FACE_API_SECRET}) {
    warn("\n\nSet FACE_API_KEY, FACE_API_SECRET for testing\n\n");
    plan skip_all => ' Set environment vars for API access';
}

plan tests => 88;

my $client;
eval { $client = Face::Client->new() };
ok( !$@, "new()" );

isa_ok( $client, 'Face::Client' );

########################################################################
#                   Account API
########################################################################

my $account = $client->account_limits;
isa_ok($account, "Face::Client::Response::Account");

can_ok($account,'used');
can_ok($account,'remaining');
can_ok($account,'limit');
can_ok($account,'reset_time_text');
can_ok($account,'reset_time');

can_ok($account,'namespace_limit');
can_ok($account,'namespace_used');
can_ok($account,'namespace_remaining');

can_ok($client,"account_namespaces");
my @namespaces = $client->account_namespaces;
cmp_ok($#namespaces ,">", 10, "Namespaces returned");

can_ok($client,"account_users");

########################################################################
#                   Tag API
########################################################################

# Check for lowlevel API methods availability
can_ok( $client, "faces_detect" );
my @tags = $client->faces_detect(
        { urls => "http://face.com/img/faces-of-the-festival-no-countries.jpg" }
   );
is( $#tags, 15, "16 tags retrieved" );
my $tag = shift @tags;

isa_ok( $tag, 'Face::Client::Response::Tag' );
can_ok( $tag, "width" );
is( $tag->width, '11.09', 'check for width value' );
can_ok( $tag, "height" );
is( $tag->height, '11.13', 'check for height value' );
can_ok( $tag, "center" );
is_deeply(
    $tag->center,
    { y => '90.05', x => '5.91' },
    'check for center value'
);
can_ok( $tag, "eye_left" );
is_deeply(
    $tag->eye_left,
    { y => '87.15', x => '3.43' },
    'check for eye_left value'
);
can_ok( $tag, "eye_right" );
is_deeply(
    $tag->eye_right,
    { y => '87.56', x => '7.88' },
    'check for eye_right value'
);
can_ok( $tag, "mouth_left" );
is_deeply(
    $tag->mouth_left,
    { y => '92.91', x => '2.77' },
    'check for mouth_left value'
);
can_ok( $tag, "mouth_center" );
is_deeply(
    $tag->mouth_center,
    { x => '4.23', y => '93.06' },
    'check for center value'
);
can_ok( $tag, "mouth_right" );
is_deeply(
    $tag->mouth_right,
    { x => '6.42', y => '93.21' },
    'check for mouth_right value'
);
can_ok( $tag, "nose" );
is_deeply( $tag->nose, { x => '4.05', y => '90.29' }, 'check for nose value' );
can_ok( $tag, "yaw" );
is( $tag->yaw, '19.14', 'check for yaw value' );
can_ok( $tag, "pitch" );
is( $tag->pitch, '-1.68', 'check for pitch value' );
can_ok( $tag, "roll" );
is_deeply( $tag->roll, '7.92', 'check for roll value' );
can_ok( $tag, "attributes" );

is_deeply(
    $tag->attributes,
    {
        'face'    => { 'value' => 'true',  'confidence' => 97 },
        'smiling' => { 'value' => 'false', 'confidence' => 90 },
        'glasses' => { 'value' => 'false', 'confidence' => 98 },
        'gender'  => { 'value' => 'male',  'confidence' => 89 }
    },
    'check for attributes value'
);
can_ok( $tag, "gender" );
is( $tag->gender, undef, 'check for gender value' );
can_ok( $tag, "smiling" );
is( $tag->smiling, undef, 'check for smiling value' );
can_ok( $tag, "mood" );
is( $tag->mood, undef, 'check for mood value' );
can_ok( $tag, "lips" );
is( $tag->lips, undef, 'check for lips value' );
can_ok( $tag, "face" );
is( $tag->face, undef, 'check for face value' );
can_ok( $tag, "tid" );
# Can't test tid (as *temporary* value changes between each invocation)
#is( $tag->tid, "TEMP_F@49996d7d39d82aa979caed80fcc052f4_9ae307bb1e8fb6b90767fe326b6edb12_5.91_90.05_0_0", 'check for tid value' );

########################################################################
#                   Response API
########################################################################

my $response = $client->response;
isa_ok( $response, 'Face::Client::Response' );
can_ok( $response, "status" );
can_ok( $response, "error_code" );
can_ok( $response, "error_message" );
can_ok( $response, "photos" );
can_ok( $response, "url" );
can_ok( $response, "pid" );
can_ok( $response, "width" );
can_ok( $response, "height" );
can_ok( $response, "tags" );
can_ok( $response, "groups" );
can_ok( $response, "tid" );
can_ok( $response, "recognizable" );
can_ok( $response, "threshold" );
can_ok( $response, "uids" );
can_ok( $response, "confirmed" );
can_ok( $response, "manual" );

########################################################################
#                   Client API
########################################################################

can_ok( $client, "faces_recognize" );
can_ok( $client, "faces_train" );
can_ok( $client, "faces_status" );

can_ok( $client, "tags_get" );
can_ok( $client, "tags_add" );
can_ok( $client, "tags_save" );
can_ok( $client, "tags_remove" );

can_ok( $client, "account_limits" );
can_ok( $client, "account_users" );

########################################################################
#                   helper functions
########################################################################


my $client_h = Face::Client->new({api_key => 'key', api_secret => 'secret'}); 
is($client_h->_get_credential_parameters(),'&api_key=key&api_secret=secret');
$client_h = Face::Client->new(); 
is($client_h->_get_credential_parameters(),'&api_key='.$ENV{FACE_API_KEY}.'&api_secret='.$ENV{FACE_API_SECRET});


########################################################################
#                   Face recognition scenario
########################################################################

@tags = $client->faces_detect(
    { urls => "http://img.clubic.com/03520176-photo-kevin-polizzi-fondateur-jaguar-network.jpg,http://media.linkedin.com/mpr/pub/image-ydXbyfluDqrF4odQH8fDyBF07ONcpJdQHNaYyXk1s4K8Dk6Q/kevin-polizzi.jpg,http://experts-it.fr/files/2011/01/Jaguar-Kevin-Polizzi.jpg,http://www.jaguar-network.com/jn/templates/images/img57.jpg" }
);
my $ids = join ",", map {$_->tid} @tags;
my @st = $client->tags_save(
     { tids => $ids,uid => 'kevin.polizzi@face-client-perl' }
);
is ($client->response->status,"success", "Test for error code");
@tags = $client->tags_get( { uids => 'kevin.polizzi@face-client-perl' } );
cmp_ok($#st,'==',$#tags,"Get saved tags");

my @users = $client->account_users( { namespaces => 'face-client-perl' } );
cmp_ok($#users ,"==", 0,"Zero user before training");
$client->faces_train( { uids => 'kevin.polizzi@face-client-perl' } );
@users = $client->account_users( { namespaces => 'face-client-perl' } );
is_deeply(@users,('kevin.polizzi@face-client-perl'),'users are the same');
@tags = $client->faces_recognize(
    { 
        urls => "http://img.clubic.com/03520176-photo-kevin-polizzi-fondateur-jaguar-network.jpg",
        uids => 'kevin.polizzi@face-client-perl'
    }
);
ok ($tags[0]->recognized, 'User recognized');
@tags = $client->faces_recognize(
    {
    urls => 'http://img2.imagesbn.com/images/137400000/137404562.JPG', 
    uids => 'kevin.polizzi@face-client-perl'
    }
);
ok (!$tags[0]->recognized, 'Bad user NOT recognized');

#$client->tags_remove(tids => );
