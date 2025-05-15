<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="tei"
                version="2.0">
    
    <xsl:output method="xml" encoding="utf-8" indent="yes"/>
    
    <!-- Identity template : copy all text nodes, elements and attributes -->  
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:template match="tei:profileDesc">
        <xsl:copy copy-namespaces="no">
        <xsl:apply-templates select="@*|node()"/>
        <correspDesc>
            <correspAction type="sent">
                    <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:sender/tei:persName"/>
                <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:placeSender/tei:placeName"/>            
                <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:dateSender/tei:date"/>
            </correspAction>
            <correspAction type="received">
                <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:addressee/tei:persName"/>
                <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:placeAddressee/tei:placeName"/>
                <xsl:variable name="stamps"
                             select="count(parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness[1]/tei:msDesc/tei:physDesc/tei:stamp/tei:date)"/>
                <xsl:if test="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness[1]/tei:msDesc/tei:physDesc/tei:stamp[tei:date][$stamps]/tei:date and                     not(parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness[1]/tei:msDesc/tei:physDesc/tei:stamp[tei:date][$stamps]/tei:date/@when = parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:correspDesc/tei:dateSender/tei:date/@when)">
                    <xsl:apply-templates select="parent::tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness[1]/tei:msDesc/tei:physDesc/tei:stamp[tei:date][$stamps]/tei:date"/>
                </xsl:if>
            </correspAction>
        </correspDesc>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:correspDesc"/>
  
    
    
</xsl:stylesheet>
