<?php
  // find the site root
  require_once('class.siteroot.php');		// Load SiteRoot class
  $sr = new SiteRoot();			// Create SiteRoot object
  //$sr->setDebug();			// Optionally set debug in dev/test
  $fsSitePath = $sr->getFsRoot();	// Get filesystem root-dir
  $webSitePath = $sr->getWebRoot();	// Get web root-dir

  // display using webtemplate
  require_once("$fsSitePath/common/class.sten.php");	// Refer to Sten class or other files

  ////////////////////////////////////////////////////////////////////////////
  // Valid access to this script via HTTP GET:
  //   http://MYHOST/MYPATH/THIS_SCRIPT.php
  // or HTTP POST (or GET) variable: t=TYPE&q=SUBQUERY
  $max_chars_http_var = 200;	// Char-limit for HTTP POST & GET vars
  $error_msg = null;		// Assume no error

  $fields = array('t', 'q');
  $param = array();
  foreach ($fields as $field) {
    // Prefer to use POST field
    if (array_key_exists($field, $_POST) && strlen($_POST[$field]) > 0)
      $ref_value =& $_POST[$field];	// Use reference/pointer (as string may be huge due to mis-use)

    elseif (array_key_exists($field, $_GET) && strlen($_GET[$field]) > 0)
      $ref_value =& $_GET[$field];	// Use reference/pointer (as string may be huge due to mis-use)

    else
      $ref_value = "";

    // Too long
    if (strlen($ref_value) > $max_chars_http_var) {
      $error_msg = <<<EOMSG1
        <div>
          <p><strong>Search Results</strong><br />
          <font face="arial, helvetica, sans-serif" size=1 color="4A293A"> (Invalid search. No records found) </font>
        </div>
EOMSG1;
      break;
    }

    // Too short
    if ("$ref_value" == "") {
      $error_msg = '';			// No error for empty value-string
      break;
    }
    $param[$field] =& $ref_value;
  }

  if (is_null($error_msg)) {
      $fname = "$param[t]/$param[q].inc.html";	// TYPE/SUBQUERY.inc.html
      if (!file_exists($fname)) {
        $error_msg = <<<EOMSG2
          <div>
            <p><strong>Search Results</strong><br />
            <font face="arial, helvetica, sans-serif" size=1 color="4A293A"> (Invalid search - no records found) </font>
          </div>
EOMSG2;
      }
  }

  $tpl = new Sten();			// Create template obj
  if (is_null($error_msg))
    $tpl->addToken('sten_search_content',    'file',      $fname);
  else
    $tpl->addToken('sten_search_content',    'text',      $error_msg);

  //$tpl->setDebug();			// Switch on debug/verification web-page
  $tpl->show("$fsSitePath/common/template.html");	// Show the template (with tokens replaced with content)
?>
