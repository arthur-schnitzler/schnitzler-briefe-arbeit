<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:foo="whatever"
    version="3.0" exclude-result-prefixes="tei">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:param name="listcorrespondence" select="document('../../indices/listcorrespondence.xml')"/>
    <xsl:template match="main">
        <xsl:variable name="folderURI" select="resolve-uri('.', base-uri())"/>
        <xsl:for-each
            select="$listcorrespondence/descendant::tei:listPerson/tei:personGrp[not(@xml:id = 'correspondence_null')]">
            <xsl:variable name="correspondence-nummer"
                select="replace(@xml:id, 'correspondence_', '')"/>
            <xsl:variable name="dateiname" select="concat('toc_', $correspondence-nummer, '.xml')"/>
            <xsl:variable name="Korrespondenzname" select="foo:nameOhneKomma(child::tei:persName[@role = 'main'][1])"/>
            <xsl:result-document indent="true" href="../../tocs/{$dateiname}">
                <TEI xmlns="http://www.tei-c.org/ns/1.0"
                    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    xsi:schemaLocation="http://www.tei-c.org/ns/1.0        http://diglib.hab.de/rules/schema/tei/P5/v2.3.0/tei-p5-transcr.xsd">
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat('korrespondenz_', $correspondence-nummer)"/>
                    </xsl:attribute>
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title level="s">Arthur Schnitzler: Briefwechsel mit Autorinnen und
                                    Autoren</title>
                                <xsl:element name="title">
                                    <xsl:attribute name="level">
                                        <xsl:text>a</xsl:text>
                                    </xsl:attribute>
                                    <xsl:text>Korrespondenz Arthur Schnitzler – </xsl:text>
                                    <xsl:value-of select="$Korrespondenzname"/>
                                </xsl:element>
                                <respStmt>
                                    <resp>providing the content</resp>
                                    <name>Martin Anton Müller</name>
                                    <name>Gerd-Hermann Susen</name>
                                    <name>Laura Untner</name>
                                    <name>Selma Jahnke</name>
                                </respStmt>
                                <respStmt>
                                    <resp>converted to XML encoding</resp>
                                    <name>Martin Anton Müller</name>
                                </respStmt>
                            </titleStmt>
                            <publicationStmt>
                                <publisher>Austrian Centre for Digital Humanities and Cultural Heritage (ACDH-CH)</publisher>
                                <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                                    <xsl:value-of select="current-date()"/>
                                </xsl:element>
                                <idno type="URI">
                                    <xsl:text>https://id.acdh.oeaw.ac.at/schnitzler-briefe/tocs/</xsl:text>
                                    <xsl:value-of select="$dateiname"/>
                                </idno>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Inhaltsverzeichnis einzelner Korrespondenzen von
                                    schnitzler-briefe</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <xsl:element name="list" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:for-each
                                    select="collection(concat($folderURI, '../../editions/?select=L0*.xml;recurse=yes'))[descendant::tei:correspContext/tei:ref[@type='belongsToCorrespondence' and @target= concat('correspondence_', $correspondence-nummer)]]/node()">
                                    <xsl:sort
                                        select="child::tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type = 'sent']/tei:date[1]/@*[name() = 'when' or name() = 'from' or name() = 'notBefore']"/>
                                    <xsl:sort
                                        select="child::tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type = 'sent']/tei:date[1]/@n"/>
                                    <xsl:if test="child::*[1]"><!-- Brachialmethode. Es kamen bei Bahr, Robert Adam und noch
                                    ein paar anderen leere Elemente raus: <item corresp=""/>. Keine Ahnung, warum-->
                                    <xsl:element name="item" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="corresp">
                                            <xsl:value-of select="@xml:id"/>
                                        </xsl:attribute>
                                        <xsl:copy-of
                                            select="child::tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[@level = 'a'][1]"
                                            copy-namespaces="false"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"/>
                                        <xsl:copy-of
                                            select="child::tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[@type = 'sent']/tei:date[1]"
                                            xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                                            copy-namespaces="false"/>
                                    </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:element>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="foo:nameOhneKomma" as="xs:string">
        <xsl:param name="name" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="contains($name, ', ')">
                <xsl:value-of select="concat(substring-after($name, ', ')[1], ' ', substring-before($name, ', ')[1])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$name"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
</xsl:stylesheet>
