/*
 * Varnish 4 example config for Drupal 7 / Pressflow 6 & 7
 */

# Original source: https://github.com/NITEMAN/varnish-bites/varnish4/drupal-base.vcl
# Copyright (c) 2015 Pedro González Serrano and individual contributors.
# MIT License

# Intended to be used both in simple production environments and with
# learning/teaching purposes.
# Some references may not be yet updated to VCL 4.0, we use SeeV3 then.

# WARNING:
# Note that the built-in logic will be appended to our code if no return is
# performed before.
# Built-in logic is included commented out right after our's for reference
# purposes in that cases.
# See https://www.varnish-cache.org/trac/wiki/VCLExampleDefault

#######################################################################
# Initialization: Version & imports;

/* Version statement */
# Since Varnish 4.0 it's mandatory to declare VCL version on first line.
vcl 4.0;

/* Module (VMOD) imports */
# Standard module
# See https://www.varnish-cache.org/docs/4.0/reference/vmod_std.generated.html
import std;

# Directors module
# See https://www.varnish-cache.org/docs/4.0/reference/vmod_directors.generated.html
# Unused in simple configs.
#import directors;


#######################################################################
# Probe, backend, ACL and subroutine definitions

/* Backend probes / healthchecks */
# See https://www.varnish-cache.org/docs/4.0/reference/vcl.html#probes
probe basic {
  /* Only test that backend's IP serves content for '/' */
  # This might be a too heavy probe
  # .url = "/";

  /* Only test that backend's IP has apache working */
  # Nginx would fail this probe with a default config
  .request =
    "OPTIONS * HTTP/1.1"
    "Host: localhost"
    "Connection: close";

  /* Common options */
  .interval = 10s;
  .timeout = 2s;
  .window = 8;
  .threshold = 6;
}

/* Backend definitions.*/
# See https://www.varnish-cache.org/docs/4.0/reference/vcl.html#backend-definition
backend default {
  /* Default backend on the same machine. */
  # WARNING: timeouts could be not big enought for certain POST requests.
  .host = "web";
  .port = "80";
  .max_connections = 100;
  .connect_timeout = 60s;
  .first_byte_timeout = 60s;
  .between_bytes_timeout = 60s;
  .probe = basic;
}

/* Access Control Lists */
# See https://www.varnish-cache.org/docs/4.0/reference/vcl.html#access-control-list-acl
acl purge_ban {
  /* Simple access control list for allowing item purge for the self machine */
   "web"/32; // We can use '"localhost";' instead
}
acl allowed_monitors {
  /* Simple access control list for allowing item purge for the self machine */
  "web"/32; // We can use '"localhost";' instead
}
# acl own_proxys {
#   "web"/32; // We can use '"localhost";' instead
# }

/* Custom subroutines */
# See https://www.varnish-cache.org/docs/4.0/reference/vcl.html#subroutines
#TODO# Test in Varnihs 4
# Empty in simple configs.
# The only restriction naming subs is that the 'vlc_' prefix is reserverd for
# Varnish use. As a task can need several chunks of code in diferent states,
# it's a good idea to identify what main sub will call each with a suffix.
# /* Example 301 client redirection removing "www" prefix from request */
# sub perm_redirections_recv {
#   if ( req.http.host ~ "^www.*$" ) {
#     return (
#       synth(751, "http://" + regsub(req.http.host, "^www\.", "") + req.url)
#     );
#   }
# }
# sub perm_redirections_synth {
#   if ( resp.status == 751 ) {
#     /* Get new URL from the response */
#     set resp.http.Location = resp.reason;
#     /* Set HTTP 301 for permanent redirect */
#     set resp.status = 301;
#     set resp.reason = "Moved Permanently";
#     return (deliver);
#   }
# }


#######################################################################
# Client side

# vcl_recv: Called at the beginning of a request, after the complete request
# has been received and parsed. Its purpose is to decide whether or not to
# serve the request, how to do it, and, if applicable, which backend to use.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-recv
sub vcl_recv {
  /* 0th: general bypass, general return & authorization checks */
  # Empty in simple configs.
  # Useful for debugging we can pipe or pass the request to default backend
  # here to bypass completely Varnish.
  # return (pipe);
  # return (pass);
  # We can also return here a 200 Ok for network performance benchmarking.
  # return (synth(200, "Ok"));
  # Finally we can perform basic HTTP authentification here, by example.
  # SeeV3 http://blog.tenya.me/blog/2011/12/14/varnish-http-authentication/

  /* 1st: Check for Varnish special requests */
  # Custom response implementation example in order to check that Varnish is
  # working properly.
  # This is usefull for automatic monitoring with monit or when Varnish is
  # behind another proxies like HAProxy.
  if ( ( req.http.host == "monitor.server.health"
      || req.http.host == "health.varnish" )
    && client.ip ~ allowed_monitors
    && ( req.method == "OPTIONS" || req.method == "GET" )
  ) {
    return (synth(200, "OK"));
  }
  # Purge logic
  # See https://www.varnish-cache.org/docs/4.0/users-guide/purging.html#http-purging
  # SeeV3 https://www.varnish-software.com/static/book/Cache_invalidation.html#removing-a-single-object
  if ( req.method == "PURGE" ) {
    if ( client.ip !~ purge_ban ) {
      return (synth(405, "Not allowed."));
    }
    return (purge);
  }
  # Ban logic
  # See https://www.varnish-cache.org/docs/4.0/users-guide/purging.html#bans
  if ( req.method == "BAN" ) {
    if ( client.ip !~ purge_ban ) {
      return (synth(405, "Not allowed."));
    }
    ban( "req.http.host == " + req.http.host +
      "&& req.url == " + req.url);
    return (synth(200, "Ban added"));
  }

  /* 2nd: Do some Varnish black magic such as custom client redirections */
  # Empty in simple configs.
  # call perm_redirections_recv;
  # Here we can also enforce SSL when Varnish run behind some SSL termination
  # point.

  /* 3rd: Time for backend choice */
  # Empty in simple configs.

  /* 4th: Prepare request for the backend */
  # Empty in simple configs.
  # Example remove own_proxys from X-Forwarded-For
  # See https://www.varnish-cache.org/docs/4.0/whats-new/upgrading.html#x-forwarded-for-is-now-set-before-vcl-recv
  # Varnish 4 regsub doesn't accept anything but plain regexp, so we can't use
  # client.ip to exclude the proxy ips from the request:
  #   set req.http.X-Forwarded-For
  #     = regsub(req.http.X-Forwarded-For, ",( )?" + client.ip, "");
  # Instead, we need to add the proxy ips manually in the exclude list:
  # if ( req.restarts == 0
  #   && client.ip ~ own_proxys
  #   && req.http.x-forwarded-for
  # ) {
  #   set req.http.X-Forwarded-For
  #     = regsub(req.http.X-Forwarded-For,
  #         "(, )?(10\.10\.10\.10|10\.11\.11\.11)", "");
  # }
  # An alternative could be to skip all this and try to modify the header
  # manually so Varnish doesn't touch it.
  # set req.http.X-Forwarded-For = req.http.X-Forwarded-For + "";
  #
  # Example normalize the host header, remove the port (in case you're testing
  # this on various TCP ports)
  # set req.http.Host = regsub(req.http.Host, ":[0-9]+", "");

  /* 5th: Bypass breakpoint 1 */
  # Useful for debugging we can now pipe or pass the request to backend with
  # headers setted.
  # return (pipe);
  # return (pass);

  /* 6th: Decide if we should deal with a request (mostly from built-in logic) */
  if ( req.method == "PRI" ) {
    /* We do not support SPDY or HTTP/2.0 */
    return (synth(405));
  }
  if ( req.method != "GET"
    && req.method != "HEAD"
    && req.method != "PUT"
    && req.method != "POST"
    && req.method != "TRACE"
    && req.method != "OPTIONS"
    && req.method != "DELETE"
  ) {
    /* Non-RFC2616 or CONNECT which is weird. */
    return (pipe);
  }
  if ( req.method != "GET"
    && req.method != "HEAD"
  ) {
    /* We only deal with GET and HEAD by default */
    return (pass);
  }
  if ( req.http.Authorization ) {
    /* Not cacheable by default */
    return (pass);
  }
  # Websocket support
  # See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html
  if ( req.http.Upgrade ~ "(?i)websocket" ) {
    return (pipe);
  }

  /* 7th: Access control for some URLs by ACL */
  # Empty in simple configs.
  # By example denial some URLs depending on client-ip, we'll need to define
  # corresponding ACL 'internal'.
  # if ( req.url ~ "^/(cron|install)\.php"
  #   && client.ip !~ internal
  # ) {
  #   # Have Varnish throw the error directly.
  #   return (synth(403, "Forbidden."));
  #   # Use a custom error page that you've defined in Drupal at the path "404".
  #   # set req.url = "/403";
  # }

  /* 8th: Custom exceptions */
  # Host exception example:
  # if ( req.http.host == "ejemplo.exception.com" ) {
  #     return (pass);
  # }
  # Drupal exceptions, edit if we want to cache some AJAX/AHAH request.
  # Add here filters for never cache URLs such as Payment Gateway's callbacks.
  if ( req.url ~ "^/status\.php$"
    || req.url ~ "^/update\.php$"
    || req.url ~ "^/ooyala/ping$"
    || req.url ~ "^/admin/build/features"
    || req.url ~ "^/info/.*$"
    || req.url ~ "^/flag/.*$"
    || req.url ~ "^.*/ajax/.*$"
    || req.url ~ "^.*/ahah/.*$"
  ) {
    /* Do not cache these paths */
    return (pass);
  }
  # Pipe these paths directly to backend for streaming.
  if ( req.url ~ "^/admin/content/backup_migrate/export"
    || req.url ~ "^/admin/config/system/backup_migrate"
  ) {
    return (pipe);
  }
  if ( req.url ~ "^/system/files" ) {
    return (pipe);
  }

  /* 9th: Graced objets & Serve from anonymous cahe if all backends are down */
  # See https://www.varnish-software.com/blog/grace-varnish-4-stale-while-revalidate-semantics-varnish
  # set req.http.grace = "none";
  if ( ! std.healthy(req.backend_hint) ) {
    # We must do this here since cookie hashing
    unset req.http.Cookie;
    #TODO# Add sick marker
  }

  /* 10th: Deal with compression and the Accept-Encoding header */
  # Althought Varnish 3 handles gziped content itself by default, just to be
  # sure we want to remove Accept-Encoding for some compressed formats.
  # See https://www.varnish-cache.org/docs/4.0/phk/gzip.html#what-does-http-gzip-support-do
  # See https://www.varnish-cache.org/docs/4.0/users-guide/compression.html
  # See https://www.varnish-cache.org/docs/4.0/reference/varnishd.html?highlight=http_gzip_support
  # See (for older configs) https://www.varnish-cache.org/trac/wiki/VCLExampleNormalizeAcceptEncoding
  if ( req.http.Accept-Encoding ) {
    if ( req.url ~ "(?i)\.(7z|avi|bz2|flv|gif|gz|jpe?g|mpe?g|mk[av]|mov|mp[34]|og[gm]|pdf|png|rar|swf|tar|tbz|tgz|woff2?|zip|xz)(\?.*)?$"
    ) {
      /* Already compressed formats, no sense trying to compress again */
      unset req.http.Accept-Encoding;
    }
  }

  /* 11th: Further request manipulation */
  # Empty in simple configs.
  # We could add here a custom header grouping User-agent families.
  # Generic URL manipulation.
  # Remove Google Analytics added parameters, useless for our backends.
  if ( req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=" ) {
    set req.url = regsuball(req.url, "&(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "");
    set req.url = regsuball(req.url, "\?(utm_source|utm_medium|utm_campaign|utm_content|gclid|cx|ie|cof|siteurl)=([A-z0-9_\-\.%25]+)", "?");
    set req.url = regsub(req.url, "\?&", "?");
    set req.url = regsub(req.url, "\?$", "");
  }
  # Strip anchors, server doesn't need it.
  if ( req.url ~ "\#" ) {
    set req.url = regsub(req.url, "\#.*$", "");
  }
  # Strip a trailing ? if it exists
  if ( req.url ~ "\?$" ) {
    set req.url = regsub(req.url, "\?$", "");
  }
  # Normalize the querystring arguments
  set req.url = std.querysort(req.url);

  /* 12th: Cookie removal */
  # Always cache the following static file types for all users.
  # Use with care if we control certain downloads depending on cookies.
  # Be carefull also if appending .htm[l] via Drupal's clean URLs.
  if ( req.url ~ "(?i)\.(bz2|css|eot|gif|gz|html?|ico|jpe?g|js|mp3|ogg|otf|pdf|png|rar|svg|swf|tbz|tgz|ttf|woff2?|zip)(\?(itok=)?[a-z0-9_=\.\-]+)?$"
    && req.url !~ "/system/storage/serve"
  ) {
      unset req.http.Cookie;
  }
  # Remove all cookies that backend doesn't need to know about.
  # See https://www.varnish-cache.org/trac/wiki/VCLExampleRemovingSomeCookies
  if ( req.http.Cookie ) {
    /* Warning: Not a pretty solution */
    # Prefix header containing cookies with ';'
    set req.http.Cookie = ";" + req.http.Cookie;
    # Remove any spaces after ';' in header containing cookies
    set req.http.Cookie = regsuball(req.http.Cookie, "; +", ";");
    # Prefix cookies we want to preserve with one space:
    #   'S{1,2}ESS[a-z0-9]+' is the regular expression matching a Drupal session
    #   cookie ({1,2} added for HTTPS support).
    #   'NO_CACHE' is usually set after a POST request to make sure issuing user
    #   see the results of his post.
    #   'OATMEAL' & 'CHOCOLATECHIP' are special cookies used by Drupal's Bakery
    #   module to provide Single Sign On.
    # Keep in mind we should add here any cookie that should reach the backend
    # such as splash avoiding cookies.
    set req.http.Cookie
      = regsuball(
          req.http.Cookie,
          ";(S{1,2}ESS[a-z0-9]+|NO_CACHE|OATMEAL|CHOCOLATECHIP)=",
          "; \1="
        );
    # Remove from the header any single Cookie not prefixed with a space until
    # next ';' separator.
    set req.http.Cookie = regsuball(req.http.Cookie, ";[^ ][^;]*", "");
    # Remove any '; ' at the start or the end of the header.
    set req.http.Cookie = regsuball(req.http.Cookie, "^[; ]+|[; ]+$", "");
    #If there are no remaining cookies, remove the cookie header.
    if ( req.http.Cookie == "" ) {
      unset req.http.Cookie;
    }
  }

  /* 13th: Session cookie & special cookies bypass caching stage */
  # As we might want to cache some requests, hashed with its cookies, we don't
  # simply pass when some cookies remain present at this point.
  # Instead we look for request that must be passed due to the cookie header.
  if ( req.http.Cookie ~ "SESS"
    || req.http.Cookie ~ "SSESS"
    || req.http.Cookie ~ "NO_CACHE"
    || req.http.Cookie ~ "OATMEAL"
    || req.http.Cookie ~ "CHOCOLATECHIP"
  ) {
    return (pass);
  }

  /* 14th: Announce ESI Support */
  # Empty in simple configs.
  # See https://www.varnish-cache.org/docs/4.0/users-guide/esi.html
  # Note that ESI included requests inherits its parent's modified request, so
  # depending on the case you will end playing with req.esi_level to know
  # current depth.
  # Send Surrogate-Capability headers
  # See http://www.w3.org/TR/edge-arch
  # Note that myproxyname is an identifier that should avoid collitions
  # set req.http.Surrogate-Capability = "myproxyname=ESI/1.0";

  /* 15th: Bypass breakpoint 2 */
  # Useful for debugging we can now pipe or pass the request to backend to
  # bypass cache.
  # return (pipe);
  # return (pass);

  /* 16th: Bypass built-in logic */
  # We make sure no built-in logic is processed after ours returning
  # inconditionally.
  return (hash);
}

# vcl_pipe: Called upon entering pipe mode.
# In this mode, the request is passed on to the backend, and any further data
# from either client or backend is passed on unaltered until either end closes
# the connection.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-pipe
sub vcl_pipe {
  # Websocket support
  # See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-example-websockets.html
  if ( req.http.upgrade ) {
    set bereq.http.upgrade = req.http.upgrade;
  }
}
# sub vcl_pipe {
#     # By default Connection: close is set on all piped requests, to stop
#     # connection reuse from sending future requests directly to the
#     # (potentially) wrong backend. If you do want this to happen, you can undo
#     # it here.
#     # unset bereq.http.connection;
#     return (pipe);
# }

# vcl_pass: Called upon entering pass mode.
# In this mode, the request is passed on to the backend, and the backend's
# response is passed on to the client, but is not entered into the cache.
# Subsequent requests submitted over the same client connection are handled normally.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-pass
# sub vcl_pass {
#     return (fetch);
# }

# vcl_hash: You may call hash_data() on the data you would like to add to the
# hash.
# Hash is used by Varnish to uniquely identify objects.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-hash
sub vcl_hash {
  /* Hash cookie data */
  # As requests with same URL and host can produce diferent results when issued
  # with different cookies, we need to store items hashed with the associated
  # cookies. Note that cookies are already sanitized when we reach this point.
  if ( req.http.Cookie ) {
    /* Include cookie in cache hash */
    hash_data(req.http.Cookie);
  }

  /* Custom header hashing */
  # Empty in simple configs.
  # Example for caching differents object versions by device previously
  # detected (when static content could also vary):
  # if ( req.http.X-UA-Device ) {
  #   hash_data(req.http.X-UA-Device);
  # }
  # Example for caching diferent object versions by X-Forwarded-Proto, trying
  # to be smart about what kind of request could generate diffetent responses.
  if ( req.http.X-Forwarded-Proto
    && req.url !~ "(?i)\.(bz2|css|eot|gif|gz|html?|ico|jpe?g|js|mp3|ogg|otf|pdf|png|rar|svg|swf|tbz|tgz|ttf|woff2?|zip)(\?(itok=)?[a-z0-9_=\.\-]+)?$"
  ) {
    hash_data(req.http.X-Forwarded-Proto);
  }

  /* Continue with built-in logic */
  # We want built-in logic to be processed after ours so we don't call return.
}
# sub vcl_hash {
#     hash_data(req.url);
#     if (req.http.host) {
#         hash_data(req.http.host);
#     } else {
#         hash_data(server.ip);
#     }
#     return (lookup);
# }

# vcl_purge: Called after the purge has been executed and all its variants have
# been evited.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-purge
# sub vcl_purge {
#     return (synth(200, "Purged"));
# }

# vcl_hit: Called after a cache lookup if the requested document was found in
# the cache.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-hit
sub vcl_hit {
  if ( obj.ttl >= 0s ) {
    // A pure unadultered hit, deliver it
    return (deliver);
  }
  /* Allow varnish to serve up stale content if it is responding slowly */
  # See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-grace.html
  # See https://www.varnish-software.com/blog/grace-varnish-4-stale-while-revalidate-semantics-varnish
  if ( obj.ttl + 60s > 0s ) {
    // Object is in grace, deliver it
    // Automatically triggers a background fetch
    set req.http.grace = "normal";
    return (deliver);
  }
  /* Allow varish to serve up stale content if all backends are down */
  # See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-grace.html
  # See https://www.varnish-software.com/blog/grace-varnish-4-stale-while-revalidate-semantics-varnish
  if ( ! std.healthy(req.backend_hint)
    && obj.ttl + obj.grace > 0s
  ) {
    // Object is in grace, deliver it
    // Automatically triggers a background fetch
    set req.http.grace = "extended";
    return (deliver);
  }
  /* Bypass built-in logic */
  # We make sure no built-in logic is processed after ours returning
  # inconditionally.
  // fetch & deliver once we get the result
  return (fetch);
}

# vcl_miss: Called after a cache lookup if the requested document was not found
# in the cache.
# Its purpose is to decide whether or not to attempt to retrieve the document
# from the backend, and which backend to use.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-miss
# sub vcl_miss {
#     return (fetch);
# }

# vcl_deliver: Called before an object is delivered to the client
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-deliver
sub vcl_deliver {
  /* Debugging headers */
  # Please consider the risks of showing publicly this information, we can wrap
  # this with an ACL.
  # Add whether the object is a cache hit or miss and the number of hits for
  # the object.
  # SeeV3 https://www.varnish-cache.org/trac/wiki/VCLExampleHitMissHeader#Addingaheaderindicatinghitmiss
  # In Varnish 4 the obj.hits counter behaviour has changed (see bug 1492), so
  # we use a different method: if X-Varnish contains only 1 id, we have a miss,
  # if it contains more (and therefore a space), we have a hit.
  if ( resp.http.x-varnish ~ " " ) {
    set resp.http.X-Cache = "HIT";
    # Since in Varnish 4 the behaviour of obj.hits changed, this might not be
    # accurate.
    # See https://www.varnish-cache.org/trac/ticket/1492
    set resp.http.X-Cache-Hits = obj.hits;
  } else {
    set resp.http.X-Cache = "MISS";
    /* Show the results of cookie sanitization */
    set resp.http.X-Cookie = req.http.Cookie;
  }
  # See https://www.varnish-software.com/blog/grace-varnish-4-stale-while-revalidate-semantics-varnish
  set resp.http.grace = req.http.grace;

  #TODO# Add sick marker

  # Restart count
  if ( req.restarts > 0 ) {
    set resp.http.X-Restarts = req.restarts;
  }

  # Add the Varnish server hostname
  set resp.http.X-Varnish-Server = server.hostname;
  # If we have setted a custom header with device's family detected we can show
  # it:
  # if ( req.http.X-UA-Device ) {
  #   set resp.http.X-UA-Device = req.http.X-UA-Device;
  # }
  # If we have recived a custom header indicating the protocol in the request we
  # can show it:
  # if ( req.http.X-Forwarded-Proto ) {
  #   set resp.http.X-Forwarded-Proto = req.http.X-Forwarded-Proto;
  # }

  /* Vary header manipulation */
  # Empty in simple configs.
  # By example, if we are storing & serving diferent objects depending on
  # User-Agent header we must set the correct Vary header:
  # if ( resp.http.Vary ) {
  #   set resp.http.Vary = resp.http.Vary + ",User-Agent";
  # } else {
  #   set resp.http.Vary = "User-Agent";
  # }

  /* Fake headers */
  # Empty in simple configs
  # We can fake server headers here, by example:
  # set resp.http.Server = "Deep thought";
  # set resp.http.X-Powered-By = "BOFH";
  # Or have some fun with headers:
  # See http://www.nextthing.org/archives/2005/08/07/fun-with-http-headers
  # See http://royal.pingdom.com/2012/08/15/fun-and-unusual-http-response-headers/
  # set resp.http.X-Thank-You = "for bothering to look at my HTTP headers";
  # set resp.http.X-Answer = "42";

  /* Continue with built-in logic */
  # We want built-in logic to be processed after ours so we don't call return.
}
# sub vcl_deliver {
#     return (deliver);
# }

# vcl_synth: Called to deliver a synthetic object. A synthetic object is
# generated in VCL, not fetched from the backend. It is typically contructed
# using the synthetic() function.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-synth
/*
 * We can come here "invisibly" with the following errors: 413, 417 & 503
 */
sub vcl_synth {
  /* Do some Varnish black magic such as custom client redirections */
  # Empty in simple configs.
  # call perm_redirections_synth;

  /* Try to restart request in case of failure */
  # Note that max_restarts defaults to 4
  # SeeV3 https://www.varnish-cache.org/trac/wiki/VCLExampleRestarts
  if ( resp.status == 503
    && req.restarts < 4
  ) {
    return (restart);
  }

  /* Set common headers for synthetic responses */
  set resp.http.Content-Type = "text/html; charset=utf-8";

  /* HTTP Authentification client request */
  # Empty in simple configs.
  # SeeV3 http://blog.tenya.me/blog/2011/12/14/varnish-http-authentication/

  /* Load synthetic responses from disk */
  # Note that files loaded this way are never re-readed (even after a reload).
  # You should consider PROS/CONS of doing an include instead.
  # See https://www.varnish-cache.org/docs/4.0/reference/vmod_std.generated.html#func-fileread
  # Example custom 403 error page.
  # if ( resp.status == 403 ) {
  #   synthetic(std.fileread("/403.html"));
  #   return (deliver);
  # }

  /* Error page & refresh / redirections */
  # We have plenty of choices when we have to serve an error to the client,
  # from the default error page to javascript black magic or plain redirections.
  # Adding some external statistic javascript to track failures served to
  # clients is strongly suggested.
  # We can't use external resources on synthetic content, everything must be
  # inlined.
  # If we need to include images we can embed them in base64 encoding.
  # We're using error 200 for monitoring puposes which should not be retried
  # client side.
  if ( resp.status != 200 ) {
    set resp.http.Retry-After = "5";
  }

  # Here is the default error page for Varnish 4 (not so pretty)
  synthetic( {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + resp.status + " " + resp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + resp.status + " " + resp.reason + {"</h1>
    <p>"} + resp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + req.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"} );

  /* Bypass built-in logic */
  # We make sure no built-in logic is processed after ours returning
  # inconditionally.
  return (deliver);
}

#######################################################################
# Backend Fetch

# vcl_backend_fetch: Called before sending the backend request. In this
# subroutine you typically alter the request before it gets to the backend.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-backend-fetch
# sub vcl_backend_fetch {
#     return (fetch);
# }

# vcl_backend_response: Called after the response headers has been successfully
# retrieved from the backend.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-backend-response
sub vcl_backend_response {
  /* Caching exceptions */
  # Varnish will cache objects with response codes:
  #   200, 203, 300, 301, 302, 307, 404 & 410.
  # SeeV3 https://www.varnish-software.com/static/book/VCL_Basics.html#the-initial-value-of-beresp-ttl
  # Drupal's Imagecache module can return a 307 redirection to the requested
  # url itself and, depending on Drupal's cache settings, this could lead to a
  # redirection loop being cached for a long time but also we want Varnish to
  # shield a little the backend.
  # See http://drupal.org/node/1248010
  # See http://drupal.org/node/310656
  if ( beresp.status == 307
       #TODO# verify that this work better than 'bereq.url ~ "imagecache"'
    && beresp.http.Location == bereq.url
    && beresp.ttl > 5s
  ) {
    set beresp.ttl = 5s;
    set beresp.http.cache-control = "max-age=5";
  }

  /* Request retrial */
  if ( beresp.status == 500
    || beresp.status == 503
  ) {
    #TODO# consider not restarting POST requests as seenV3 on https://www.varnish-cache.org/trac/wiki/VCLExampleSaintMode
    return (retry);
  }

  /* Enable grace mode. Related with vcl_hit */
  # See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-grace.html
  # See https://www.varnish-software.com/blog/grace-varnish-4-stale-while-revalidate-semantics-varnish
  set beresp.grace = 1h;

  /* Strip cookies from the following static file types for all users. */
  # Related with our 12th stage on vcl_recv
  if ( bereq.url ~ "(?i)\.(bz2|css|eot|gif|gz|html?|ico|jpe?g|js|mp3|ogg|otf|pdf|png|rar|svg|swf|tbz|tgz|ttf|woff2?|zip)(\?(itok=)?[a-z0-9_=\.\-]+)?$"
  ) {
    unset beresp.http.set-cookie;
  }

  /* Process ESI responses */
  # Empty in simple configs.
  # See https://www.varnish-cache.org/docs/4.0/users-guide/esi.html
  # Send Surrogate-Capability headers
  # See http://www.w3.org/TR/edge-arch
  # Note that myproxyname is an identifier that should avoid collitions
  # Check for ESI acknowledgement and remove Surrogate-Control header
  #TODO# Add support for Surrogate-Control Targetting
  # if ( beresp.http.Surrogate-Control ~ "ESI/1.0" ) {
  #   unset beresp.http.Surrogate-Control;
  #   set beresp.do_esi = true;
  # }

  /* Gzip response */
  # Empty in simple configs.
  # Use Varnish to Gzip respone, if suitable, before storing it on cache.
  # See https://www.varnish-cache.org/docs/4.0/users-guide/compression.html
  # See https://www.varnish-cache.org/docs/4.0/phk/gzip.html
  if ( ! beresp.http.Content-Encoding
    && ( beresp.http.content-type ~ "text"
      || beresp.http.content-type ~ "application/x-javascript"
      || beresp.http.content-type ~ "application/javascript"
      || beresp.http.content-type ~ "application/rss+xml"
      || beresp.http.content-type ~ "application/xml"
      || beresp.http.content-type ~ "Application/JSON")
  ) {
    set beresp.do_gzip = true;
  }

  /* Debugging headers */
  # Please consider the risks of showing publicly this information, we can wrap
  # this with an ACL.
  # We can add the name of the backend that has processed the request:
  # set beresp.http.X-Backend = beresp.backend.name;
  # We can use a header to tell if the object was gziped by Varnish:
  # if ( beresp.do_gzip ) {
  #   set beresp.http.X-Varnish-Gzipped = "yes";
  # } else {
  #   set beresp.http.X-Varnish-Gizipped = "no";
  # }
  # We can do the same to tell if Varnish is streaming it:
  # if ( beresp.do_stream ) {
  #   set beresp.http.X-Varnish-Streaming = "yes";
  # } else {
  #   set beresp.http.X-Varnish-Streaming = "no";
  # }
  # We can also add headers informing whether the object is cacheable or not and why:
  # SeeV3 https://www.varnish-cache.org/trac/wiki/VCLExampleHitMissHeader#Varnish3.0
  if ( beresp.ttl <= 0s ) {
    /* Varnish determined the object was not cacheable */
    set beresp.http.X-Cacheable = "NO:Not Cacheable";
  } elsif ( bereq.http.Cookie ~ "(SESS|SSESS|NO_CACHE|OATMEAL|CHOCOLATECHIP)" ) {
    /* We don't wish to cache content for logged in users or with certain cookies. */
    # Related with our 9th stage on vcl_recv
    set beresp.http.X-Cacheable = "NO:Cookies";
    # set beresp.uncacheable = true;
  } elsif ( beresp.http.Cache-Control ~ "private" ) {
    /* We are respecting the Cache-Control=private header from the backend */
    set beresp.http.X-Cacheable = "NO:Cache-Control=private";
    # set beresp.uncacheable = true;
  } else {
    /* Varnish determined the object was cacheable */
    set beresp.http.X-Cacheable = "YES";
  }

  /* Further header manipulation */
  # Empty in simple configs.
  # We can also unset some headers to prevent information disclosure and save
  # some cache space.
  # unset beresp.http.Server;
  # unset beresp.http.X-Powered-By;
  # Retry count.
  if ( bereq.retries > 0 ) {
    set beresp.http.X-Retries = bereq.retries;
  }

  /* Continue with built-in logic */
  # We want built-in logic to be processed after ours so we don't call return.
}
# sub vcl_backend_response {
#     if (beresp.ttl <= 0s ||
#       beresp.http.Set-Cookie ||
#       beresp.http.Surrogate-control ~ "no-store" ||
#       (!beresp.http.Surrogate-Control &&
#         beresp.http.Cache-Control ~ "no-cache|no-store|private") ||
#       beresp.http.Vary == "*") {
#         /*
#         * Mark as "Hit-For-Pass" for the next 2 minutes
#         */
#         set beresp.ttl = 120s;
#         set beresp.uncacheable = true;
#     }
#     return (deliver);
# }

# vcl_backend_error: This subroutine is called if we fail the backend fetch.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-backend-error
sub vcl_backend_error {

  /* Try to restart request in case of failure */
  #TODO# Confirm max_retries default value
  # SeeV3 https://www.varnish-cache.org/trac/wiki/VCLExampleRestarts
  if ( bereq.retries < 4 ) {
    return (retry);
  }

  /* Debugging headers */
  # Please consider the risks of showing publicly this information, we can wrap
  # this with an ACL.
  # Retry count
  if ( bereq.retries > 0 ) {
    set beresp.http.X-Retries = bereq.retries;
  }

  set beresp.http.Content-Type = "text/html; charset=utf-8";
  set beresp.http.Retry-After = "5";
  synthetic( {"<!DOCTYPE html>
<html>
  <head>
    <title>"} + beresp.status + " " + beresp.reason + {"</title>
  </head>
  <body>
    <h1>Error "} + beresp.status + " " + beresp.reason + {"</h1>
    <p>"} + beresp.reason + {"</p>
    <h3>Guru Meditation:</h3>
    <p>XID: "} + bereq.xid + {"</p>
    <hr>
    <p>Varnish cache server</p>
  </body>
</html>
"} );

  /* Bypass built-in logic */
  # We make sure no built-in logic is processed after ours returning at this
  # point.
  return (deliver);
}

#######################################################################
# Housekeeping

# vcl_init: Called when VCL is loaded, before any requests pass through it.
# Typically used to initialize VMODs.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-init
# Here is where you should declare your directors now.
# See https://www.varnish-cache.org/docs/4.0/reference/vmod_directors.generated.html
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-backends.html#directors
# Empty in simple configs
# sub vcl_init {
#     return (ok);
# }

# vcl_fini: Called when VCL is discarded only after all requests have exited
# the VCL. Typically used to clean up VMODs.
# See https://www.varnish-cache.org/docs/4.0/users-guide/vcl-built-in-subs.html#vcl-fini
# sub vcl_fini {
#     return (ok);
# }
