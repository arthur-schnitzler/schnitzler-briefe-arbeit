<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output indent="yes" method="xml" encoding="utf-8" omit-xml-declaration="false"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="correspPartner" select="document('../../indices/listcorrespondence.xml')"/>
    <xsl:key name="corresp-lookup" match="tei:personGrp" use="tei:persName/@ref"/>
    <!-- Diese Datei fügt correspDesc zwei Attribute hinzu: ana mit einem Iso-Datum und person mit
der liste aller Korrespondenzpartner*innen Schnitzlers. 
Zusätzlich wird ein neues correspContext-Element angelegt, das bei den
zugehörigen Briefwechseln die zugehörigen Nummern angibt (also Anna Bahr-Mildenburg zu Bahr). Hier 
entstehen Duplikate! -->
    <xsl:template match="tei:profileDesc">
        <xsl:element name="profileDesc" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="child::tei:correspDesc">
                <xsl:variable name="date-n">
                    <xsl:choose>
                        <xsl:when test="tei:correspAction[1]/tei:date/@when">
                            <xsl:value-of select="tei:correspAction[1]/tei:date/@when"/>
                        </xsl:when>
                        <xsl:when test="tei:correspAction[1]/tei:date/@from">
                            <xsl:value-of select="tei:correspAction[1]/tei:date/@from"/>
                        </xsl:when>
                        <xsl:when test="tei:correspAction[1]/tei:date/@notBefore">
                            <xsl:value-of select="tei:correspAction[1]/tei:date/@notBefore"/>
                        </xsl:when>
                        <xsl:when test="tei:correspAction[1]/tei:date/@to">
                            <xsl:value-of select="tei:correspAction[1]/tei:date/@to"/>
                        </xsl:when>
                        <xsl:when test="tei:correspAction[1]/tei:date/@notAfter">
                            <xsl:value-of select="tei:correspAction[1]/tei:date/@notAfter"/>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when
                            test="string-length(tei:correspAction[@type = 'sent']/tei:date/@n) = 1">
                            <xsl:value-of
                                select="concat('_0', tei:correspAction[@type = 'sent']/tei:date/@n)"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat('_', tei:correspAction[@type = 'sent']/tei:date/@n)"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="partner" as="node()">
                    <xsl:choose>
                        <xsl:when
                            test="tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2121' or tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb2173' or tei:correspAction[@type = 'sent']/tei:persName/@ref = '#pmb12695'">
                            <xsl:copy-of select="tei:correspAction[@type = 'received']"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="tei:correspAction[@type = 'sent']"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:element name="correspDesc" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:copy-of select="@*"/>
                    <xsl:attribute name="ana">
                        <xsl:value-of select="$date-n"/>
                    </xsl:attribute>
                    <xsl:for-each select="tei:correspAction">
                        <xsl:element name="correspAction" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:value-of select="@type"/>
                            </xsl:attribute>
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:for-each>
                    <xsl:element name="correspContext" namespace="http://www.tei-c.org/ns/1.0">
                        <xsl:for-each select="$partner/tei:persName">
                            <xsl:choose>
                                <xsl:when
                                    test="key('corresp-lookup', @ref, $correspPartner)/@xml:id = 'correspondence_null'"/>
                                <!-- Das filtert die paar Fälle, die wir (noch) nicht aufnehmen -->
                                <xsl:otherwise>
                                    <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
                                        <xsl:attribute name="type">
                                            <xsl:text>belongsToCorrespondence</xsl:text>
                                        </xsl:attribute>
                                        <xsl:choose>
                                            <xsl:when
                                                test="string-length(key('corresp-lookup', @ref, $correspPartner)/tei:persName[@role = 'main']) &gt; 1">
                                                <xsl:attribute name="target">
                                                  <xsl:value-of
                                                  select="key('corresp-lookup', @ref, $correspPartner)/@xml:id"
                                                  />
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="key('corresp-lookup', @ref, $correspPartner)/tei:persName[@role = 'main']"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="target">
                                                  <xsl:value-of select="@ref"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                        <xsl:copy-of select="tei:correspContext/child::*"/>
                    </xsl:element>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
