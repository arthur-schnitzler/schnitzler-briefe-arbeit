<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:p="http://schema.primaresearch.org/PAGE/gts/pagecontent/2013-07-15"
  xmlns:mets="http://www.loc.gov/METS/" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:local="local"
  xmlns:xstring="https://github.com/dariok/XStringUtils" exclude-result-prefixes="#all"
  version="3.0">

  <xsl:output indent="0"/>

  <xd:doc>
    <xd:desc>Whether to create `rs type="..."` for person/place/org (default) or `persName` etc.
      (false())</xd:desc>
  </xd:doc>
  <xsl:param name="rs" select="true()"/>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Author:</xd:b> Dario Kampkaspar, dario.kampkaspar@oeaw.ac.at</xd:p>
      <xd:p>Austrian Centre for Digital Humanities http://acdh.oeaw.ac.at</xd:p>
      <xd:p/>
      <xd:p>This stylesheet, when applied to mets.xml of the PAGE output, will create (valid)
        TEI</xd:p>
      <xd:p/>
      <xd:p><xd:b>Contributor</xd:b> Matthias Boenig, boenig@bbaw.de</xd:p>
      <xd:p>OCR-D, Berlin-Brandenburg Academy of Sciences and Humanities http://ocr-d.de/eng</xd:p>
      <xd:p>extend the original XSL-Stylesheet by specific elements based on the @typing of the text
        region</xd:p>
      <xd:p/>
      <xd:p><xd:b>Contributor</xd:b> Peter Stadler, github:@peterstadler</xd:p>
      <xd:p>Carl-Maria-von-Weber-Gesamtausgabe</xd:p>
      <xd:p>Added corrections to tei:sic/tei:corr</xd:p>
      <xd:p/>
      <xd:p><xd:b>Contributor</xd:b> Till Graller, github:@tillgrallert</xd:p>
      <xd:p>Orient-Institut Beirut</xd:p>
      <xd:p>Use tei:ab as fallback instead of tei:p</xd:p>
    </xd:desc>
  </xd:doc>

  <!-- use extended string functions from https://github.com/dariok/XStringUtils -->
  <xsl:include href="string-pack.xsl"/>

  <xsl:param name="debug" select="false()"/>

  <xd:doc>
    <xd:desc>Entry point: start at the top of METS.xml</xd:desc>
  </xd:doc>
  <xsl:template match="/mets:mets">
    <!--<TEI>
      <teiHeader>
        <fileDesc>
          <titleStmt>
            <xsl:apply-templates select="mets:amdSec//trpDocMetadata/title" />
            <xsl:apply-templates select="mets:amdSec//trpDocMetadata/author" />
            <xsl:apply-templates select="mets:amdSec//trpDocMetadata/uploader" />
          </titleStmt>
          <publicationStmt>
            <publisher>tranScriptorium</publisher>
          </publicationStmt>
          <seriesStmt>
            <xsl:apply-templates select="mets:amdSec//trpDocMetadata/collectionList/colList[1]/colName" />
          </seriesStmt>
          <sourceDesc>
            <p>TRP document creator: <xsl:value-of select="mets:amdSec//uploader"/></p>
            <xsl:apply-templates select="mets:amdSec//trpDocMetadata/desc" />
          </sourceDesc>
        </fileDesc>
      </teiHeader>
      <xsl:if test="not($debug)">
        <facsimile>
          <xsl:apply-templates select="mets:fileSec//mets:fileGrp[@ID='PAGEXML']/mets:file" mode="facsimile" />
        </facsimile>
      </xsl:if>-->
    <text>
      <body>
        <xsl:variable name="make_div">
          <div>
            <xsl:apply-templates select="mets:fileSec//mets:fileGrp[@ID = 'PAGEXML']/mets:file"
              mode="text"/>
          </div>
        </xsl:variable>
        <!--       <xsl:message select="$make_div"></xsl:message>-->
        <xsl:for-each-group select="$make_div//*[local-name() = 'div']/*"
          group-starting-with="*[local-name() = 'head']">
          <div>
            <xsl:copy-of select="current-group()"/>
          </div>
        </xsl:for-each-group>
      </body>
    </text>
    <!--</TEI>-->
  </xsl:template>

  <!-- Templates for trpMetaData -->
  <xd:doc>
    <xd:desc>
      <xd:p>The title within the Transkribus meta data</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:template match="title">
    <title>
      <xsl:if test="position() = 1">
        <xsl:attribute name="type">main</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

  <xd:doc>
    <xd:desc>The author as stated in Transkribus meta data. Will be used in the teiHeader as
      titleStmt/author</xd:desc>
  </xd:doc>
  <xsl:template match="author">
    <author>
      <xsl:apply-templates/>
    </author>
  </xsl:template>

  <xd:doc>
    <xd:desc>The uploader of the current document. Will be used as titleStmt/principal</xd:desc>
  </xd:doc>
  <xsl:template match="uploader">
    <principal>
      <xsl:apply-templates/>
    </principal>
  </xsl:template>

  <xd:doc>
    <xd:desc>The description as given in Transkribus meta data. Will be used in sourceDesc</xd:desc>
  </xd:doc>
  <xsl:template match="desc">
    <p><xsl:apply-templates/></p>
  </xsl:template>

  <xd:doc>
    <xd:desc>The name of the collection from which this document was exported. Will be used as
      seriesStmt/title</xd:desc>
  </xd:doc>
  <xsl:template match="colName">
    <title>
      <xsl:apply-templates/>
    </title>
  </xsl:template>

  <!-- Templates for METS -->
  <xd:doc>
    <xd:desc>Create tei:facsimile with @xml:id</xd:desc>
  </xd:doc>
  <xsl:template match="mets:file" mode="facsimile">
    <xsl:variable name="file" select="document(mets:FLocat/@xlink:href, /)"/>
    <xsl:variable name="numCurr" select="@SEQ"/>

    <xsl:apply-templates select="$file//p:Page" mode="facsimile">
      <xsl:with-param name="imageName" select="substring-after(mets:FLocat/@xlink:href, '/')"/>
      <xsl:with-param name="numCurr" select="$numCurr" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <xd:doc>
    <xd:desc>Apply by-page</xd:desc>
  </xd:doc>
  <xsl:template match="mets:file" mode="text">
    <xsl:variable name="file" select="document(mets:FLocat/@xlink:href, .)"/>
    <xsl:variable name="numCurr" select="@SEQ"/>

    <xsl:apply-templates select="$file//p:Page" mode="text">
      <xsl:with-param name="numCurr" select="$numCurr" tunnel="true"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- Templates for PAGE, facsimile -->
  <xd:doc>
    <xd:desc>
      <xd:p>Create tei:facsimile/tei:surface</xd:p>
    </xd:desc>
    <xd:param name="imageName">
      <xd:p>the file name of the image</xd:p>
    </xd:param>
    <xd:param name="numCurr">
      <xd:p>Numerus currens of the parent facsimile</xd:p>
    </xd:param>
  </xd:doc>
  <xsl:template match="p:Page" mode="facsimile">
    <xsl:param name="imageName"/>
    <xsl:param name="numCurr" tunnel="true"/>

    <xsl:variable name="coords" select="tokenize(p:PrintSpace/p:Coords/@points, ' ')"/>
    <xsl:variable name="type" select="substring-after(@imageFilename, '.')"/>

    <!-- NOTE: up to now, lry and lry were mixed up. This is fiex here. -->
    <surface ulx="0" uly="0" lrx="{@imageWidth}" lry="{@imageHeight}" xml:id="facs_{$numCurr}">
      <graphic
        width="{@imageWidth}px" height="{@imageHeight}px" facs="{encode-for-uri(substring-before($imageName, '.'))||'.'||$type}"/>
      <xsl:apply-templates
        select="p:PrintSpace | p:TextRegion | p:SeparatorRegion | p:GraphicRegion | p:TableRegion"
        mode="facsimile"/>
    </surface>

  </xsl:template>

  <xd:doc>
    <xd:desc>create the zones within facsimile/surface</xd:desc>
    <xd:param name="numCurr">Numerus currens of the current page</xd:param>
  </xd:doc>
  <xsl:template
    match="p:PrintSpace | p:TextRegion | p:SeparatorRegion | p:GraphicRegion | p:TextLine"
    mode="facsimile">
    <xsl:param name="numCurr" tunnel="true"/>

    <xsl:variable name="renditionValue">
      <xsl:choose>
        <xsl:when test="local-name(parent::*) = 'TableCell'">TableCell</xsl:when>
        <xsl:when test="local-name() = 'TextRegion'">TextRegion</xsl:when>
        <xsl:when test="local-name() = 'SeparatorRegion'">Separator</xsl:when>
        <xsl:when test="local-name() = 'GraphicRegion'">Graphic</xsl:when>
        <xsl:when test="local-name() = 'TextLine'">Line</xsl:when>
        <xsl:otherwise>printspace</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="custom" as="map(xs:string, xs:string)">
      <xsl:map>
        <xsl:for-each-group select="tokenize(@custom || ' lfd {' || $numCurr, '\} ')"
          group-by="substring-before(., ' ')">
          <xsl:map-entry key="substring-before(., ' ')"
            select="string-join(substring-after(., '{'), '–')"/>
        </xsl:for-each-group>
      </xsl:map>
    </xsl:variable>

    <xsl:if test="$renditionValue = ('Line', 'TableCell')">
      <xsl:text>
        </xsl:text>
    </xsl:if>
    <zone points="{p:Coords/@points}" rendition="{$renditionValue}">
      <xsl:if test="$renditionValue != 'printspace'">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="'facs_' || $numCurr || '_' || @id"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@type">
        <xsl:attribute name="subtype">
          <xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="map:contains($custom, 'structure') and not(@type)">
        <xsl:attribute name="subtype"
          select="substring-after(substring-before(map:get($custom, 'structure'), ';'), ':')"/>
      </xsl:if>
      <xsl:apply-templates select="p:TextLine" mode="facsimile"/>
      <xsl:if
        test="not($renditionValue = ('Line', 'Graphic', 'Separator', 'printspace', 'TableCell'))">
        <xsl:text>
      </xsl:text>
      </xsl:if>
    </zone>
  </xsl:template>

  <xd:doc>
    <xd:desc>Create the zone for a table</xd:desc>
    <xd:param name="numCurr">Numerus currens of the current page</xd:param>
  </xd:doc>
  <xsl:template match="p:TableRegion" mode="facsimile">
    <xsl:param name="numCurr" tunnel="true"/>

    <zone points="{p:Coords/@points}" rendition="Table">
      <xsl:attribute name="xml:id">
        <xsl:value-of select="'facs_' || $numCurr || '_' || @id"/>
      </xsl:attribute>
      <xsl:apply-templates select="p:TableCell//p:TextLine" mode="facsimile"/>
    </zone>
  </xsl:template>

  <xd:doc>
    <xd:desc>create the page content</xd:desc>
    <xd:param name="numCurr">Numerus currens of the current page</xd:param>
  </xd:doc>
  <!-- Templates for PAGE, text -->
  <xsl:template match="p:Page" mode="text">
    <xsl:param name="imageName"/>
    <xsl:param name="numCurr" tunnel="true"/>

    <xsl:variable name="coords" select="tokenize(p:PrintSpace/p:Coords/@points, ' ')"/>
    <xsl:variable name="type" select="@imageFilename"/>
    <xsl:element name="page" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:choose>
        <xsl:when test="descendant::*:TextLine[@custom/contains(., 'letter-begin')][1] and descendant::*:TextLine[@custom/contains(., 'letter-end')][1]">
          <xsl:attribute name="type">
            <xsl:text>letter-begin-end</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="descendant::*:TextLine[@custom/contains(., 'letter-begin')][1]">
          <xsl:attribute name="type">
            <xsl:text>letter-begin</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="descendant::*:TextLine[@custom/contains(., 'letter-end')][1]">
          <xsl:attribute name="type">
            <xsl:text>letter-end</xsl:text>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
    <pb facs="{substring-before($type, '.jpg')}"/>
    <xsl:apply-templates select="p:TextRegion | p:SeparatorRegion | p:GraphicRegion | p:TableRegion"
      mode="text"/>
    </xsl:element>
  </xsl:template>

  <xd:doc>
    <xd:desc>
      <xd:p>create specific elements based on the @typing of the text region</xd:p>
      <xd:p>PAGE labels for text region see: https://www.primaresearch.org/tools/PAGELibraries
        caption observed header observed footer observed page-number observed drop-capital ignored
        credit ignored floating ignored signature-mark observed catch-word observed marginalia
        observed footnote observed footnote-continued observed endnote ignored TOC-entry ignored
        list-label ignored other observed </xd:p>
    </xd:desc>
    <xd:param name="numCurr"/>
  </xd:doc>
  <xsl:template match="p:TextRegion" mode="text">
    <xsl:param name="numCurr" tunnel="true"/>
    <xsl:variable name="custom" as="map(*)">
      <xsl:apply-templates select="@custom"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@type = 'heading'">
        <head facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </head>
      </xsl:when>
      <xsl:when test="@type = 'caption'">
        <figure>
          <head facs="#facs_{$numCurr}_{@id}">
            <xsl:apply-templates select="p:TextLine"/>
          </head>
        </figure>
      </xsl:when>
      <xsl:when test="@type = 'header'">
        <fw type="header" place="top" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </fw>
      </xsl:when>
      <xsl:when test="@type = 'footer'">
        <fw type="header" place="bottom" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </fw>
      </xsl:when>
      <xsl:when test="@type = 'catch-word'">
        <fw type="catch" place="bottom" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </fw>
      </xsl:when>
      <xsl:when test="@type = 'signature-mark'">
        <fw place="bottom" type="sig" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </fw>
      </xsl:when>
      <xsl:when test="@type = 'marginalia'">
        <note place="[direction]" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </note>
      </xsl:when>
      <xsl:when test="@type = 'footnote'">
        <note place="foot" n="[footnote reference]" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </note>
      </xsl:when>
      <xsl:when test="@type = 'footnote-continued'">
        <note place="foot" n="[footnote-continued reference]" facs="#facs_{$numCurr}_{@id}">
          <xsl:apply-templates select="p:TextLine"/>
        </note>
      </xsl:when>
      <xsl:when test="@type = ('other', 'paragraph')">
<!--        <p facs="#facs_{$numCurr}_{@id}">-->
          <xsl:apply-templates select="p:TextLine"/>
        <!--</p>-->
      </xsl:when>
      <!-- the fallback option should be a semantically open element such as <ab> -->
      <xsl:otherwise>
          <xsl:apply-templates select="p:TextLine"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    <xd:desc>create a table</xd:desc>
    <xd:param name="numCurr"/>
  </xd:doc>
  <xsl:template match="p:TableRegion" mode="text">
    <xsl:param name="numCurr" tunnel="true"/>
    <xsl:text>
      </xsl:text>
    <table facs="#facs_{$numCurr}_{@id}">
      <xsl:for-each-group select="p:TableCell" group-by="@row">
        <xsl:sort select="@col"/>
        <xsl:text>
        </xsl:text>
        <row n="{@row}">
          <xsl:apply-templates select="current-group()"/>
        </row>
      </xsl:for-each-group>
    </table>
  </xsl:template>

  <xd:doc>
    <xd:desc>create table cells</xd:desc>
    <xd:param name="numCurr"/>
  </xd:doc>
  <xsl:template match="p:TableCell">
    <xsl:param name="numCurr" tunnel="true"/>
    <xsl:text>
          </xsl:text>
    <cell facs="#facs_{$numCurr}_{@id}" n="{@col}">
      <xsl:apply-templates select="@rowSpan | @colSpan"/>
      <xsl:attribute name="rend">
        <xsl:value-of select="number((xs:boolean(@leftBorderVisible), false())[1])"/>
        <xsl:value-of select="number((xs:boolean(@topBorderVisible), false())[1])"/>
        <xsl:value-of select="number((xs:boolean(@rightBorderVisible), false())[1])"/>
        <xsl:value-of select="number((xs:boolean(@bottomBorderVisible), false())[1])"/>
      </xsl:attribute>
      <xsl:apply-templates select="p:TextLine"/>
    </cell>
  </xsl:template>
  <xd:doc>
    <xd:desc>rowspan -> rows</xd:desc>
  </xd:doc>
  <xsl:template match="@rowSpan">
    <xsl:choose>
      <xsl:when test=". &gt; 1">
        <xsl:attribute name="rows" select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xd:doc>
    <xd:desc>colspan -> cols</xd:desc>
  </xd:doc>
  <xsl:template match="@colSpan">
    <xsl:choose>
      <xsl:when test=". &gt; 1">
        <xsl:attribute name="cols" select="."/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--  <xd:doc>
    <xd:desc>
      Combine taggings marked with “continued” – cf. https://github.com/dariok/page2tei/issues/10
      Thanks to @thodel for reporting.
    </xd:desc>
    <xd:param name="context" />
  </xd:doc>
  <xsl:template name="continuation">
    <xsl:param name="context" />
    <xsl:for-each select="$context/node()">
      <xsl:choose>
        <xsl:when test="@continued
          and following-sibling::*[1][self::tei:lb]
          and string-length(normalize-space(following-sibling::node()[1])) = 0">
          <xsl:element name="{local-name()}">
            <xsl:sequence select="@*[not(local-name() = 'continued')]" />
            <xsl:sequence select="node()" />
            <lb>
              <xsl:sequence select="following-sibling::*[1]/@*" />
              <xsl:attribute name="break" select="'no'" />
            </lb>
            <xsl:sequence select="following-sibling::*[2]/node()" />
          </xsl:element>
        </xsl:when>
        <xsl:when test="(self::tei:lb
            and preceding-sibling::*[1]/@continued
            and string-length(normalize-space(preceding-sibling::node()[1])) = 0
            and following-sibling::node()[1]/@continued)
          or (@continued and preceding-sibling::node()[1][self::tei:lb])
          or (self::text()
            and normalize-space() = ''
            and preceding-sibling::node()[1]/@continued
            and following-sibling::node()[1][self::tei:lb])" />
        <xsl:otherwise>
          <xsl:sequence select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>-->

  <xd:doc>
    <xd:desc>Converts one line of PAGE to one line of TEI</xd:desc>
    <xd:param name="numCurr">Numerus currens, to be tunneled through from the page level</xd:param>
  </xd:doc>
  <xsl:template match="p:TextLine">
    <xsl:param name="numCurr" tunnel="true"/>

    <xsl:variable name="text" select="p:TextEquiv/p:Unicode"/>
    <xsl:variable name="custom" as="text()*">

      <xsl:for-each select="tokenize(@custom, '\}')">
        <xsl:choose>
          <xsl:when
            test="string-length() &lt; 1 or starts-with(., 'readingOrder') or starts-with(normalize-space(), 'structure')"/>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="starts" as="map(*)">
      <xsl:map>
        <xsl:if test="count($custom) &gt; 0">
          <xsl:for-each-group select="$custom"
            group-by="substring-before(substring-after(., 'offset:'), ';')">
            <xsl:map-entry key="xs:int(current-grouping-key())" select="current-group()"/>
          </xsl:for-each-group>
        </xsl:if>
      </xsl:map>
    </xsl:variable>
    <xsl:variable name="ends" as="map(*)">
      <xsl:map>
        <xsl:if test="count($custom) &gt; 0">
          <xsl:for-each-group select="$custom" group-by="
              xs:int(substring-before(substring-after(., 'offset:'), ';'))
              + xs:int(substring-before(substring-after(., 'length:'), ';'))">
            <xsl:map-entry key="current-grouping-key()" select="current-group()"/>
          </xsl:for-each-group>
        </xsl:if>
      </xsl:map>
    </xsl:variable>
    <xsl:variable name="prepped">
      <xsl:for-each select="0 to string-length($text)">
        <xsl:if test=". &gt; 0">
          <xsl:value-of select="substring($text, ., 1)"/>
        </xsl:if>
        <xsl:for-each select="map:get($starts, .)">
          <!--<xsl:sort select="substring-before(substring-after(.,'offset:'), ';')" order="ascending"/>-->
          <!-- end of current tag -->
          <xsl:sort select="
              xs:int(substring-before(substring-after(., 'offset:'), ';'))
              + xs:int(substring-before(substring-after(., 'length:'), ';'))"
            order="descending"/>
          <xsl:sort select="substring(., 1, 3)" order="ascending"/>
          <xsl:element name="local:m">
            <xsl:attribute name="type" select="normalize-space(substring-before(., ' '))"/>
            <xsl:attribute name="o" select="substring-after(., 'offset:')"/>
            <xsl:attribute name="pos">s</xsl:attribute>
          </xsl:element>
        </xsl:for-each>
        <xsl:for-each select="map:get($ends, .)">
          <xsl:sort select="substring-before(substring-after(., 'offset:'), ';')" order="descending"/>
          <xsl:sort select="substring(., 1, 3)" order="descending"/>
          <xsl:element name="local:m">
            <xsl:attribute name="type" select="normalize-space(substring-before(., ' '))"/>
            <xsl:attribute name="o" select="substring-after(., 'offset:')"/>
            <xsl:attribute name="pos">e</xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="prepared">
      <xsl:for-each select="$prepped/node()">
        <xsl:choose>
          <xsl:when test="@pos = 'e'">
            <xsl:variable name="position" select="count(preceding-sibling::node())"/>
            <xsl:variable name="o" select="@o"/>
            <xsl:variable name="id" select="@type"/>
            <xsl:variable name="precs"
              select="preceding-sibling::local:m[@pos = 's' and preceding-sibling::local:m[@o = $o]]"/>

            <xsl:for-each select="$precs">
              <xsl:variable name="so" select="@o"/>
              <xsl:variable name="myP"
                select="count(following-sibling::local:m[@pos = 'e' and @o = $so]/preceding-sibling::node())"/>
              <xsl:if test="
                  following-sibling::local:m[@pos = 'e' and @o = $so
                  and $myP &gt; $position] and not(@type = $id)">
                <local:m type="{@type}" pos="e" o="{@o}"
                  prev="{$myP||'.'||$position||($myP > $position)}"/>
              </xsl:if>
            </xsl:for-each>
            <xsl:sequence select="."/>
            <xsl:for-each select="$precs">
              <xsl:variable name="so" select="@o"/>
              <xsl:variable name="myP"
                select="count(following-sibling::local:m[@pos = 'e' and @o = $so]/preceding-sibling::node())"/>
              <xsl:if test="
                  following-sibling::local:m[@pos = 'e' and @o = $so
                  and $myP &gt; $position] and not(@type = $id)">
                <local:m type="{@type}" pos="s" o="{@o}"
                  prev="{$myP||'.'||$position||($myP > $position)}"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="pos"
      select="xs:integer(substring-before(substring-after(@custom, 'index:'), ';')) + 1"/>

    <!-- TODO parameter to create <l>...</l> - #1 -->
    <xsl:text>
      </xsl:text>
    <xsl:if test="contains(@custom, 'type:paragraph')">
      <!--<xsl:text>&lt;p&gt;</xsl:text>-->
      <paragraph-start/>
    </xsl:if>
    <!--<lb facs="#facs_{$numCurr}_{@id}" n="N{format-number($pos, '000')}"/>-->
    <xsl:apply-templates select="$prepared/text()[not(preceding-sibling::local:m)]"/>
    <xsl:apply-templates select="
        $prepared/local:m[@pos = 's']
        [count(preceding-sibling::local:m[@pos = 's']) = count(preceding-sibling::local:m[@pos = 'e'])]"/>
    <!--[not(preceding-sibling::local:m[1][@pos='s'])]" />-->
    <!--<xsl:if test="following-sibling::p:TextLine[1]/contains(@custom, 'type:paragraph') and not(ancestor-or-self::p:TextLine/@custom/contains(.,'salute'))">
      <xsl:text>&lt;/p&gt;</xsl:text>
    </xsl:if>-->
  </xsl:template>

  <xd:doc>
    <xd:desc>Starting milestones for (possibly nested) elements</xd:desc>
  </xd:doc>
  <xsl:template match="local:m[@pos = 's']">
    <xsl:variable name="o" select="@o"/>
    <xsl:variable name="custom" as="map(*)">
      <xsl:map>
        <xsl:variable name="t" select="tokenize(@o, ';')"/>
        <xsl:if test="count($t) &gt; 1">
          <xsl:for-each select="$t[. != '']">
            <xsl:map-entry key="normalize-space(substring-before(., ':'))"
              select="normalize-space(substring-after(., ':'))"/>
          </xsl:for-each>
        </xsl:if>
      </xsl:map>
    </xsl:variable>

    <xsl:variable name="elem">
      <local:t>
        <xsl:sequence select="
            following-sibling::node()
            intersect following-sibling::local:m[@o = $o]/preceding-sibling::node()"/>
      </local:t>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="@type = 'textStyle'">
        <xsl:choose>
          <xsl:when test="@o[contains(., 'strikethrough')]">
            <del rend="strikethrough">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </del>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'bold')]">
            <hi rend="bold">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'italic')]">
            <hi rend="italics">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'subscript')]">
            <hi rend="subscript">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'superscript')]">
            <hi rend="superscript">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'underlined')]">
            <hi rend="underline" n="">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'smallCaps')]">
            <hi rend="small_caps">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@o[contains(., 'letterSpaced')]">
            <hi rend="spaced_out">
              <xsl:call-template name="elem">
                <xsl:with-param name="elem" select="$elem"/>
              </xsl:call-template>
            </hi>
          </xsl:when>
        </xsl:choose>
      </xsl:when>

      <xsl:when test="@type = 'supplied'">
        <supplied>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </supplied>
      </xsl:when>

      <xsl:when test="@type = 'Address'">
        <address>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </address>
      </xsl:when>

      <xsl:when test="@type = 'foreign'">
        <foreign xml:lang="">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </foreign>
      </xsl:when>

      <xsl:when test="@type = 'addrLine'">
        <addrLine>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </addrLine>
      </xsl:when>

      <xsl:when test="@type = 'opener'">
        <opener>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </opener>
      </xsl:when>

      <xsl:when test="@type = 'closer'">
        <closer>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </closer>
      </xsl:when>

      <xsl:when test="@type = 'postscript'">
        <postscript>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </postscript>
      </xsl:when>

      <xsl:when test="@type = 'comment'">
        <xsl:variable name="comment"
          select="@o/substring-before(substring-after(., 'comment:'), ';')"/>
        <anchor type="commentary" xml:id="XXXX">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
          <xsl:text>[Kommentar: </xsl:text>
          <xsl:value-of select="$comment"/>
          <xsl:text>]</xsl:text>
        </anchor>
        <note type="commentary" xml:id="XXXX"/>
      </xsl:when>

      <!--      <TextLine id="line_1648725614556_91" custom="readingOrder {index:0;} comment {offset:0; length:5;comment:test;}">-->

      <xsl:when test="@type = 'work'">
        <rs type="work" ref="">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </rs>
      </xsl:when>

      <xsl:when test="@type = 'signed'">
        <signed>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </signed>
      </xsl:when>

      <xsl:when test="@type = 'time'">
        <time>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </time>
      </xsl:when>


      <xsl:when test="@type = 'pre-print'">
        <hi rend="pre-print">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </hi>
      </xsl:when>

      <xsl:when test="@type = 'salute'">
        <salute>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </salute>
      </xsl:when>

      <xsl:when test="@type = 'closer'">
        <closer>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </closer>
      </xsl:when>

      <xsl:when test="@type = 'signed'">
        <signed>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </signed>
      </xsl:when>

      <xsl:when test="@type = 'latintype'">
        <hi rend="latintype">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </hi>
      </xsl:when>

      <xsl:when test="@type = 'paragraph-begin'">
        <!--<xsl:text>&lt;p&gt;</xsl:text>-->
        <paragraph-start/>
      </xsl:when>

      <xsl:when test="@type = 'paragraph-start'">
        <!--<xsl:text>&lt;p&gt;</xsl:text>-->
        <paragraph-start/>
      </xsl:when>

      <!--<xsl:when test="@type = 'paragraph-end'">
        <!-\-<xsl:text>&lt;&#47;p&gt;</xsl:text>-\->
        <paragraph-end/>
      </xsl:when>-->

      <!--<xsl:when test="@type = 'paragraph-inbetween'">
        <xsl:text>&lt;p&gt;&lt;&#47;p&gt;</xsl:text>
      </xsl:when>-->

     <!-- <xsl:when test="@type = 'letter-begin'">
        <xsl:text>&lt;letter&gt;</xsl:text>
      </xsl:when>

      <xsl:when test="@type = 'letter-end'">
        <xsl:text>&lt;&#47;letter&gt;</xsl:text>
      </xsl:when>-->

      <xsl:when test="@type = 'date'">
        <date>
          <!--<xsl:variable name="year" select="if(map:keys($custom) = 'year') then format-number(xs:integer(map:get($custom, 'year')), '0000') else '00'"/>
          <xsl:variable name="month" select=" if(map:keys($custom) = 'month') then format-number(xs:integer(map:get($custom, 'month')), '00') else '00'"/>
          <xsl:variable name="day" select=" if(map:keys($custom) = 'day') then format-number(xs:integer(map:get($custom, 'day')), '00') else '00'"/>
          <xsl:variable name="when" select="$year||'-'||$month||'-'||$day" />
          <xsl:if test="$when != '0000-00-00'">
            <xsl:attribute name="when" select="$when" />
          </xsl:if>-->
          <xsl:for-each select="map:keys($custom)">
            <xsl:if test=". != 'length' and . != ''">
              <xsl:attribute name="{.}" select="map:get($custom, .)"/>
            </xsl:if>
          </xsl:for-each>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </date>
      </xsl:when>

      <xsl:when test="@type = 'person'">
        <xsl:variable name="elName" select="
            if ($rs) then
              'rs'
            else
              'persName'"/>
        <xsl:element name="{$elName}">
          <xsl:if test="$rs">
            <xsl:attribute name="type">person</xsl:attribute>
            <xsl:attribute name="ref"/>
          </xsl:if>
          <xsl:if test="$custom('lastname') != '' or $custom('firstname') != ''">
            <xsl:attribute name="key"
              select="replace($custom('lastname'), '\\u0020', ' ') || ', ' || replace($custom('firstname'), '\\u0020', ' ')"
            />
          </xsl:if>
          <xsl:if test="$custom('continued')">
            <xsl:attribute name="continued" select="true()"/>
          </xsl:if>

          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@type = 'place'">
        <xsl:variable name="elName" select="
            if ($rs) then
              'rs'
            else
              'placeName'"/>
        <xsl:element name="{$elName}">
          <xsl:if test="$rs">
            <xsl:attribute name="type">place</xsl:attribute>
            <xsl:attribute name="ref"/>
          </xsl:if>
          <xsl:if test="$custom('placeName') != ''">
            <xsl:attribute name="key" select="replace($custom('placeName'), '\\u0020', ' ')"/>
          </xsl:if>

          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <xsl:when test="@type = 'organization'">
        <xsl:variable name="elName" select="
            if ($rs) then
              'rs'
            else
              'orgName'"/>
        <xsl:element name="{$elName}">
          <xsl:if test="$rs">
            <xsl:attribute name="type">org</xsl:attribute>
            <xsl:attribute name="ref"/>
          </xsl:if>
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{@type}">
          <xsl:call-template name="elem">
            <xsl:with-param name="elem" select="$elem"/>
          </xsl:call-template>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:apply-templates
      select="following-sibling::local:m[@pos = 'e' and @o = $o]/following-sibling::node()[1][self::text()]"
    />
  </xsl:template>

  <xd:doc>
    <xd:desc>Process what's between a pair of local:m</xd:desc>
    <xd:param name="elem"/>
  </xd:doc>
  <xsl:template name="elem">
    <xsl:param name="elem"/>

    <xsl:choose>
      <xsl:when test="$elem//local:m">
        <xsl:apply-templates select="$elem/local:t/text()[not(preceding-sibling::local:m)]"/>
        <xsl:apply-templates select="
            $elem/local:t/local:m[@pos = 's']
            [not(preceding-sibling::local:m[1][@pos = 's'])]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$elem/local:t/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    <xd:desc>Leave out possibly unwanted parts</xd:desc>
  </xd:doc>
  <xsl:template match="p:Metadata" mode="text"/>

  <xd:doc>
    <xd:desc>Parse the content of an attribute such as @custom into a map.</xd:desc>
  </xd:doc>
  <xsl:template match="@custom" as="map(*)">
    <xsl:map>
      <xsl:for-each select="tokenize(., '\}')[normalize-space() != '']">
        <xsl:map-entry key="substring-before(normalize-space(), ' ')">
          <xsl:map>
            <xsl:for-each select="tokenize(substring-after(., '{'), ';')[normalize-space() != '']">
              <xsl:map-entry key="substring-before(., ':')" select="substring-after(., ':')"/>
            </xsl:for-each>
          </xsl:map>
        </xsl:map-entry>
      </xsl:for-each>
    </xsl:map>
  </xsl:template>

  <xd:doc>
    <xd:desc>Text nodes to be copied</xd:desc>
  </xd:doc>
  <!--<xsl:template match="text()">
    <!-\-<xsl:value-of select="."/>-\->
    <xsl:value-of select="translate(., '¬', '')"/>
    <!-\- Zeilenumbruchszeichen entfernen -\->
  </xsl:template>-->

</xsl:stylesheet>
