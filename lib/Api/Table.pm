package Api::Table;
use Api::Connection;
use Api::Query;
our $connection = Api::Connection->create_connection();

sub list {
  my @tables = ();
  my $list_query = $connection->prepare(
    Api::Query->select("information_schema.tables", {
      columns => ["table_schema", "table_name"],
      where => {
        eq => {
          table_type => 'BASE TABLE',
          table_schema => 'public'
        }
      },
      orber_by => {
        asc => ["table_schema", "table_name"]
      }
    })
  );

  $list_query->execute();
  while(my $ref = $list_query->fetchrow_hashref()) {
    push @tables, $ref->{'table_name'}
  };
  @tables;
};

sub columns {
  my ($self, $table_name) = @_;
  my %result = ();
  my $columns_query = $connection->prepare(
    Api::Query->select("information_schema.columns", {
      colums => ["column_name", "data_type", "character_maximum_length"],
      where => {
        eq => { table_name => $table_name }
      }
    })
  );
  $columns_query->execute();

  while(my $ref = $columns_query->fetchrow_hashref()) {
    $result{$ref->{'column_name'}} = $ref->{'data_type'};
  };
  %result;
};

sub records {
  my ($self, $table_name) = @_;
  my @result = ();
  my $records_query = $connection->prepare(
    Api::Query->select($table_name, {})
  );
  $records_query->execute();
  while(my $ref = $records_query->fetchrow_hashref()) {
    push @result, $ref;
  };
  @result;
};

sub insert {
  my ($self, $table_name, $params) = @_;
  my %columns = Api::Table->columns($table_name);
  my %insert_attributes = ();
  my $error;

  foreach $key (keys %columns) {
    if ($key ne "id" ) {
      $insert_attributes{$key} = $params->param($key);
    }
  };

  $connection->{HandleError} = sub {
    $error = $DBI::errstr
  };

  my $record = $connection->do(
    Api::Query->insert($table_name, \%insert_attributes)
  );

  return { error => $error } if $error;

  my $record_column = identifier($table_name);
  my $last_record_query = $connection->prepare(
    Api::Query->select($table_name, {
      order_by => {
        desc => [$record_column]
      },
      limit => 1
    })
  );

  $last_record_query->execute();
  $last_record_query->fetchrow_hashref();
}

sub record {
  my ($self, $table_name, $id) = @_;
  my $record_column = identifier($table_name);
  my $record_query = $connection->prepare(
    Api::Query->select($table_name, {
      where => { "$record_column" => $id },
      limit => 1
    })
  );
  $record_query->execute();
  $record_query->fetchrow_hashref();
}

sub identifier {
  $table_name = shift;
  my %columns = Api::Table->columns($table_name);
  my $record_column = "id";
  unless (grep {$_ eq "id"} @columns) {
    $record_column = $table_name."_id";
  }
  $record_column;
}

1;

