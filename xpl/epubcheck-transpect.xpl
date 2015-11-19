<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="epubcheck-transpect"
  type="epubcheck:transpect">

  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h1>epubcheck-transpect</h1>
    <p>checks EPUB for compatibility to IDPF EPUB, Amazon KF8/MOBI and various retailers</p>
    <ol>
      <li>
        <i>Bash Script</i>
        <pre>
./epubcheck-transpect 9783110339406.epub</pre>
      </li>
      <li>
        <i>XML Calabash</i>
        <pre>
./calabash/calabash.sh \
  -o result=output/report.xml \
  xpl/epubcheck-transpect.xpl \
  file=9783110339406.epub
        </pre>
      </li>
    </ol>
    
  </p:documentation>

  <!--  *
        * port declarations
        * -->
  <p:documentation xmlns="http://www.w3.org/1999/xhtml"><h2>Ports</h2></p:documentation>
  
  <p:input port="params" primary="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>params</dt><dd>expects a c:param-set document</dd></dl></p:documentation>
  </p:input>
  
  <p:input port="schematron" primary="false" sequence="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>schematron</dt><dd>expects a schematron document</dd></dl></p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>result</dt><dd>provides the report xml file</dd></dl>
    </p:documentation>  
  </p:output>
  
  <!--  *
        * options
        * -->
  <p:documentation xmlns="http://www.w3.org/1999/xhtml">
    <h2>Options</h2>
  </p:documentation>
  
  <p:option name="file" required="true">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>file</dt><dd>the input EPUB file</dd></dl>
    </p:documentation>
  </p:option>
  
  <p:option name="htmlreport" select="'report.html'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>htmlreport</dt><dd>provides the path to the HTML report</dd></dl>
    </p:documentation>
  </p:option>
  
  <p:option name="severity-default-name" select="'warning'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>severity</dt><dd>The default error severity name of the Schematron Asserts/Report</dd></dl>
    </p:documentation>
  </p:option>
  
  <p:option name="phase" select="''"/>
  
  <p:option name="debug" select="'yes'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>debug</dt><dd>switch debugging on or off</dd></dl>
    </p:documentation>
  </p:option>
  
  <p:option name="debug-dir-uri" select="'debug'">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>debug-dir-uri</dt><dd>location of the debug files</dd></dl>
    </p:documentation>
  </p:option>
  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')">
    <p:documentation xmlns="http://www.w3.org/1999/xhtml">
      <dl><dt>status-dir-uri</dt><dd>location of the status files</dd></dl>
    </p:documentation>
  </p:option>

  <!--  *
        * import xproc modules
        * -->
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/resolve-params/xpl/resolve-params.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <p:import href="epubcheck-file-iteration.xpl"/>
  <p:import href="epubcheck-validate.xpl"/>
  <p:import href="epubcheck-htmlreport.xpl"/>
  
  <tr:store-debug pipeline-step="epubcheck-transpect/param-set-original">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] resolve params'"/>
  </cx:message>
  
  <tr:resolve-params name="resolve-params"/>
  
  <tr:store-debug pipeline-step="epubcheck-transpect/param-set-expanded">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
    
  <tr:file-uri name="normalize-filename">
    <p:with-option name="filename" select="$file"/>
  </tr:file-uri>
  
  <tr:store-debug pipeline-step="epubcheck-transpect/zip-filename">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <cx:message>
    <p:with-option name="message" select="'[info] normalize filename: ', /c:result/@os-path"/>
  </cx:message>
  
  <epubcheck:file-iteration name="file-iteration">
    <p:input port="params">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:with-option name="file" select="/c:result/@os-path">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="severity-default-name" select="$severity-default-name"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </epubcheck:file-iteration>
  
  <epubcheck:validate name="validate">
    <p:input port="params">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:input port="schematron">
      <p:pipe port="schematron" step="epubcheck-transpect"/>
    </p:input>
    <p:with-option name="file" select="/c:result/@os-path">
      <p:pipe port="result" step="normalize-filename"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>    
  </epubcheck:validate>
  
  <epubcheck:htmlreport name="report">
    <p:input port="reports">
      <p:pipe port="report" step="validate"/>
    </p:input>
    <p:input port="params">
      <p:pipe port="result" step="resolve-params"/>
    </p:input>
    <p:with-option name="severity-default-name" select="$severity-default-name"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>    
  </epubcheck:htmlreport>
  
</p:declare-step>