use lib 'lib';
use Api::Query;
use Test::Simple tests => 2;

do {
  $expected = "SELECT * FROM example WHERE email = 'john\@example.com' AND id > '5' AND name LIKE 'john'";
  $returned = Api::Query->build("example", {
      where => {
        email => 'john@example.com',
        like => {
          name => 'john'
        },
        gt => { id => '5' }
      }
    });

  ok($expected eq $returned, 'builds the query');
};

do {
  $expected = "SELECT * FROM example";
  $returned = Api::Query->build("example", {});

  ok($expected eq $returned, 'generates simple query when no options');
};
