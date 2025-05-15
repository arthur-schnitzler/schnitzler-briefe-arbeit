<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy" />
        
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