package Api::Query;
use strict;
use warnings;

sub build {
  my ($self, $table_name, $options) = @_;
  my %options = %$options;
  my @where = ();
  my $query_string = "SELECT * FROM $table_name";
  my $order = "";
  my @columns = ();

  for my $key (sort keys %options) {
    my $where = $options{$key};

    if ($key eq "columns") {
      @columns = @{$where};
    }

    if ($key eq "where") {
      parse_where(\@where, $where);
    }

    if ($key eq "order_by") {
      parse_order(\$order, $where);
    }
  }

  if (@columns) {
    my $columns = join(", ", @columns) if (@columns);
    $query_string = "SELECT $columns FROM $table_name";
  }

  if (@where) {
    my $joined_where = join(" AND ", @where);
    $query_string = $query_string." WHERE $joined_where";
  }

  if (length $order > 0) {
    $query_string = $query_string." $order";
  }

  $query_string;
}

sub parse_where {
  my $where_ref = shift @_;
  my %where_options = %{shift @_};

  for my $key (sort keys %where_options) {
    my $ref = $where_options{$key};
    if (ref($ref) eq "HASH") {
      my %where_option = %where_options{$key};

      for my $option_key (sort keys %where_option) {
        my %attribute_values = %{$where_option{$option_key}};

        for my $attribute_key (sort keys %attribute_values) {
          my $attribute_value = $attribute_values{$attribute_key};
          my $query_string = build_where_query(
            $option_key, $attribute_key, $attribute_value
          );

          push(@{$where_ref}, $query_string) if (length($query_string) > 0);
        }
      }
    } else {
      my $query_string = build_where_query("eq", $key, $ref);
      push(@{$where_ref}, $query_string);
    }
  }
}

sub parse_order {
  my $order_ref = shift;
  my %order_options = %{shift @_};
  my @keys = keys %order_options;

  my $direction = uc(shift(@keys));
  my @columns = @{$order_options{lc $direction}};
  my $joined_columns = join(", ", @columns);
  $$order_ref = "ORDER BY $joined_columns $direction";
}

sub build_where_query {
  my $query_string = "";
  my ($operator, $attr, $value) = @_;

  if ($operator eq "eq") {
    $query_string = "$attr = '$value'";
  }

  if ($operator eq "like") {
    $query_string = "$attr LIKE '$value'";
  }

  if ($operator eq "gt") {
    $query_string = "$attr > '$value'";
  }

  $query_string;
}

1;
