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
  <p:output port="result"/>
  
  <p:option name="href" required="true"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/calabash-extensions/image-props-extension/image-identify-declaration.xpl"/>
  <p:import href="http://transpect.io/css-tools/xpl/css.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <cx:message>
    <p:with-option name="message" select="'[info] load content-file: ', $href"/>
  </cx:message>
  
  <tr:load fail-on-error="false" name="load-content-files">
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
  
  <!-- analyze images -->
  
  <p:viewport match="//html:img" name="viewport">
    
    <cx:message>
      <p:with-option name="message" select="'[info] analyze image: ', html:img/@src"/>
    </cx:message>
    
    <tr:image-identify name="image-identify">
      <p:with-option name="href" select="resolve-uri(html:img/@src, base-uri())"/>
    </tr:image-identify>
    
    <p:insert match="html:img" position="first-child">
      <p:input port="insertion">
        <p:pipe port="report" step="image-identify"/>
      </p:input>
    </p:insert>
    
  </p:viewport>
  
</p:declare-step>