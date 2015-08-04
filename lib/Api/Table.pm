package Api::Table;
use Api::Connection;
use Api::Query;
our $connection = Api::Connection->create_connection();

sub list {
  my @tables = ();
  my $list_query = $connection->prepare(
    Api::Query->build("information_schema.tables", {
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
    Api::Query->build("information_schema.columns", {
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
    Api::Query->build($table_name, {})
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

  my $record_column = identifier($table_name);
  my $last_record_query = $connection->prepare(
    Api::Query->build($table_name, {
      order_by => {
        desc => [$record_column]
      }
    })
  );
  $last_record_query->execute();
  $last_record_query->fetchrow_hashref();
}

sub record {
  my ($self, $table_name, $id) = @_;
  my $record_column = identifier($table_name);
  my $record_query = $connection->prepare(
    Api::Query->build($table_name, {
      where => { "$record_column" => $id }
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

sub current_timestamp {
  ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = gmtime(time);
  "$year-$mon-$mday $hour:$min:$sec"
}

sub escape_string {
  my $string = shift;
  "'$string'";
}

1;
