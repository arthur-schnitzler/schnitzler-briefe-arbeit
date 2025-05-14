<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0" exclude-result-prefixes="tei">
    <xsl:output method="xml" indent="true"/>
    <xsl:mode on-no-match="shallow-skip"/>
    <!-- Das angewandt auf create-cmif.xml kopiert alle correspDescs zusammen
    und führt, in einem element ab auch die erwähnten Entitäten an-->
    
    <xsl:template match="root">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Arthur Schnitzler – Briefwechsel mit Autorinnen und Autoren
                            CMIF</title>
                        <editor>Martin Anton Müller<email>martin.anton.mueller@oeaw.ac.at</email>
                        </editor>
                        
                            <editor>Martin Anton Müller</editor>
                            <editor>Gerd-Hermann Susen</editor>
                            <editor>Laura Untner</editor>
                            <editor>Selma Jahnke</editor>
                        
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <ref target="https://schnitzler-briefe.acdh.oeaw.ac.at/">Martin Anton
                                Müller</ref>
                        </publisher>
                        <idno type="url"
                            >https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-cmif/main/schnitzler-briefe_cmif.xml</idno>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/null/"
                                >CC0</licence>
                        </availability>
                        <xsl:element name="date">
                            <xsl:attribute name="when">
                                <xsl:value-of select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
                            </xsl:attribute>
                        </xsl:element>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl type="online" xml:id="asbw_0a380dfe-61d4-4b9e-8641-01eba8e50760"
                            >Arthur Schnitzler – Briefwechsel mit Autorinnen und Autoren. Digitale
                            Edition herausgegeben von Martin Anton Müller, Gerd-Hermann Susen und
                            Laura Untner, 2018–[2024] <ref
                                target="https://schnitzler-briefe.acdh.oeaw.ac.at/"
                                >https://schnitzler-briefe.acdh.oeaw.ac.at/</ref>
                        </bibl>
                    </sourceDesc>
                </fileDesc>
                <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:variable name="folderURI" select="resolve-uri('.', base-uri())"/>
                    <xsl:for-each
                        select="collection(concat($folderURI, '../../editions/?select=L0*.xml;recurse=yes'))[descendant::tei:correspAction]/node()">
                        <xsl:if test="not(@xml:id='' or not(@xml:id) or empty(@xml:id))">
                        <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="key">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                            <xsl:attribute name="ref">
                                <xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/', @xml:id, '.html')"/>                
                            </xsl:attribute>
                            <xsl:attribute name="source">
                                <xsl:text>#asbw_0a380dfe-61d4-4b9e-8641-01eba8e50760</xsl:text>                
                            </xsl:attribute>
                            <xsl:copy-of select="descendant::tei:correspDesc/tei:correspAction" copy-namespaces="no"
                            />
<xsl:element name="correspContext" namespace="http://www.tei-c.org/ns/1.0">
    <xsl:element name="ab" namespace="http://www.tei-c.org/ns/1.0">
        <xsl:attribute name="type">
            <xsl:text>entitaeten</xsl:text>
        </xsl:attribute>
        <xsl:if test="tei:text/tei:back/tei:listPerson">
            <xsl:element name="listPerson" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:text/tei:back/tei:listPerson/tei:person[not(@xml:id='pmb2121')]"> <!-- schnitzler nicht -->
                    <xsl:element name="person" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="persName" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ref">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="tei:persName[1][tei:surname and tei:forename]">
                                    <xsl:value-of select="concat(tei:persName[1]/tei:forename, ' ', tei:persName[1]/tei:surname)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="tei:persName[1]"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
        <xsl:if test="tei:text/tei:back/tei:listBibl">
            <xsl:element name="listBibl" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:text/tei:back/tei:listBibl/tei:bibl"> <!-- schnitzler nicht -->
                    <xsl:element name="bibl" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ref">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:title[1]"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
        <xsl:if test="tei:text/tei:back/tei:listOrg">
            <xsl:element name="listOrg" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:text/tei:back/tei:listOrg/tei:org"> <!-- schnitzler nicht -->
                    <xsl:element name="org" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="orgName" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ref">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:orgName[1]"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
        <xsl:if test="tei:text/tei:back/tei:listPlace">
            <xsl:element name="listPlace" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:for-each select="tei:text/tei:back/tei:listPlace/tei:place"> <!-- schnitzler nicht -->
                    <xsl:element name="place" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:element name="placeName" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="ref">
                                <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                            <xsl:value-of select="tei:placeName[1]"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:for-each>
            </xsl:element>
        </xsl:if>
        
    </xsl:element>
    
    
</xsl:element>
                            
                        </xsl:element>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </teiHeader>
            <text>
                <body>
                    <p/>
                </body>
            </text>
        </TEI>
    </xsl:template>
</xsl:stylesheet>
