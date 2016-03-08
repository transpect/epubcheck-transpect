<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="htmlreport"
  type="epubcheck:htmlreport">

  <p:documentation>
    Takes the SVRL results and the HTML files and provide
    a HTML report of the EPUB package.
  </p:documentation>
  
  <p:input port="source" primary="true"/>
  <p:input port="reports" primary="false" sequence="true"/>
  <p:input port="params" primary="false"/>
  
  <p:output port="result"/>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:option name="severity-default-name" select="'error'"/>
  
  <p:import href="http://transpect.io/htmlreports/xpl/patch-svrl.xpl"/>
  <p:import href="http://transpect.io/xproc-util/html-embed-resources/xpl/html-embed-resources.xpl"/>
  
  <cx:message>
    <p:with-option name="message" select="'[info] combine HTML chunks'"/>
  </cx:message>
  
  <p:xslt name="epubcheck-transform-wrap">
    <p:input port="stylesheet">
      <p:document href="../xsl/epubcheck-transform-wrap.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="params" step="htmlreport"/>
    </p:input>
  </p:xslt>
  
  <tr:store-debug pipeline-step="epubcheck-htmlreport/wrap-html" extension="html">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <tr:html-embed-resources name="html-embed-resources">
    <p:with-option name="fail-on-error" select="'false'">
      <p:documentation>sometimes resources such as CSS overrides in the content repository don't exist</p:documentation>
    </p:with-option>
  </tr:html-embed-resources>
  
  <tr:store-debug pipeline-step="epubcheck-htmlreport/wrap-html-embedded-resources" extension="html">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] patch SVRL into HTML'"/>
  </cx:message>
  
  <tr:patch-svrl name="patch-svrl">
    <p:input port="reports">
      <p:pipe step="htmlreport" port="reports"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="params" step="htmlreport"/>
    </p:input>
    <p:with-option name="report-title" select="'epubcheck'"/>
    <p:with-option name="show-adjusted-srcpath" select="'yes'"/>
    <p:with-option name="show-step-name" select="'no'"/>
    <p:with-option name="severity-default-name" select="$severity-default-name"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:patch-svrl>
  
  <p:delete match="@srcpath"/>
  
</p:declare-step>
