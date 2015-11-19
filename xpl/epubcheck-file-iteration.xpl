<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:tr="http://transpect.io"
  xmlns:epubcheck="http://transpect.io/epubcheck"
  version="1.0"
  name="file-iteration"
  type="epubcheck:file-iteration">
  
  <p:input port="source" primary="true"/>
  <p:input port="params" primary="false"/>
  
  <p:output port="result" primary="true"/>
  <p:output port="report" primary="false" sequence="true">
    <p:pipe port="report" step="try"/>
  </p:output>
  
  <p:option name="file" required="true"/>
  <p:option name="severity-default-name" select="'warning'"/>
  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>  
  <p:option name="status-dir-uri" select="concat($debug-dir-uri, '/status')"/>
  
  <p:import href="http://transpect.io/calabash-extensions/image-props-extension/image-identify-declaration.xpl"/>
  <p:import href="http://transpect.io/calabash-extensions/unzip-extension/unzip-declaration.xpl"/>
  <p:import href="http://transpect.io/xproc-util/file-uri/xpl/file-uri.xpl"/>
  <p:import href="http://transpect.io/xproc-util/load/xpl/load.xpl"/>
  <p:import href="http://transpect.io/xproc-util/simple-progress-msg/xpl/simple-progress-msg.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xml-model/xpl/prepend-xml-model.xpl"/>

  <p:import href="epubcheck-load-html.xpl"/>
  
  <p:try name="try">
    <p:group>
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:pipe port="report" step="content-file-iteration-group"/>
      </p:output>
      
      <p:variable name="dest-dir" select="concat(replace($file, '^(.+)/.+$', '$1/'), 'archive')"/>
      
      <tr:simple-progress-msg file="epubcheck-transpect_extract.txt">
        <p:input port="msgs">
          <p:inline>
            <c:messages>
              <c:message xml:lang="en">Dekomprimiere Archiv</c:message>
              <c:message xml:lang="de">Extract archive</c:message>
            </c:messages>
          </p:inline>
        </p:input>
        <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
      </tr:simple-progress-msg>
      
      <p:xslt name="generate-epubconfig">
        <p:input port="source">
          <p:pipe port="params" step="file-iteration"/>
        </p:input>
        <p:input port="stylesheet">
          <p:document href="../xsl/epubcheck-params-to-checks.xsl"/>
        </p:input>
        <p:with-param name="severity-default-name" select="$severity-default-name"/>
      </p:xslt>
      
      <cx:message>
        <p:with-option name="message" select="'[info] unzip: ', $file, ' &#xa; => ', $dest-dir"/>
      </cx:message>
      
      <tr:unzip name="unzip">
        <p:with-option name="zip" select="$file"/>
        <p:with-option name="dest-dir" select="$dest-dir"/>
        <p:with-option name="overwrite" select="'yes'"/>
      </tr:unzip>
      
      <tr:store-debug pipeline-step="epubcheck-file-iteration/archive">
        <p:with-option name="active" select="$debug"/>
        <p:with-option name="base-uri" select="$debug-dir-uri"/>
      </tr:store-debug>
      
      <p:group name="content-file-iteration-group">
        <p:output port="result" primary="true"/>
        <p:output port="report" primary="false" sequence="true">
          <p:pipe port="report" step="content-file-iteration"/>
        </p:output>
        <p:variable name="base-uri" select="/c:files/@xml:base"/>
        <p:variable name="container-xml" select="/c:files/c:file[@name eq 'META-INF/container.xml']/@name"/>
        
        <!-- generate file list -->
        
        <p:xslt name="generate-opf-file-representation">
          <p:input port="stylesheet">
            <p:document href="../xsl/epubcheck-opf-file-representation.xsl"/>
          </p:input>
          <p:input port="parameters">
            <p:empty/>
          </p:input>
        </p:xslt>
        
        <tr:store-debug pipeline-step="epubcheck-file-iteration/files">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <p:viewport match="//c:file[@href][matches(@href, '(jpg|png|svg)$', 'i')]" name="image-viewport">
          
          <cx:message>
            <p:with-option name="message" select="'[info] analyze image: ', c:file/@oebps-name"/>
          </cx:message>
          
          <tr:image-identify name="image-identify">
            <p:with-option name="href" select="c:file/@href"/>
          </tr:image-identify>
          
          <p:insert match="c:file" position="first-child">
            <p:input port="insertion">
              <p:pipe port="report" step="image-identify"/>
            </p:input>
          </p:insert>
          
        </p:viewport>

        <!-- load META-INF/container.xml to retrieve the path of the OPF file -->
        
        <cx:message>
          <p:with-option name="message" select="'[info] load Container-XML: ', $container-xml"/>
        </cx:message>

        <p:sink/>

        <tr:load fail-on-error="true" name="load-container-xml">
          <p:with-option name="href" select="replace(concat($base-uri, $container-xml), '%2F', '/')"/>
        </tr:load>
        
        <tr:store-debug pipeline-step="epubcheck-file-iteration/archive_container-xml">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <!-- load OPF file -->
        
        <cx:message>
          <p:with-option name="message" select="'[info] load OPF: ', /*:container/*:rootfiles[1]/*:rootfile[1]/@full-path"/>
        </cx:message>
        
        <tr:load fail-on-error="true" name="load-opf">
          <p:with-option name="href" select="replace(concat($base-uri, /*:container/*:rootfiles[1]/*:rootfile[1]/@full-path), '%2F', '/')"/>
        </tr:load>
        
        <tr:store-debug pipeline-step="epubcheck-file-iteration/opf">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <!-- load NCX file if exists -->
          
        <cx:message cx:depends-on="load-opf">
          <p:with-option name="message" select="'[info] load NCX if exists: ', /*:package/*:manifest/*:item[@media-type eq 'application/x-dtbncx+xml']/@full-path">
            <p:pipe port="result" step="load-opf"/>
          </p:with-option>
        </cx:message>
        
        <tr:load fail-on-error="false" name="load-ncx">
          <p:with-option name="href" select="replace(concat($base-uri, /*:package/*:manifest/*:item[@media-type eq 'application/x-dtbncx+xml']/@href), '%2F', '/')">
            <p:pipe port="result" step="load-opf"/>
          </p:with-option>
        </tr:load>
        
        <tr:store-debug pipeline-step="epubcheck-file-iteration/ncx">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <!-- load HTML content documents -->
      
        <p:for-each name="content-file-iteration">
          <p:output port="result" primary="true" sequence="true"/>
          <p:output port="report" primary="false" sequence="true">
            <p:pipe port="report" step="load-html"/>
          </p:output>
          
          <p:iteration-source select="/*:package/*:spine/*:itemref">
            <p:pipe port="result" step="load-opf"/>
          </p:iteration-source>
          <p:variable name="opf-href" select="/*/@xml:base">
            <p:pipe port="result" step="load-opf"/>
          </p:variable>
          <p:variable name="itemref-id" select="*:itemref/@idref"/>
          <p:variable name="content-href" select="replace(concat(replace($opf-href, '^(.+/).+$', '$1'), /*:package/*:manifest/*:item[@id eq $itemref-id]/@href), '%2F', '/')">
            <p:pipe port="result" step="load-opf"/>
          </p:variable>
          
          <!-- load html files, expand CSS and analyze images -->
          
          <epubcheck:load-html name="load-html">
            <p:with-option name="href" select="$content-href"/>
            <p:with-option name="debug" select="$debug"/>
            <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
            <p:with-option name="status-dir-uri" select="$status-dir-uri"/>    
          </epubcheck:load-html>
          
          <tr:store-debug>
            <p:with-option name="pipeline-step" select="concat('epubcheck-file-iteration/content__', replace($content-href, '^.+/(.+)$', '$1'))"/>
            <p:with-option name="active" select="$debug"/>
            <p:with-option name="base-uri" select="$debug-dir-uri"/>
          </tr:store-debug>
          
        </p:for-each>
        
        <p:wrap-sequence wrapper="document" wrapper-prefix="cx" wrapper-namespace="http://xmlcalabash.com/ns/extensions"/>
        
        <p:add-attribute match="/cx:document" attribute-name="name" attribute-value="wrap-chunks" name="wrap-chunks"/>
        
        <tr:store-debug pipeline-step="epubcheck-file-iteration/html-chunks">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
        <p:sink/>
        
        <p:insert match="/c:wrap" position="first-child">
          <p:input port="source">
            <p:inline>
              <c:wrap xmlns="http://www.w3.org/ns/xproc-step"/>
            </p:inline>
          </p:input>
          <p:input port="insertion">
            <p:pipe port="result" step="generate-epubconfig"/>
            <p:pipe port="result" step="load-opf"/>
            <p:pipe port="result" step="image-viewport"/>
            <p:pipe port="result" step="wrap-chunks"/>
            <p:pipe port="result" step="load-ncx"/>
            <p:pipe port="result" step="unzip"/>
          </p:input>
        </p:insert>
        
        <p:rename match="/c:wrap/c:files" new-name="c:zipfile"/>

        <tr:prepend-xml-model name="prepend-schematron-model">
          <p:input port="models">
            <p:inline>
              <c:models>
                <c:model href="http://transpect.io/epubtools/schematron/epub.sch.xml" type="application/xml" 
                         schematypens="http://purl.oclc.org/dsdl/schematron"/>
              </c:models>
            </p:inline>
          </p:input>
        </tr:prepend-xml-model>

        <tr:store-debug pipeline-step="epubcheck-file-iteration/wrap">
          <p:with-option name="active" select="$debug"/>
          <p:with-option name="base-uri" select="$debug-dir-uri"/>
        </tr:store-debug>
        
      </p:group>      
     
    </p:group>
    <p:catch name="catch">
      <p:output port="result" primary="true"/>
      <p:output port="report" primary="false" sequence="true">
        <p:pipe port="result" step="forward-error"/>
      </p:output>
      
      <p:identity name="identity">
        <p:input port="source">
          <p:pipe port="error" step="catch"/>
        </p:input>
      </p:identity>
      
      <cx:message>
        <p:with-option name="message" select="'[ERROR] EPUB file iteration failed! &#xa;', /c:errors"/>
      </cx:message>
      
      <p:add-attribute attribute-name="tr:step-name" attribute-value="file-load" match="/c:errors"/>
      
      <p:add-attribute attribute-name="tr:rule-family" attribute-value="file-load" match="/c:errors" name="forward-error"/>
      
    </p:catch>
  </p:try>
  
</p:declare-step>