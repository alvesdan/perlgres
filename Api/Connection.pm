package Api::Connection;
use DBI;
use vars('$connection');

sub create_connection {
  my $database = $ENV{"DB_NAME"};
  my $host = $ENV{"DB_HOST"};
  my $username = $ENV{"DB_USERNAME"};
  my $password = $ENV{"DB_PASSWORD"};

  my $connection = DBI->connect(
    "DBI:Pg:dbname=$database;host=$host",
    $username,
    $password,
    {'RaiseError' => 1}
  );
  return $connection;
};

$connection = create_connection();

1;
