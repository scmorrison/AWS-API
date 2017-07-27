use AWS::API::Config::Defaults;

unit module AWS::API::Config;

my @common_config = [
    'http_client',
    'json_codec', 
    'access_key_id',
    'secret_access_key',
    'debug_requests',
	'region',
    'security_token',
    'retries'];

our sub env-defaults($env = 'dev') {
    %();
}

our sub new(
    $service, %opts = %()
) { 
    ($service
     ==> build-base(overrides => %opts)
     ==> retrieve-runtime-config()
     ==> parse-host-for-region());
}

our sub build-base(
    $service!, :%overrides = %()
) is export {
    my %defaults       = config-defaults($service);
    my %common_config  = %(); #(env-defaults{|@common_config}:kv).Map;
    my %service_config = (%*ENV<service>:kv).Map;

    %(%defaults, %common_config, %overrides);
}

sub retrieve-runtime-config($config) {
    my %config = gather {
        $config.grep: -> $p {
            next unless $p.key.defined && $p.value.defined;
            given $p {
                when .key ~~ 'host' {
                    take Pair.new('host', retrieve-runtime-value(.value, %config));
                    #%config<host> = retrieve-runtime-value(.value, %config);
                };
                when .key ~~ 'retries' {
                    take Pair.new('retries', .value);
                    #%config<retries> = .value;
                }
                when .key ~~ 'http_opts' {
                    take Pair.new('http_opts', .value);
                    #%config<http_opts> = .value;
                }
                default {
                    take Pair.new(.key, retrieve-runtime-value($p, $config));
                    #%config{.key} = retrieve-runtime-value($p, $config);
                }
            }
        }
    };
    return %config;
}


subset MiscValue of Any where * ~~ Str|Bool;

our proto retrieve-runtime-value(|) {*}
multi retrieve-runtime-value(Pair $value, %config where { $value.key ~~ 'system'}) {
    note "value 1: {$value.perl}";
    %*ENV{$value.value};
}

multi retrieve-runtime-value(Pair $value, %config where { $value.key ~~ 'instance_role'}) {
    note "value 5: {$value.perl}";
    $value;
}

multi retrieve-runtime-value(Pair $value, %config where { $value.key ~~ 'awscli'}) {
    note "value 6: {$value.perl}";
    $value;
}

multi retrieve-runtime-value(%values, %config) {
    note "value 3: {%values.perl}";
	map -> $k, $v {
        note "value 3.5: {$k}";
        retrieve-runtime-value($v, %config)
    }, %values.kv;
}

multi retrieve-runtime-value($value where { !$value.defined  }, %config) {  $value }
multi retrieve-runtime-value(MiscValue $value, %config) { note "value 2: {$value.perl}"; $value }
multi retrieve-runtime-value($value, %config) { note "value 4: {$value.perl}";  }

sub parse-host-for-region($config) { $config }
