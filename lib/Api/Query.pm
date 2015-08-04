package Api::Query;
use strict;
use warnings;

sub build {
  my ($self, $table_name, $options) = @_;
  my %options = %$options;
  my @wheres = ();
  my $query_string = "SELECT * FROM $table_name";

  for my $key (sort keys %options) {
    if ($key eq "where") {
      my $where = $options{$key};
      parse_wheres(\@wheres, $where);
    }
  }

  if (@wheres) {
    my $joined_wheres = join(" AND ", @wheres);
    $query_string = $query_string." WHERE $joined_wheres";
  }

  $query_string;
}

sub parse_wheres {
  my $wheres = shift @_;
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

          push(@{$wheres}, $query_string) if (length($query_string) > 0);
        }
      }
    } else {
      my $query_string = build_where_query("eq", $key, $ref);
      push(@{$wheres}, $query_string);
    }
  }
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
