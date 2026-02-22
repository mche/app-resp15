package Controll::Main;
use Mojo::Base 'Mojolicious::Controller', -signatures;

has model => sub { $_[0]->app->models->{'Video'} };


# This action will render a template
sub index ($self) {
  $self->render(title => 'Main', msg => 'OK here!');
}

sub video ($self) {
  $self->render(title => 'Камеры', cams => ['cam1']);
}

sub ws_feed {
  my $ws = shift;
  #~ $ws->inactivity_timeout(300);# переподключение вебсокета
  $ws->tx->with_protocols('binary', 'null');# null - google chrome!
  
  my $feed = $ws->param('feed')
    or return $ws->send({json   => {error=>"none param feed?"}});#=> sub { $ws->log->error("Sended", $ws->req->headers->user_agent)});
  
  my $r = $ws->model->subws($ws, $feed);
  return $ws->send({json   => {error=>$r}})
    unless ref $r;
  
  $ws->on(
    finish => sub {
      #~ my( $ws, $code, $reason ) = @_ ;
      $ws->model->unsubws($ws, $feed);
    }
  );
  
}

1;
