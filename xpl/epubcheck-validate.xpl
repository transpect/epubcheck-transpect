<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:svrl="http://purl.oclc.org/dsdl/svrl"
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="validate"
  type="epubcheck:validate">
  
  <p:input port="source" primary="true"/>
  <p:input port="params" primary="false"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="epubtools-schematron"/>
  </p:output>
  <p:output port="report" primary="false">
    <p:pipe port="result" step="schematron-debug"/>
  </p:output>
  
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.io/schematron/xpl/oxy-schematron.xpl"/>
  <p:import href="http://transpect.io/xproc-util/insert-srcpaths/xpl/insert-srcpaths.xpl"/>
  
  <tr:insert-srcpaths/>
  
  <tr:store-debug pipeline-step="epubcheck-validate/wrap-with-srcpaths">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] start Schematron validation'"/>
  </cx:message>
  
  <tr:oxy-validate-with-schematron name="epubtools-schematron">
    <p:input port="schema">
      <p:document href="http://transpect.io/epubtools/schematron/epub.sch.xml"/>
    </p:input>
    <p:with-param name="allow-foreign" select="'true'"/>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </tr:oxy-validate-with-schematron>
  
  <p:sink/>
  
  <p:add-attribute attribute-name="tr:step-name" attribute-value="validate-epub" match="/svrl:schematron-output">
    <p:input port="source">
      <p:pipe port="report" step="epubtools-schematron"/>
    </p:input>
  </p:add-attribute>

  <p:add-attribute attribute-name="tr:rule-family" attribute-value="validate-epub" match="/svrl:schematron-output"/>
  
  <tr:store-debug pipeline-step="epubcheck-validate/wrap-with-srcpaths" name="schematron-debug">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
</p:declare-step>