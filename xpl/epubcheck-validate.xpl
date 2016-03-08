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

  <p:documentation>
    Validates the EPUB with Schematron and XProc wrappers for
    IDPF epubcheck and Amazon KindleGen.
  </p:documentation>
  
  <p:input port="source" primary="true"/>
  <p:input port="params" primary="false"/>
  <p:input port="schematron" primary="false" sequence="true"/>
  
  <p:output port="result" primary="true">
    <p:pipe port="result" step="insert-srcpaths"/>
  </p:output>
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="schematron-iteration"/>
    <p:pipe port="result" step="epubcheck-idpf"/>
    <p:pipe port="report" step="kindlegen"/>
  </p:output>
  
  <p:option name="file" required="true"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/epubcheck-idpf/xpl/epubcheck.xpl"/>
  <p:import href="http://transpect.io/kindlegen/xpl/kindlegen.xpl"/>
  <p:import href="http://transpect.io/schematron/xpl/oxy-schematron.xpl"/>
  <p:import href="http://transpect.io/xproc-util/insert-srcpaths/xpl/insert-srcpaths.xpl"/>
  
  <tr:insert-srcpaths name="insert-srcpaths"/>
  
  <tr:store-debug pipeline-step="epubcheck-validate/wrap-with-srcpaths">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] start Schematron validation'"/>
  </cx:message>
  
  <p:sink/>
  
  <p:for-each name="schematron-iteration">
    <p:iteration-source>
      <p:pipe port="schematron" step="validate"/>
      <p:document href="http://transpect.io/epubtools/schematron/epub.sch.xml"/>
    </p:iteration-source>
    <p:output port="report" primary="true"/>
    <p:output port="result" primary="false">
      <p:pipe port="result" step="oxy-schematron"/>
    </p:output>
    
    <tr:oxy-validate-with-schematron name="oxy-schematron">
      <p:input port="schema">
        <p:pipe port="current" step="schematron-iteration"/>
      </p:input>
      <p:input port="source">
        <p:pipe port="result" step="insert-srcpaths"/>
      </p:input>
      <p:with-param name="allow-foreign" select="'true'"/>
    </tr:oxy-validate-with-schematron>
    
    <p:sink name="sink1"/>
    
    <p:add-attribute match="/*" attribute-name="tr:rule-family" name="a1">
      <p:input port="source">
        <p:pipe port="report" step="oxy-schematron"/>
      </p:input>
      <p:with-option name="attribute-value" select="(/*/@tr:rule-family, replace( base-uri(/*), '^.+/(.+)\..+$', '$1') )[1]">
        <p:pipe port="current" step="schematron-iteration"/>
      </p:with-option>
    </p:add-attribute>
    
    <p:add-attribute match="/*" attribute-name="tr:step-name" name="a2">
      <p:with-option name="attribute-value" select="(/*/@tr:step-name, replace( base-uri(/*), '^.+/(.+)\..+$', '$1') )[1]">
        <p:pipe port="current" step="schematron-iteration"/>
      </p:with-option>
    </p:add-attribute>
    
    <tr:store-debug>
      <p:with-option name="pipeline-step" 
        select="concat('epubcheck-validate/svrl_',
                        (/*/@tr:step-name, replace( base-uri(/*), '^.+/(.+)\..+?$', '$1') )[1]
                      )">
        <p:pipe port="current" step="schematron-iteration"/>
      </p:with-option>
      <p:with-option name="active" select="$debug"/>
      <p:with-option name="base-uri" select="$debug-dir-uri"/>
    </tr:store-debug>
    
  </p:for-each>
  
  <p:sink/>
    
  <tr:epubcheck-idpf name="epubcheck-idpf" cx:depends-on="schematron-iteration">
    <p:with-option name="epubfile-path" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>    
  </tr:epubcheck-idpf>
  
  <cx:message>
    <p:with-option name="message" select="'[info] check file with Amazon Kindlegen'"/>
  </cx:message>
  
  <p:sink/>
  
  <tr:kindlegen name="kindlegen" cx:depends-on="epubcheck-idpf">
    <p:with-option name="epub" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:kindlegen>
  
  <p:sink/>
  
</p:declare-step>
