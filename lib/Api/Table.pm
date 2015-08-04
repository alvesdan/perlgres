package Api::Table;
use Api::Connection;
our $connection = Api::Connection->create_connection();

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
  @tables;
};

sub columns {
  my ($self, $table_name) = @_;
  my %result = ();
  my $columns_query = $connection->prepare(
    "SELECT column_name, data_type, character_maximum_length
    from INFORMATION_SCHEMA.COLUMNS where table_name = '$table_name'"
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
    "SELECT * FROM $table_name"
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
  my @columns = ();
  my @values = ();
  my $error;

  foreach $key (keys %columns) {
    $insert_attributes{"$key"} = $params->param("$key");
  };

  delete @insert_attributes{qw(id)};

  foreach $key (sort keys %insert_attributes) {
    my $value = $insert_attributes{"$key"};
    if ($value) {
      push @columns, $key;
      push @values, "'$value'";
    }
  };

  if ($columns{"created_at"}) {
    unless (grep {$_ eq "created_at"} @columns) {
      push @columns, "created_at";
      push @values, escape_string(current_timestamp());
      push @columns, "updated_at";
      push @values, escape_string(current_timestamp());
    }
  }

  my $columns_string = join(", ", @columns);
  my $values_string = join(", ", @values);

  $connection->{HandleError} = sub {
    $error = $DBI::errstr
  };

  my $record = $connection->do(
    "INSERT INTO $table_name($columns_string)
    VALUES($values_string)"
  );

  return { error => $error } if $error;
  # TODO: Return the record ID
  { success => 1 };
}

sub record {
  my ($self, $table_name, $id) = @_;
  my %columns = Api::Table->columns($table_name);
  my $record_column = "id";
  unless (grep {$_ eq "id"} @columns) {
    $record_column = $table_name."_id";
  }
  my $record_query = $connection->prepare(
    "SELECT * FROM $table_name WHERE $record_column = $id"
  );
  $record_query->execute();
  $record_query->fetchrow_hashref();
}

sub current_timestamp {
  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);
  "$year-$mon-$mday $hour:$min:$sec"
}

sub escape_string {
  my $string = shift;
  "'$string'";
}

1;
