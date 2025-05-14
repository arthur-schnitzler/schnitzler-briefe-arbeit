<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei" version="2.0">
    <xsl:output method="xml" encoding="utf-8" indent="no"/>
    <xsl:template match="root">
        <root>
            <xsl:apply-templates/>
        </root>
    </xsl:template>
    <!-- Identity template : copy all text nodes, elements and attributes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template
        match="TEI[descendant::text[@type = 'diaryDay']] | TEI[descendant::text[@type = 'image']] | TEI[descendant::image]">
        <TEI when="{(descendant::date[not(ancestor::kommentar) and ancestor::body]/@when)[1]}"
            n="{(descendant::date[not(ancestor::kommentar) and ancestor::body]/@n)[1]}"
            xml:id="xxxx">
            <xsl:apply-templates select="@* | node()"/>
        </TEI>
    </xsl:template>
    <xsl:template
        match="TEI[descendant::text[@type = 'manuscript']] | TEI[descendant::text[@type = 'article']] | TEI[descendant::text[@type = 'text']] | TEI[descendant::text[@type = 'note']]">
        <TEI when="{descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[1]/@when}"
            n="{descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[1]/@n}"
            xml:id="xxxx">
            <xsl:apply-templates select="@* | node()"/>
        </TEI>
    </xsl:template>
    <xsl:template match="TEI[descendant::correspDesc/correspAction[@type = 'sent']/date]">
        <xsl:choose>
            <xsl:when
                test="descendant::correspDesc/correspAction[@type = 'sent']/date/@when = '' or empty(descendant::correspDesc/correspAction[@type = 'sent']/date/@when)">
                <TEI when="{descendant::correspDesc/correspAction[@type='sent']/date/@notBefore}"
                    n="{descendant::correspDesc/correspAction[@type='sent']/date/@n}" xml:id="xxxx">
                    <xsl:apply-templates select="@* | node()"/>
                </TEI>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="string-length(descendant::correspDesc/correspAction[@type = 'sent']/date/@when) = 4">
                        <TEI
                            when="{concat(descendant::correspDesc/correspAction[@type='sent']/date/@when,'-00-00')}"
                            n="{descendant::correspDesc/correspAction[@type='sent']/date/@n}"
                            xml:id="xxxx">
                            <xsl:apply-templates select="@* | node()"/>
                        </TEI>
                    </xsl:when>
                    <xsl:when
                        test="string-length(descendant::correspDesc/correspAction[@type = 'sent']/date/@when) = 7">
                        <TEI
                            when="{concat(descendant::correspDesc/correspAction[@type='sent']/date/@when,'-00')}"
                            n="{descendant::correspDesc/correspAction[@type='sent']/date/@n}"
                            xml:id="xxxx">
                            <xsl:apply-templates select="@* | node()"/>
                        </TEI>
                    </xsl:when>
                    <xsl:otherwise>
                        <TEI when="{descendant::correspDesc/correspAction[@type='sent']/date/@when}"
                            n="{descendant::correspDesc/correspAction[@type='sent']/date/@n}"
                            xml:id="xxxx">
                            <xsl:apply-templates select="@* | node()"/>
                        </TEI>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
