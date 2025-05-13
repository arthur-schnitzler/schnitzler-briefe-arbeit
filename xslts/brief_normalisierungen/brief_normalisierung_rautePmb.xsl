<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    
    <!-- das entfernt whitespace am Beginn eines Elements: -->
    <xsl:template match="tei:*[not(child::*) and starts-with(text()[1], ' ')]/text()">
        <xsl:value-of select="replace(., '^\s+', '')"/>
    </xsl:template>
        
    <xsl:template match="@ref">
        <xsl:attribute name="ref">
            <xsl:for-each select="tokenize(., ' ')">
                <xsl:choose>
                    <xsl:when test="starts-with(., '#pmb')">
                        <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="replace(., '#', '#pmb')"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(position() = last())">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@scribe">
        <xsl:attribute name="scribe">
            <xsl:choose>
                <xsl:when test="starts-with(., '#pmb')">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(., '#', '#pmb')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="tei:handNote/@corresp">
        <xsl:attribute name="corresp">
            <xsl:choose>
                <xsl:when test="starts-with(., '#pmb')">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(., '#', '#pmb')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <!-- Das hier überprüft, ob die Kombination @when/@n eindeutig ist -->
    <xsl:template
        match="tei:correspAction[@type='sent']/tei:date[@n and @*[name() = 'when' or name() = 'from' or name() = 'notBefore']]">
            <xsl:element name="date" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="@*[not(name()='n')]"/>
                    <xsl:attribute name="n">
                        <xsl:choose>
                            <xsl:when test="string-length(@n) = 1">
                                <xsl:value-of select="concat('0', @n)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@n"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                <xsl:copy-of select="text()[1]"/>
            <xsl:variable name="nn" select="@n"/>
            <xsl:variable name="attribute-when">
                <xsl:choose>
                    <xsl:when test="@when">
                        <xsl:value-of select="@when"/>
                    </xsl:when>
                    <xsl:when test="@from">
                        <xsl:value-of select="@from"/>
                    </xsl:when>
                    <xsl:when test="@noBefore">
                        <xsl:value-of select="@notBefore"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="current-xml-id" select="ancestor::tei:TEI[1]/@xml:id[1]"/>
            <xsl:for-each
                select="collection('../?select=L0*.xml;recurse=yes')[descendant::tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspAction[1]/tei:date[@n = $nn and (@*[name() = 'when' or name() = 'notBefore' or name() = 'from'][1] = $attribute-when)]]/tei:TEI/@xml:id">
                <xsl:if test="not(. = $current-xml-id)">
                    <xsl:element name="duplicate-date-nn" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:attribute name="of">
                            <xsl:value-of select="."/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:if>
            </xsl:for-each>
            </xsl:element>
    </xsl:template>
    
    <!-- Das hier schreibt die Verweise, die einen 
            ganzen Kommentar ausmachen, zu Großbuchstaben am 
            Anfang um und hängt ein Punkt an
            
            Also
            vgl. Schnitzler-Tagebuch, 4.4.1890
            wird zu
            
            Vgl. Schnitzler-Tagebuch, 4.4.1890.
           
        -->
    
    <!-- Identifizieren der relevanten Elemente -->
    <xsl:template match="tei:note[@type='commentary' and not(child::*[2]) and normalize-space(.)='']/tei:ref[@subtype='cf']">
        <!-- Kopiere das Element, aber ändere das Attribut 'subtype' -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="subtype">Cf</xsl:attribute>
        </xsl:copy><xsl:text>.</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:note[@type='commentary' and not(child::*[2]) and normalize-space(.)='']/tei:ref[@subtype='see']">
        <!-- Kopiere das Element, aber ändere das Attribut 'subtype' -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="subtype">See</xsl:attribute>
        </xsl:copy><xsl:text>.</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="tei:note[@type='commentary' and not(child::*[2]) and normalize-space(.)='']/tei:ref">
        <!-- Kopiere das Element, aber ändere das Attribut 'subtype' -->
        <xsl:copy>
            <xsl:copy-of select="@*"/>
        </xsl:copy><xsl:text>.</xsl:text>
    </xsl:template>
</xsl:stylesheet>
