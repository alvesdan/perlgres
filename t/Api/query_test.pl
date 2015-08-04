use lib 'lib';
use Api::Query;
use Test::Simple tests => 4;

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

do {
  $expected = "SELECT * FROM example WHERE name LIKE '\%john\%' ORDER BY id DESC";
  $returned = Api::Query->build("example", {
    order_by => {
      desc => ["id"]
    },
    where => {
      like => { name => '%john%' }
    }
  });

  ok($expected eq $returned, 'generates a query with ORDER');
};

do {
  $expected = "SELECT id, name FROM example";
  $returned = Api::Query->build("example", {
    columns => ["id", "name"]
  });

  ok($expected eq $returned, 'generates a query with custom columns');
};
