<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:param name="input" as="xs:string"/>
    
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title level="s">Arthur Schnitzler: Briefwechsel mit Autorinnen und
                            Autoren</title>
                        <title level="a">
                        <xsl:choose>
                            <xsl:when test="ends-with($input, 'erson')">
                                <xsl:text>Verzeichnis der vorkommenden Personen</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'bibl')">
                                <xsl:text>Verzeichnis der vorkommenden Werke</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'org')">
                                <xsl:text>Verzeichnis der vorkommenden Institutionen</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'place')">
                                <xsl:text>Verzeichnis der vorkommenden Orte</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'events')">
                                <xsl:text>Verzeichnis der vorkommenden Ereignisse</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        </title>
                        <respStmt>
                            <resp>providing the content</resp>
                            <name>Martin Anton Müller</name>
                            <name>Gerd-Hermann Susen</name>
                            <name>Laura Untner</name>
                            <name>Selma Jahnke</name>
                            <name>PMB (Personen der Moderne Basis)</name>
                        </respStmt>
                        <respStmt>
                            <resp>converted to XML encoding</resp>
                            <name>Martin Anton Müller</name>
                        </respStmt>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>Austrian Centre for Digital Humanities and Cultural Heritage (ACDH-CH)</publisher>
                        <pubPlace>Vienna, Austria</pubPlace>
                        <date>
                            <xsl:value-of select="current-date()"/>
                        </date>
                        <xsl:element name="idno">
                            <xsl:attribute name="type">
                                <xsl:text>URI</xsl:text>
                            </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="ends-with($input, 'erson')">
                                <xsl:text>https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listPerson</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'ibl')">
                                <xsl:text>https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listBibl</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'rg')">
                                <xsl:text>https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listOrg</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'lace')">
                                <xsl:text>https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listPlace</xsl:text>
                            </xsl:when>
                            <xsl:when test="ends-with($input, 'vents')">
                                <xsl:text>https://id.acdh.oeaw.ac.at/arthur-schnitzler-briefe/v1/indices/listEvent</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                        </xsl:element>
                        <xsl:element name="idno">
                            <xsl:attribute name="type">
                                <xsl:text>handle</xsl:text>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="ends-with($input, 'erson')">
                                    <xsl:text>https://hdl.handle.net/21.11115/0000-000E-753F-9</xsl:text>
                                </xsl:when>
                                <xsl:when test="ends-with($input, 'ibl')">
                                    <xsl:text>https://hdl.handle.net/21.11115/0000-000E-7542-4</xsl:text>
                                </xsl:when>
                                <xsl:when test="ends-with($input, 'rg')">
                                    <xsl:text>https://hdl.handle.net/21.11115/0000-000E-753D-B</xsl:text>
                                </xsl:when>
                                <xsl:when test="ends-with($input, 'lace')">
                                    <xsl:text>https://hdl.handle.net/21.11115/0000-000E-753E-A</xsl:text>
                                </xsl:when>
                                <xsl:when test="ends-with($input, 'vents')">
                                    <xsl:text>XXXX</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:element>
                        
                    </publicationStmt>
                    <sourceDesc>
                        <p>Entitäten für die Edition der Korrespondenz Schnitzlers mit Autorinnen und Autoren, https://schnitzler-briefe.acdh.oeaw.ac.at/</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    
                </body>
            </text>
        </TEI>
        
        
    </xsl:template>
    
    
</xsl:stylesheet>