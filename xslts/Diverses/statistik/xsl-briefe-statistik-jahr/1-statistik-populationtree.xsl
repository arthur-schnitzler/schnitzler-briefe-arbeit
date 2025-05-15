<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.0">
    <xsl:output method="text" indent="false"/>
    <xsl:mode on-no-match="shallow-skip"/>
   
   <!-- die idee hier ist eine statistik der briefe zu bekommen, angewandt auf cmif gesamt, die
   wie ein bevölkerungsdiagramm die briefe schnitzlers im positiven, die an ihn im negativen bereich 
   zeigt -->
   
    <xsl:template match="tei:profileDesc">
        <xsl:variable name="startYear" select="1888" />
        <xsl:variable name="endYear" select="1901" />
        <xsl:variable name="correspAction-gesamt" as="node()" select="."/>
        <xsl:variable name="correspAction-schnitzler" as="node()">
            <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="descendant::tei:correspDesc[tei:correspAction[@type='sent']/tei:persName/@ref='#pmb2121']"/>
            </xsl:element>
        </xsl:variable>
        <xsl:variable name="correspAction-notschnitzler" as="node()">
            <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
                <xsl:copy-of select="descendant::tei:correspDesc[tei:correspAction[last()]/tei:persName/@ref='#pmb2121']"/>
            </xsl:element>
        </xsl:variable>
        <xsl:for-each select="($startYear to $endYear)">
            <xsl:variable name="currentYear" select="." />
            <!-- Zählen der tei:date[@when] für das aktuelle Jahr -->
            <xsl:variable name="countAllDates" select="count($correspAction-gesamt/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <xsl:variable name="countSchnitzlerDates" select="count($correspAction-schnitzler/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <xsl:variable name="countNotSchnitzlerDates" select="count($correspAction-notschnitzler/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <!-- Ausgabe der Anzahl von tei:date[@when] für das aktuelle Jahr -->
            <xsl:value-of select="concat($currentYear, ',-',$countAllDates, ',-',$countSchnitzlerDates, ',',$countAllDates,',', $countNotSchnitzlerDates)" />
            <xsl:text>&#10;</xsl:text>
            
        </xsl:for-each>
        <xsl:variable name="startYear" select="1902" />
        <xsl:variable name="endYear" select="1931" />
        <xsl:for-each select="($startYear to $endYear)">
            <xsl:variable name="currentYear" select="." />
            <!-- Zählen der tei:date[@when] für das aktuelle Jahr -->
            <xsl:variable name="countAllDates" select="count($correspAction-gesamt/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <xsl:variable name="countSchnitzlerDates" select="count($correspAction-schnitzler/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <xsl:variable name="countNotSchnitzlerDates" select="count($correspAction-notschnitzler/descendant::tei:correspDesc[number(tokenize(@ana, '-')[1]) = $currentYear]/number(tokenize(@ana, '-')[1]))" as="xs:integer" />
            <!-- Ausgabe der Anzahl von tei:date[@when] für das aktuelle Jahr -->
            <xsl:value-of select="concat($currentYear, ',-',$countAllDates, ',-',$countSchnitzlerDates, ',',$countAllDates,',', $countNotSchnitzlerDates)" />
            <xsl:text>&#10;</xsl:text>
            
        </xsl:for-each>
        
    </xsl:template>
</xsl:stylesheet>
