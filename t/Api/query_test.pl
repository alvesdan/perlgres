use warnings;
use strict;
use lib 'lib';
use Api::Query;
use Test::Simple tests => 5;

do {
  my $expected = "SELECT * FROM example WHERE email = 'john\@example.com' AND id > '5' AND name LIKE 'john'";
  my $returned = Api::Query->select("example", {
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
  my $expected = "SELECT * FROM example";
  my $returned = Api::Query->select("example", {});

  ok($expected eq $returned, 'generates simple query when no options');
};

do {
  my $expected = "SELECT * FROM example WHERE name LIKE '\%john\%' ORDER BY id DESC";
  my $returned = Api::Query->select("example", {
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
  my $expected = "SELECT id, name FROM example";
  my $returned = Api::Query->select("example", {
    columns => ["id", "name"]
  });

  ok($expected eq $returned, 'generates a query with custom columns');
};

do {
  my $expected = "INSERT INTO example(email, name) VALUES('john\@example.com', 'John')";
  my $returned = Api::Query->insert("example", {
    name => "John",
    email => "john\@example.com"
  });

  ok($expected eq $returned, 'generates an insert query');
};
