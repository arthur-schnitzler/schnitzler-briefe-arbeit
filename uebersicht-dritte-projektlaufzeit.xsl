<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" expand-text="yes">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output media-type="text"/>
    <xsl:variable name="editions" select="collection('editions/?select=L0*.xml')"/>
    <xsl:variable name="editionsIII"
        select="$editions
        [number(substring-after(//tei:TEI/@xml:id, 'L0')) &gt; 3614]"/>
    <xsl:template match="*:report">
        <xsl:element name="report">
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>In der dritten Projektlaufzeit wurden Stand </xsl:text>
            <xsl:value-of select="current-date()"/>
            <xsl:text> </xsl:text>
            <xsl:value-of
                select="count($editionsIII[number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614])"/>
            <xsl:text> neue Dokumente mit insgesamt </xsl:text>
            <xsl:value-of
                select="sum($editionsIII[number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614]//tei:revisionDesc/../../count(//tei:pb))"/>
            <xsl:text> Seiten angelegt.
            </xsl:text>
            <xsl:text>Davon wurden bereits </xsl:text>
            <xsl:value-of
                select="count($editionsIII[number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614]//tei:revisionDesc[@status = 'approved'])"/>
            <xsl:text> Dokumente bzw. </xsl:text>
            <xsl:value-of
                select="sum($editionsIII[number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614]//tei:revisionDesc[@status = 'approved']/../../count(//tei:pb))"/>
            <xsl:text> Seiten fertiggestellt.</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>Diese Dokumente sind "proposed":</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:for-each select="$editionsIII">
                <xsl:sort select="//tei:TEI/@xml:id"/>
                    <xsl:choose>
                        <xsl:when
                            test="descendant::tei:revisionDesc[1][@status='proposed']">
                            <xsl:value-of select="tei:TEI/@xml:id"/>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>Diese Dokumente sind "candidate":</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:for-each select="$editionsIII">
                <xsl:sort select="//tei:TEI/@xml:id"/>
                <xsl:choose>
                    <xsl:when
                        test="descendant::tei:revisionDesc[1][@status='candidate']">
                        <xsl:value-of select="tei:TEI/@xml:id"/>
                        <xsl:text>&#xa;</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>Selma, diese Dokumente hast Du noch nicht gesehen:</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:for-each select="$editionsIII">
                <xsl:sort select="//tei:TEI/@xml:id"/>
                <xsl:if test="number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614">
                    <xsl:choose>
                        <xsl:when
                            test="//tei:revisionDesc[not(@status='approved') and not(tei:change/@who='SJ')]">
                            <xsl:value-of select="tei:TEI/@xml:id"/>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:text>Martin, diese Dokumente hast Du noch nicht gesehen:</xsl:text>
            <xsl:text>&#xa;</xsl:text>
            <xsl:for-each select="$editionsIII">
                <xsl:sort select="//tei:TEI/@xml:id"/>
                <xsl:if test="number(substring-after(//tei:TEI/@xml:id, 'L0')) > 3614">
                    <xsl:choose>
                        <xsl:when
                            test="//tei:revisionDesc[not(@status='approved') and not(tei:change[not(. ='Export aus Transkribus')]/@who='MAM')]">
                            <xsl:value-of select="tei:TEI/@xml:id"/>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:when>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
