<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:array="http://www.w3.org/2005/xpath-functions/array" exclude-result-prefixes="#all"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="personen" as="array(xs:string*)"
        select="['#pmb12438', 
        ('#pmb2147', '#pmb2260'), 
        '#pmb10762', 
        ('#pmb10815', '#pmb10818', '#pmb10818', '#pmb5490', '#pmb10977', '#pmb5489', '#pmb29124', '#pmb11054', '#pmb18530', '#pmb29126', '#pmb11913', '#pmb29122', '#pmb29123', '#pmb29121', '#pmb5495', '#pmb28344', '#pmb29120', '#pmb12968', '#pmb27882', '#pmb27886'), 
        ('#pmb10863', '#pmb13923', '#pmb2668', '#pmb10860'), 
        '#pmb10912', 
        '#pmb10955', 
        ('#pmb14328', '#pmb35015'), 
        ('#pmb10992', '#pmb4395', '#pmb5558'), 
        '#pmb11002', 
        '#pmb11036', 
        ('#pmb11061', '#pmb11324'), 
        '#pmb11098', 
        '#pmb2416', 
        '#pmb2281', 
        ('#pmb11148', '#pmb4358'), 
        ('#pmb11230', '#pmb15716', '#pmb29150'), 
        ('#pmb2450', '#pmb42508'), 
        '#pmb11527', 
        ('#pmb11617', '#pmb11617'), 
        ('#pmb11740', '#pmb16658', '#pmb16670', '#pmb3220', '#pmb2292', '#pmb18404', '#pmb11737', '#pmb24033', '#pmb24239'), 
        '#pmb11763', 
        ('#pmb2563', '#pmb28812', '#pmb41355'), 
        ('#pmb11988', '#pmb2446', '#pmb29184', '#pmb5830', '#pmb3004', '#pmb12564', '#pmb4498', '#pmb13064'), 
        ('#pmb12071', '#pmb29182', '#pmb11697', '#pmb29183', '#pmb5822', '#pmb5819', '#pmb12614', '#pmb12826', '#pmb2725'), 
        '#pmb4986', 
        ('#pmb12176', '#pmb12173'), 
        '#pmb12170', 
        '#pmb12183', 
        '#pmb12225', 
        '#pmb9550', 
        '#pmb12740', 
        '#pmb26121', 
        '#pmb13055', 
        '#pmb13068', 
        '#pmb3557', 
        '#pmb13212',
        '#pmb2167',
        '#pmb12740', 
        '#pmb11485',
        '#pmb11216']"/>
    <!-- Listet die Briefwechsel auf. Mehrere Personen in einem Briefwechsel mit Klammer verbunden -->
    <!-- Brandes incl. Tochter und Rung-->
    <!-- Muss nicht alphabetisch geordnet sein, die Liste
    kann aus listeDerBriefwechsel transformiert werden-->
    <xsl:key name="sent-by" match="TEI"
        use="descendant::correspDesc/correspAction[@type = 'sent']/persName/@ref"/>
    <xsl:key name="received-by" match="TEI"
        use="descendant::correspDesc/correspAction[@type = 'received']/persName/@ref"/>
    <xsl:variable name="sent-by-arthur"
        select="key('sent-by', ('#pmb2121', '#pmb2173', '#pmb12698', '#pmb12692'))"/>
    <xsl:variable name="received-by-arthur"
        select="key('received-by', ('#pmb2121', '#pmb2173', '#pmb12698', '#pmb12692'))"/>
    <xsl:template match="/*">
        <xsl:variable name="root" select="."/>
        <xsl:copy>
            <xsl:for-each select="1 to array:size($personen)">
                <xsl:apply-templates
                    select="key('sent-by', $personen(.), $root) intersect $received-by-arthur | key('received-by', $personen(.), $root) intersect $sent-by-arthur">
                    <xsl:with-param name="correspondence" select="$personen(.)[1]"/>
                </xsl:apply-templates>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="TEI">
        <xsl:param name="correspondence"/>
        <TEI bw="{$correspondence}">
            <xsl:apply-templates select="@* | node()"/>
        </TEI>
        <xsl:if test="starts-with(@xml:id, 'E')">
            <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.tei-c.org/ns/1.0 ../../XML/META/asbwschema.xsd"
                xml:id="xxxx">
                <xsl:attribute name="bw">
                    <xsl:value-of select="concat('A', substring(@xml:id, 2))"/>
                </xsl:attribute>
                <xsl:apply-templates select="@* | node()"/>
            </TEI>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
