package AppResp15;
use Mojo::Base 'Mojolicious', -signatures;
use Mojo::Loader;

has models => sub {
  my $app = shift;
  return +{map {
    my $name = $_;
    my $model;
    if (my $class = $app->load_class("Model::$name")) {
      $model = $class->new(app=>$app);
      if ($model) {
        $app->log->info("Создал модель [$name]");
        $model->init()
          if $model->can('init');
      } else {
        $app->log->error("Не смог создать модель Model::$name");
      }
    } else {
      $app->log->error("Не смог загрузить класс модели Model::$name");
    }
    $model ? ($name => $model) : ();
  } qw(Video)};

};

# This method will run once at server start
sub startup ($self) {

  # Load configuration from config file
  my $config = $self->plugin('Config');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router
  my $r = $self->routes;
  push @{$r->namespaces}, ('Controll');

  # Normal route to controller
  $r->get('/')->to('Main#index');
  $r->get('/video')->to('Main#video');
  $r->websocket('/video/feed/:feed')->to('Main#ws_feed')->name('ws feed');

  $self->hook(before_server_start => 
    sub {
      my ($server, $app) = @_;
      $app->attr( 'server_engine' => sub { $server } );# это  пригодится
    }
  )
}

sub load_class {
  my ($self, $class) = @_;
  # if (@_ == 1 && ! ref $_[0]) {$class = shift}
  # else {
  #   my $conf = ref $_[0] ? shift : {@_};
  #   $class  = join '::', $conf->{namespace} ? ($conf->{namespace}) : (), $conf->{module} || $conf->{controller} || $conf->{package};
  # }

  my $e; $e = Mojo::Loader::load_class($class)# success undef
    and ($e eq 1 ? 1 : warn("None load_class[$class]: ", $e)) # warn("Class [$class] not found ", sprintf("[%s] [%s] [%s]", caller))
    and return undef;
  return $class;
}

1;
