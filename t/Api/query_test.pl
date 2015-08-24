use warnings;
use strict;
use lib 'lib';
use Api::Query;
use Test::Simple tests => 9;

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

  ok($expected eq $returned, 'Builds the query');
};

do {
  my $expected = "SELECT * FROM example";
  my $returned = Api::Query->select("example", {});

  ok($expected eq $returned, 'Generates simple query when no options');
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

  ok($expected eq $returned, 'Generates a query with ORDER');
};

do {
  my $expected = "SELECT id, name FROM example";
  my $returned = Api::Query->select("example", {
    columns => ["id", "name"]
  });

  ok($expected eq $returned, 'Generates a query with custom columns');
};

do {
  my $expected = "INSERT INTO example(email, name) VALUES('john\@example.com', 'John')";
  my $returned = Api::Query->insert("example", {
    name => "John",
    email => "john\@example.com"
  });

  ok($expected eq $returned, 'Generates an insert query');
};

do {
  my $expected = "SELECT * FROM example LIMIT 10";
  my $returned = Api::Query->select("example", {
    limit => 10
  });

  ok($expected eq $returned, 'Generates an query with LIMIT');
};

do {
  my $expected = "SELECT * FROM example OFFSET 5";
  my $returned = Api::Query->select("example", {
    offset => 5
  });

  ok($expected eq $returned, 'Generates an query with OFFSET');
};

do {
  my $expected = "SELECT * FROM example LIMIT 10 OFFSET 5";
  my $returned = Api::Query->select("example", {
    offset => 5,
    limit => 10
  });

  ok($expected eq $returned, 'Generates an query with LIMIT and OFFSET');
};

do {
  my $expected = "DELETE FROM example WHERE id = 1";
  my $returned = Api::Query->delete("example", {
    id => 1
  });

  ok($expected eq $returned, 'Generates a deletion query');
};
