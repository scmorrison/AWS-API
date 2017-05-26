use v6;

use URI;
use URI::Escape;
use AWS::API::Auth::Utils;
use AWS::API::Auth::Credentials;
use AWS::API::Auth::Signatures;

unit module AWS::API::Auth;

our sub validate-config(
    :$config
) is export {
    keys($config) ~~ / 'access_key_id'/ & / 'secret_access_key' /;
}

our sub headers(
    :$http_method,
    :$url,
    :$service,
    :$config,
    :$headers,
    :$body
) is export {

    given validate-config(:$config) {
        when :so {
            my $datetime = DateTime.new(now);
            my %headers = %(
                host       => URI.new($url).authority,
                x-amz-date => date($datetime),
                |$headers
            ) ==> tmp-credentials($config<security_token>);

            my %auth_header = auth-header(
               :$http_method,
               :$url,
               :%headers,
               :$body,
               :$service,
               :$datetime,
               :$config);
           %( %auth_header, |%headers );
        }

    }

}

sub auth-header(
    :$http_method,
    :$url,
    :%headers,
    :$body,
    :$service,
    :$datetime,
    :$config
) is export {

    my $uri       = URI.new: $url;
    my $path      = uri-encode $uri.path;
    my $query     = $uri.query ?? $uri.query !! "";
    my $signature = signature(
        :$http_method,
        :$path,
        :$query,
        :%headers,
        :$body,
        :$datetime,
        :$config);
    %(Authorization => "AWS4-HMAC-SHA256 Credential=" ~
                       generate-credential-v4(:$service, :$config, :$datetime) ~
                       ",SignedHeaders=" ~ signed-headers(%headers) ~ 
                       ",Signature={$signature.perl}");
}

sub signed-headers(%headers) {
    %headers
    ==> map({ .key.lc })
    ==> sort({$^a cmp $^b})
    ==> join(';');
}

sub signature(
    :$http_method,
    :$path,
    :$query,
    :$headers,
    :$body,
    :$service,
    :$datetime,
    :$config
    --> Str
) {
    my $request        = build-canonical-request(:$http_method, :$path, :$query, :$headers, :$body);
    my $string_to_sign = string-to-sign(:$request, :$service, :$datetime, :$config);
    generate-signature-v4(:$service, :$config, :$datetime, :$string_to_sign);
}

sub string-to-sign(
    :$request,
    :$service,
    :$datetime,
    :$config
) {
    "AWS4-HMAC-SHA256\n{amz-date $datetime}\n" ~
    "{generate-credential-scope-v4 :$service, :$config, :$datetime}\n" ~ 
    "{hash-sha256($request)}";
}

our sub presigned-url-headers($url) {
    %( host => URI.new($url).authority );
}

our sub presigned-url(
    :$http_method,
    :$url,
    :$service,
    :$datetime,
    :$config,
    :$expires,
    :$query_params
) is export {

    given validate-config(:$config) {
        when :so {
            my $service_name     = $service;
            my %headers          = presigned-url-headers($url);
            my %amz_query_params = build-amz-query-params(
                service  => $service_name,
                datetime => $datetime,
                config   => $config,
                expires  => $expires
            );

            my ($org_query, $amz_query) = [$query_params, %amz_query_params].map(&canonical-query-params);
            my ($query_to_sign, $query_for_url) = $org_query 
                ?? ("$amz_query&$org_query", "$org_query&$amz_query")
                !! ($amz_query, $amz_query);

            my $uri           = URI.new($url);
            my $path          = $uri.path;
            my $signature     = signature(
                http_method => $http_method,
                path        => $path,
                query       => $query_to_sign,
                headers     => %headers,
                body        => Empty,
                service     => $service,
                datetime    => $datetime,
                config      => $config);

            "{$uri.scheme}://{$uri.authority}$path?$query_for_url&X-Amz-Signature=$signature";

        }

    }

}

sub build-amz-query-params(
    :$service,
    :$datetime,
    :$config,
    :$expires
) {
   [ 
        X-Amz-Algorithm     => "AWS4-HMAC-SHA256",
        X-Amz-Credential    => uri-escape(generate-credential-v4(:$service, :$config, :$datetime)),
        X-Amz-Date          => amz-date($datetime),
        X-Amz-Expires       => $expires,
        X-Amz-SignedHeaders => "host",
        |%( $config<security_token> ?? X-Amz-Security-Token => $config<security_token> !! () )
    ];
}

multi tmp-credentials(%headers, $token) {  %( X-Amz-Security-Token => $token, |%headers ) }
multi tmp-credentials($headers, Any) { $headers }

our sub build-canonical-request(
    :$http_method,
    :$path,
    :$query,
    :%headers,
    :$body
) is export {
    
    my $headers = %headers.map({ .key ~ ':' ~ .value }).join(';').Str;
    my $signed_headers = %headers.keys.join(';').Str;
    my $payload = $body ~~ Empty ?? 'UNSIGNED-PAYLOAD' !! hash-sha256($body);
    "{$http_method.uc}\n{uri-encode($path)}\n$query\n$headers\n\n$signed_headers\n$payload";
}

sub canonical-headers(:%headers) {
    %headers.map({ .key.lc }).sort({$^a cmp $^b});
}

multi sub canonical-query-params(Any) { "" }
multi sub canonical-query-params(%params) {
    %params.sort({ $^a.key cmp $^b.key }).map({ "{.key}={.value}" }).join('&');
}
