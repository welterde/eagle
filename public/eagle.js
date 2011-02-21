$(document).ready(function() {
  $('select#action').change(function() {
    alert($('input#value'));
    switch($('select#action').val()) {
      case 'prefix':
        $('input#value').attr('name', 'prefix');
        $('input#value').attr('placeholder', 'Enter an IP address or CIDR prefix (1.2.3.4, 5.6.7.0/24, etc)...');
        break;
      case 'asn':
        $('input#value').attr('placeholder', 'Enter an AS number (digits only: 23456, 18559, etc)...');
        break;
      default:
        $('input#data').attr('placeholder', '...');
        break;
    }
});
