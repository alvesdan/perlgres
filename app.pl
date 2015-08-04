use Mojolicious::Lite;
use lib 'lib';
use Api::Table;

get "/" => sub {
  my $self = shift;
  my @tables = Api::Table::list();
  $self->render(json => \@tables);
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

get "/:table_name/:id" => sub {
  my $self = shift;
  my $table_name = $self->stash('table_name');
  my $id = $self->stash('id');
  my $record = Api::Table->record($table_name, $id);

  $self->render(
    json => $record
  );
};

app->start;
