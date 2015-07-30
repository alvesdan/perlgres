use Mojolicious::Lite;
use Api::Table;

get "/" => sub {
  my $self = shift;
  $self->render(json => Api::Table::list());
};

get "/:table_name/columns" => sub {
  my $self = shift;
  my $table_name = $self->stash('table_name');
  my %columns = Api::Table->columns($table_name);

  $self->render(
    json => \%columns
  );
};

get "/:table_name" => sub {
  my $self = shift;
  my $table_name = $self->stash('table_name');
  my @records = Api::Table->records($table_name);

  $self->render(
    json => \@records
  );
};

post "/:table_name" => sub {
  my $self = shift;
  my $table_name = $self->stash('table_name');
  my $params = $self->req->body_params;
  my $record = Api::Table->insert($table_name, $params);

  $self->render(
    json => $record
  );
};

app->start;

