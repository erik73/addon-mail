<?php
$CONF['configured'] = true;

$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = getenv("host");
$CONF['database_user'] = getenv("username");
$CONF['database_password'] = getenv("password");
$CONF['database_port'] = getenv("port");
$CONF['database_name'] = 'postfixadmin';

$CONF['default_aliases'] = array (
  'abuse'      => 'abuse@domain',
  'hostmaster' => 'hostmaster@domain',
  'postmaster' => 'postmaster@domain',
  'webmaster'  => 'webmaster@domain'
);

$CONF['password_validation'] = array(
  #    '/regular expression/' => '$PALANG key (optional: + parameter)',
      '/.{4}/'                => 'password_too_short 4',      # minimum length 5 characters
  #    '/([a-zA-Z].*){3}/'     => 'password_no_characters 3',  # must contain at least 3 characters
  #    '/([0-9].*){2}/'        => 'password_no_digits 2',      # must contain at least 2 digits
  );

$CONF['fetchmail'] = 'NO';
$CONF['show_footer_text'] = 'NO';

$CONF['quota'] = 'YES';
$CONF['domain_quota'] = 'YES';
$CONF['quota_multiplier'] = '1024000';
$CONF['used_quotas'] = 'YES';
$CONF['new_quota_table'] = 'YES';

$CONF['aliases'] = '0';
$CONF['mailboxes'] = '0';
$CONF['maxquota'] = '0';
$CONF['domain_quota_default'] = '0';
$CONF['emailcheck_resolve_domain']='NO';
?>
