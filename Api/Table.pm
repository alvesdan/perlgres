package Api::Table;
use Api::Connection;
our $connection = $Api::Connection::connection;

sub list {
  my @tables = ();
  my $list_query = $connection->prepare(
    "SELECT table_schema,table_name
    FROM information_schema.tables
    WHERE table_type = 'BASE TABLE' AND table_schema = 'public'
    ORDER BY table_schema, table_name"
  );

  $list_query->execute();
  while(my $ref = $list_query->fetchrow_hashref()) {
    push @tables, $ref->{'table_name'}
  };
  \@tables;
};

sub about {
  my ($self, $table_name) = @_;
  my %result = ();
  my $about_query = $connection->prepare(
    "SELECT column_name, data_type, character_maximum_length
    from INFORMATION_SCHEMA.COLUMNS where table_name = '$table_name'"
  );
  $about_query->execute();

  while(my $ref = $about_query->fetchrow_hashref()) {
    $result{$ref->{'column_name'}} = $ref->{'data_type'};
  };
  \%result;
};

sub records {
  my ($self, $table_name) = @_;
  my @result = ();
  my $records_query = $connection->prepare(
    "SELECT * FROM $table_name"
  );
  $records_query->execute();
  while(my $ref = $records_query->fetchrow_hashref()) {
    push @result, $ref;
  };
  \@result;
};

1;
