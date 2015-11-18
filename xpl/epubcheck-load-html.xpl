<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="load-html"
  type="epubcheck:load-html">
  
  <p:input port="source"/>
  <p:output port="result" primary="true"/>
  <p:output port="report" primary="false">
    <p:pipe port="report" step="try"/>
  </p:output>
  
  <p:option name="href" required="true"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/css-tools/xpl/css.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <cx:message>
    <p:with-option name="message" select="'[info] load content-file: ', $href"/>
  </cx:message>
  
  <p:try name="try">
    <p:group>
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false">
        <p:inline>
          <c:result>ok</c:result>
        </p:inline>
      </p:output>
      
      <tr:load fail-on-error="true" name="load-content-files">
        <p:with-option name="href" select="$href"/>
      </tr:load>
      
      <cx:message>
        <p:with-option name="message" select="'[info] parse CSS files: ', //html:link[@type eq 'text/css']/@href"/>
      </cx:message>
      
      <!-- expand internal and external css resources as XML attributes -->
      
      <css:expand name="expand">
        <p:input port="stylesheet">
          <p:document href="http://transpect.io/css-tools/xsl/css-parser.xsl"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      </css:expand>
      
    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false"/>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
      </p:identity>
      
      <cx:message>
        <p:with-option name="message" select="'[ERROR] Could not load HTML file'"/>
      </cx:message>
      
      <p:add-attribute attribute-name="tr:step-name" attribute-value="load-html" match="/c:errors"/>

      <p:add-attribute attribute-name="tr:rule-family" attribute-value="load-html" match="/c:errors" name="forward-error"/>
      
    </p:catch>
  
  </p:try>
  
</p:declare-step>