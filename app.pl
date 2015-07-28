use Mojolicious::Lite;
use Api::Table;
use 5.20.0;

get "/" => sub {
  my $self = shift;
  $self->render(json => Api::Table::list());
};

get "/:table_name" => sub {
  my $self = shift;
  my $log = Mojo::Log->new;
  my $table_name = $self->stash('table_name');

  $self->render(
    json => Api::Table->about($table_name)
  );
};

app->start;

